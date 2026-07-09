<#
.SYNOPSIS
    Apply postbird's recommended Betterbird prefs to a profile.

.DESCRIPTION
    Writes a managed block into <profile>\user.js with the settings postbird
    expects. Betterbird reads user.js at startup and copies the values into
    prefs.js. Restart Betterbird after running.

    Prefs set:
      toolkit.legacyUserProfileCustomizations.stylesheets = true  (load userChrome/Content)
      mail.pane_config.dynamic            = 2   (message-pane layout, see below)
      mail.threadpane.listview            = 0   (0 = Cards view, 1 = Table)
      mail.threadpane.cardsview.rowcount  = 2   (2-line cards)

    mail.pane_config.dynamic values:
      0 Classic | 1 Wide | 2 Vertical (message pane on the RIGHT, Postbox-like)
      3 Wide-Thread | 4 Stacked | 5 Horizontal (message pane at the BOTTOM)
    Edit $Prefs below to change the layout.

    NOTE: while the managed block is present, these prefs are re-applied every
    startup (you can't change them persistently in the UI). To "unlock" them,
    launch once (so they land in prefs.js), then re-run with -Remove.

.PARAMETER ProfilePath
    Explicit profile directory. If omitted, auto-detected (same logic as deploy.ps1).

.PARAMETER Remove
    Remove postbird's managed block from user.js instead of writing it.

.EXAMPLE
    .\scripts\configure-prefs.ps1
.EXAMPLE
    .\scripts\configure-prefs.ps1 -ProfilePath 'C:\...\Profiles\xxxx.screenshots'
#>
[CmdletBinding()]
param(
    [string] $ProfilePath,
    [switch] $Remove
)

$ErrorActionPreference = 'Stop'

# Recommended prefs (edit values here). Format: name = value (bool/int).
$Prefs = [ordered]@{
    'toolkit.legacyUserProfileCustomizations.stylesheets' = $true
    'mail.pane_config.dynamic'                            = 2      # Vertical (message pane on the right)
    'mail.pane_config.multiline_all'                      = $true  # multi-line rows in all views
    'mail.threadpane.listview'                            = 0      # Cards view
    'mail.threadpane.cardsview.rowcount'                  = 2      # 2-line cards
    'toolbar.unifiedtoolbar.buttonstyle'                  = 1      # toolbar buttons: icons-above-text
    'mailnews.default_view_flags'                         = 1      # threaded view
    'mail.ui.display.dateformat.always_show_time'         = $true  # show time in the date column
}

$BEGIN = '// >>> postbird recommended prefs (managed - do not edit inside) >>>'
$END   = '// <<< postbird recommended prefs (managed) <<<'

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

if (-not $ProfilePath) {
    $ProfilePath = Resolve-MailProfile
    if (-not $ProfilePath) { throw "Could not auto-detect a profile. Pass -ProfilePath." }
    Write-Host "Auto-detected profile: $ProfilePath" -ForegroundColor DarkGray
}
if (-not (Test-Path $ProfilePath)) { throw "Profile not found: $ProfilePath" }

$userJs = Join-Path $ProfilePath 'user.js'
$existing = (Test-Path $userJs) ? (Get-Content $userJs -Raw) : ''

# Strip any previous managed block (keeps the user's other prefs intact).
$pattern = [regex]::Escape($BEGIN) + '.*?' + [regex]::Escape($END) + '\r?\n?'
$cleaned = [regex]::Replace($existing, $pattern, '', 'Singleline').TrimEnd()

if ($Remove) {
    if ($cleaned) { Set-Content $userJs ($cleaned + "`r`n") -Encoding UTF8 }
    elseif (Test-Path $userJs) { Remove-Item $userJs }
    Write-Host "Removed postbird's managed prefs block from user.js." -ForegroundColor Yellow
    Write-Host "Values already copied into prefs.js on a prior launch remain (now editable)."
    return
}

$lines = foreach ($k in $Prefs.Keys) {
    $v = $Prefs[$k]
    $val = ($v -is [bool]) ? ($v.ToString().ToLower()) : $v
    "user_pref(`"$k`", $val);"
}
$block = @($BEGIN) + $lines + @($END) -join "`r`n"
$content = ($cleaned ? ($cleaned + "`r`n`r`n") : '') + $block + "`r`n"
Set-Content $userJs $content -Encoding UTF8

Write-Host "Wrote postbird prefs to: $userJs" -ForegroundColor Cyan
$Prefs.GetEnumerator() | ForEach-Object { Write-Host ("  {0} = {1}" -f $_.Key, $_.Value) }
Write-Host ''
Write-Host '  RESTART Betterbird for these to take effect.' -ForegroundColor Yellow
Write-Host '  Layout too "horizontal"? Set mail.pane_config.dynamic = 2 (Vertical = message on the right).' -ForegroundColor DarkGray
