<#
.SYNOPSIS
    Apply postbird's recommended Betterbird *layout* settings (XULStore).

.DESCRIPTION
    Some Betterbird UI settings live in xulstore.json, not prefs: the unified
    toolbar layout, folder-pane modes, menu-bar auto-hide, quick-filter
    visibility, and message-header layout. This writes postbird's recommended
    values into that file.

    UNLIKE prefs (user.js), these are the LIVE state — after applying you can
    still change them in the UI and the change sticks. So this is "apply once".

    IMPORTANT: Betterbird/Thunderbird rewrites xulstore.json when it closes, so
    it MUST be fully closed while this runs. The script refuses to run if it's
    open (override with -Force at your own risk).

    Toolbar layout note: the ported mail toolbar keeps only NATIVE buttons +
    flexible spaces (addon-specific buttons from the source profile are dropped).

.PARAMETER ProfilePath
    Explicit profile directory. If omitted, auto-detected (like deploy.ps1).

.PARAMETER Force
    Apply even if Betterbird appears to be running (not recommended).

.EXAMPLE
    .\scripts\configure-xulstore.ps1 -ProfilePath 'C:\...\Profiles\xxxx.screenshots'
#>
[CmdletBinding()]
param(
    [string] $ProfilePath,
    [switch] $Force
)

$ErrorActionPreference = 'Stop'
$DOC = 'chrome://messenger/content/messenger.xhtml'

function Resolve-MailProfile {
    foreach ($appName in @('Betterbird', 'Thunderbird')) {
        $root = Join-Path $env:APPDATA $appName
        if (-not (Test-Path $root)) { continue }
        $iniPath = Join-Path $root 'profiles.ini'
        if (Test-Path $iniPath) {
            $default = (Get-Content $iniPath |
                Select-String -Pattern '^\s*Default\s*=\s*(.+\.default-release.*)$').Matches |
                ForEach-Object { $_.Groups[1].Value.Trim() } | Select-Object -First 1
            if ($default) {
                $candidate = Join-Path $root ($default -replace '/', '\')
                if (Test-Path $candidate) { return $candidate }
            }
        }
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

# --- Guard: the app must be closed (it rewrites xulstore.json on exit). ---
$running = Get-Process -Name 'betterbird', 'thunderbird' -ErrorAction SilentlyContinue
if ($running -and -not $Force) {
    throw "Betterbird/Thunderbird is running. Close it fully first (it overwrites xulstore.json on exit), then re-run. Use -Force to override."
}

if (-not $ProfilePath) {
    $ProfilePath = Resolve-MailProfile
    if (-not $ProfilePath) { throw "Could not auto-detect a profile. Pass -ProfilePath." }
    Write-Host "Auto-detected profile: $ProfilePath" -ForegroundColor DarkGray
}
if (-not (Test-Path $ProfilePath)) { throw "Profile not found: $ProfilePath" }

# --- Recommended values ---
# Mail toolbar: NATIVE buttons + flexible spaces only (addon buttons stripped).
$toolbarState = [ordered]@{
    mail     = @('get-messages','address-book','spacer','spacer','reply','reply-all',
                 'forward-inline','spacer','spacer','mark-as','tag-message','previous','next',
                 'spacer','spacer','archive','junk','delete','spacer','spacer','write-message',
                 'spacer','spacer','search-bar','throbber')
    calendar = @('synchronize','new-event','new-task','edit-event','delete-event')
    tasks    = @('synchronize','new-event','new-task','edit-event','delete-event')
    settings = @('get-messages','spacer','search-bar','spacer')
} | ConvertTo-Json -Compress -Depth 5

$headerLayout = [ordered]@{
    showAvatar = $true; showBigAvatar = $true; showFullAddress = $true
    hideLabels = $true; subjectLarge = $true; buttonStyle = 'only-icons'; collapsed = $false
} | ConvertTo-Json -Compress

# element -> attribute -> value (strings, as XULStore stores them)
$items = [ordered]@{
    'folderTree'      = @{ mode = 'favorite,all,tags' }
    'toolbar-menubar' = @{ autohide = 'true' }
    'quickFilterBar'  = @{ collapsed = 'true'; visible = 'false' }
    'unifiedToolbar'  = @{ state = $toolbarState }
    'messageHeader'   = @{ layout = $headerLayout }
}

# --- Merge into xulstore.json (preserve everything else) ---
$xulstore = Join-Path $ProfilePath 'xulstore.json'
$xs = (Test-Path $xulstore) ? (Get-Content $xulstore -Raw | ConvertFrom-Json -AsHashtable) : @{}
if (-not $xs.ContainsKey($DOC)) { $xs[$DOC] = @{} }
foreach ($el in $items.Keys) {
    if (-not $xs[$DOC].ContainsKey($el)) { $xs[$DOC][$el] = @{} }
    foreach ($attr in $items[$el].Keys) { $xs[$DOC][$el][$attr] = $items[$el][$attr] }
}

# Back up once, then write.
if (Test-Path $xulstore) { Copy-Item $xulstore "$xulstore.postbird-bak" -Force }
$xs | ConvertTo-Json -Depth 30 -Compress | Set-Content $xulstore -Encoding UTF8

Write-Host "Applied XULStore layout to: $xulstore" -ForegroundColor Cyan
$items.Keys | ForEach-Object { Write-Host "  $_" }
Write-Host "(backup: $xulstore.postbird-bak)" -ForegroundColor DarkGray
Write-Host ''
Write-Host '  START Betterbird to see it. These are live settings — you can still change them in the UI.' -ForegroundColor Yellow
