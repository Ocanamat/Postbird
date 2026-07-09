<#
.SYNOPSIS
    Deploy postbird into a Betterbird (or Thunderbird) profile — one command.

.DESCRIPTION
    Does everything a fresh install needs:
      1. Copies the CSS (chrome\postbird\, userChrome.css, userContent.css).
      2. Applies recommended prefs   (calls configure-prefs.ps1 -> user.js).
      3. Applies recommended layout   (calls configure-xulstore.ps1 -> XULStore),
         but only if Betterbird is CLOSED (it rewrites that file on exit); if it
         is running, this step is skipped with a note.
    Only files/settings postbird owns are touched. Restart the app afterwards.

    Skip parts with -SkipPrefs / -SkipLayout (e.g. CSS-only: both).

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
    [switch] $Link,
    [switch] $SkipPrefs,    # don't apply recommended prefs (user.js)
    [switch] $SkipLayout    # don't apply recommended layout (XULStore)
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

# --- Recommended prefs (user.js) — safe while the app is open (read at startup). ---
if (-not $SkipPrefs) {
    & (Join-Path $PSScriptRoot 'configure-prefs.ps1') -ProfilePath $ProfilePath
}

# --- Recommended layout (XULStore) — needs the app CLOSED (it rewrites the file
# on exit). If it's running, skip with a note rather than failing the deploy. ---
if (-not $SkipLayout) {
    $running = Get-Process -Name 'betterbird', 'thunderbird' -ErrorAction SilentlyContinue
    if ($running) {
        Write-Host ''
        Write-Host '  NOTE: layout settings (toolbar/folder modes/header) were NOT applied' -ForegroundColor Yellow
        Write-Host '  because Betterbird is running. Fully close it, then re-run deploy.ps1' -ForegroundColor Yellow
        Write-Host '  (or run scripts\configure-xulstore.ps1) to apply them.' -ForegroundColor Yellow
    } else {
        & (Join-Path $PSScriptRoot 'configure-xulstore.ps1') -ProfilePath $ProfilePath
    }
}

Write-Host ''
Write-Host '  Deploy complete. RESTART Betterbird for changes to load.' -ForegroundColor Yellow
Write-Host '  (userChrome.css / userContent.css are only read at startup.)' -ForegroundColor Yellow
Write-Host '  One-time pref, if not set: toolkit.legacyUserProfileCustomizations.stylesheets = true' -ForegroundColor DarkGray
