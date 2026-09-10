<#
Launch only an already-qualified local trial. No installation or profile migration.
Run with -TrialDirectory <output root from --prepare-desktop-trial>.
Use -CheckOnly for read-only launch checks. The visible QGIS window is for the analyst.
#>
param(
    [Parameter(Mandatory = $true)][string]$TrialDirectory,
    [switch]$CheckOnly
)
$ErrorActionPreference = 'Stop'
$trialRoot = (Resolve-Path -LiteralPath $TrialDirectory).Path
$trial = Get-Content -LiteralPath (Join-Path $trialRoot 'trial.json') -Raw | ConvertFrom-Json
if ($trial.schema_version -notin @(1, 2) -or $trial.status -ne 'prepared-not-analyst-qualified' -or
    [IO.Path]::GetFullPath($trial.root) -ne $trialRoot) { throw 'Invalid or relocated trial; prepare a new one.' }
$profileRoot = Join-Path $trialRoot 'profile'
if ([IO.Path]::GetFullPath($trial.profiles_path) -ne $profileRoot -or $trial.profile_name -ne 'default') {
    throw 'Profile is not the isolated trial profile.'
}
function Assert-TrialHash([string]$Path, [string]$Expected) {
    if ((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $Expected) {
        throw "Trial dependency changed: $Path. Requalify before launching."
    }
}
Assert-TrialHash $trial.input $trial.input_sha256
Assert-TrialHash (Join-Path $trial.osgeo 'share/proj/proj.db') $trial.proj_sha256
$scriptName = 'fg_review_stream_network.rsx'
$toolName = 'Review Stream Network GeoPackage (experimental)'
if ($trial.schema_version -eq 2) {
    if ($trial.algorithm -ne 'r:fgreviewstudyarea' -or $trial.script_name -ne 'fg_review_study_area.rsx' -or
        !$trial.input_files -or @($trial.input_files.PSObject.Properties).Count -eq 0) {
        throw 'Invalid saved Study Area trial contract.'
    }
    $scriptName = $trial.script_name
    $toolName = 'Review Saved Study Area (experimental)'
    $coveredInput = $false
    foreach ($entry in $trial.input_files.PSObject.Properties) {
        $inputFile = [IO.Path]::GetFullPath((Join-Path $trialRoot $entry.Name))
        if (!$inputFile.StartsWith($trialRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Input path escapes trial folder.'
        }
        Assert-TrialHash $inputFile $entry.Value
        if ($inputFile -eq [IO.Path]::GetFullPath($trial.input)) { $coveredInput = $true }
    }
    if (!$coveredInput) { throw 'Study context is absent from the trial input inventory.' }
}
Assert-TrialHash (Join-Path $trial.r_library "fgqgis/rscripts/$scriptName") $trial.script_sha256
$pluginRoot = Join-Path $profileRoot 'profiles/default/python/plugins'
foreach ($entry in $trial.plugin_files.PSObject.Properties) {
    $pluginFile = [IO.Path]::GetFullPath((Join-Path $pluginRoot $entry.Name))
    if (!$pluginFile.StartsWith($pluginRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Plugin path escapes trial profile.'
    }
    Assert-TrialHash $pluginFile $entry.Value
}
$launcher = Join-Path $trial.osgeo 'bin/qgis-ltr.bat'
$pandocFolder = Join-Path $env:LOCALAPPDATA 'Programs/Positron/resources/app/quarto/bin/tools'
foreach ($required in @($launcher, (Join-Path $trial.r_home 'bin/Rscript.exe'),
    (Join-Path $pandocFolder 'pandoc.exe'), (Join-Path $profileRoot 'profiles/default/QGIS/QGIS3.ini'))) {
    if (!(Test-Path -LiteralPath $required -PathType Leaf)) { throw "Required trial dependency is absent: $required" }
}
Write-Output "Tool: $toolName"
Write-Output "Input: $($trial.input)"
Write-Output "New report destination: $($trial.suggested_output)"
if ($CheckOnly) { Write-Output 'Trial launch checks passed; no QGIS process started.'; return }
# A second instance could contend for the same profile and database handles.
if (Get-Process -Name 'qgis*' -ErrorAction SilentlyContinue) {
    throw 'Close existing QGIS windows before launching this controlled trial.'
}
$trialEnvironment = @{
    QGIS_CUSTOM_CONFIG_PATH = $profileRoot
    R_ENVIRON_USER = (Join-Path $trialRoot 'absent-Renviron')
    R_PROFILE_USER = (Join-Path $trialRoot 'absent-Rprofile')
    RSTUDIO_PANDOC = $pandocFolder
    LC_ALL = 'English_United States.utf8'
    LANG = 'English_United States.utf8'
    QT_QPA_PLATFORM = $null
}
$previousValues = @{}
try {
    foreach ($key in $trialEnvironment.Keys) {
        $previousValues[$key] = [Environment]::GetEnvironmentVariable($key, 'Process')
        [Environment]::SetEnvironmentVariable($key, $trialEnvironment[$key], 'Process')
    }
    # The installed batch launcher sets its own DLL paths; do not replace them with R's.
    & $launcher --profiles-path $profileRoot --profile default --nologo --noversioncheck
    if ($LASTEXITCODE -ne 0) { throw "QGIS launcher exited with $LASTEXITCODE" }
    Write-Output 'Trial launch requested. Confirm a visible QGIS window before continuing; process startup alone is not desktop qualification.'
    Write-Output "Trial input: $($trial.input)"
    Write-Output "New report destination: $($trial.suggested_output)"
} finally {
    foreach ($key in $previousValues.Keys) {
        [Environment]::SetEnvironmentVariable($key, $previousValues[$key], 'Process')
    }
}
