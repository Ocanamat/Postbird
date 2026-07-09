<#
.SYNOPSIS
    Deploy the postbird theme into a Betterbird (or Thunderbird) profile.

.DESCRIPTION
    Mirrors  chrome\postbird\  and copies  chrome\userChrome.css  and
    chrome\userContent.css  into  <profile>\chrome\ . Only the files postbird
    owns are touched — other files in the profile's chrome\ folder are left
    alone.  (userChrome.css styles the app UI; userContent.css styles the email
    body. postbird's config.css tokens are shared by both.)

    Both files are only read at startup, so the app must be restarted after
    every deploy. This script reminds you; it does not restart for you.

    The profile is auto-detected from %APPDATA%\Betterbird or ...\Thunderbird
    (the default install in profiles.ini, else the newest *.default-release).
    Override with -ProfilePath if you have a non-standard setup.

.PARAMETER ProfilePath
    Explicit profile directory. If omitted, the script auto-detects it.

.PARAMETER Link
    Instead of copying, junction chrome\postbird so repo edits are live without
    redeploying (still requires a restart). The loaders are always copied.

.EXAMPLE
    .\scripts\deploy.ps1
.EXAMPLE
    .\scripts\deploy.ps1 -ProfilePath 'D:\tb\profiles\abc.default-release'
#>
[CmdletBinding()]
param(
    [string] $ProfilePath,
    [switch] $Link
)

$ErrorActionPreference = 'Stop'

function Resolve-MailProfile {
    # Betterbird reuses the Thunderbird profile root by default; support both.
    foreach ($appName in @('Betterbird', 'Thunderbird')) {
        $root = Join-Path $env:APPDATA $appName
        if (-not (Test-Path $root)) { continue }

        # 1) Honour profiles.ini's default install, if present.
        $iniPath = Join-Path $root 'profiles.ini'
        if (Test-Path $iniPath) {
            $ini = Get-Content $iniPath
            $default = ($ini | Select-String -Pattern '^\s*Default\s*=\s*(.+\.default-release.*)$').Matches |
                       ForEach-Object { $_.Groups[1].Value.Trim() } | Select-Object -First 1
            if ($default) {
                $candidate = Join-Path $root ($default -replace '/', '\')
                if (Test-Path $candidate) { return $candidate }
            }
        }

        # 2) Fallback: newest *.default-release under Profiles\.
        $profilesDir = Join-Path $root 'Profiles'
        if (Test-Path $profilesDir) {
            $p = Get-ChildItem $profilesDir -Directory -ErrorAction SilentlyContinue |
                 Where-Object { $_.Name -like '*.default-release' } |
                 Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($p) { return $p.FullName }
        }
    }
    return $null
}

# Repo chrome\ dir, resolved relative to this script (scripts\ -> ..\chrome).
$repoRoot       = Split-Path -Parent $PSScriptRoot
$sourceChrome   = Join-Path $repoRoot 'chrome'
$sourcePostbird = Join-Path $sourceChrome 'postbird'
$sourceLoader   = Join-Path $sourceChrome 'userChrome.css'
$sourceContent  = Join-Path $sourceChrome 'userContent.css'

if (-not (Test-Path $sourceLoader)) {
    throw "Loader not found: $sourceLoader (run from the postbird repo)."
}

if (-not $ProfilePath) {
    $ProfilePath = Resolve-MailProfile
    if (-not $ProfilePath) {
        throw "Could not auto-detect a Betterbird/Thunderbird profile. Pass -ProfilePath explicitly."
    }
    Write-Host "Auto-detected profile: $ProfilePath" -ForegroundColor DarkGray
}
if (-not (Test-Path $ProfilePath)) {
    throw "Profile not found: $ProfilePath"
}

$destChrome   = Join-Path $ProfilePath 'chrome'
$destPostbird = Join-Path $destChrome 'postbird'
New-Item -ItemType Directory -Force -Path $destChrome | Out-Null

if ($Link) {
    if (Test-Path $destPostbird) { Remove-Item $destPostbird -Recurse -Force }
    New-Item -ItemType Junction -Path $destPostbird -Target $sourcePostbird | Out-Null
    Write-Host "Junction: $destPostbird -> $sourcePostbird" -ForegroundColor Cyan
} else {
    # /MIR mirrors the isolated postbird subtree (safe: nothing else lives there).
    & robocopy $sourcePostbird $destPostbird /MIR /NJH /NJS /NDL /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed (exit $LASTEXITCODE)." }
    Write-Host "Copied chrome\postbird -> $destPostbird" -ForegroundColor Cyan
}

Copy-Item $sourceLoader (Join-Path $destChrome 'userChrome.css') -Force
Write-Host "Copied userChrome.css -> $destChrome" -ForegroundColor Cyan

if (Test-Path $sourceContent) {
    Copy-Item $sourceContent (Join-Path $destChrome 'userContent.css') -Force
    Write-Host "Copied userContent.css -> $destChrome" -ForegroundColor Cyan
}

Write-Host ''
Write-Host '  Deploy complete. RESTART Betterbird for changes to load.' -ForegroundColor Yellow
Write-Host '  (userChrome.css / userContent.css are only read at startup.)' -ForegroundColor Yellow
Write-Host '  One-time pref, if not set: toolkit.legacyUserProfileCustomizations.stylesheets = true' -ForegroundColor DarkGray
