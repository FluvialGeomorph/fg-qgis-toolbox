# Read-only preflight tests. Invalid manifests are supplied in memory; saved
# trial manifests, source files, profiles and installed dependencies are unchanged.
param([Parameter(Mandatory = $true)][string]$TrialDirectory)
$ErrorActionPreference = 'Stop'
$launcher = Join-Path $PSScriptRoot 'start-qgis-trial.ps1'
$manifestPath = Join-Path (Resolve-Path -LiteralPath $TrialDirectory).Path 'trial.json'
$originalText = Get-Content -LiteralPath $manifestPath -Raw
$originalHash = (Get-FileHash -LiteralPath $manifestPath).Hash
& $launcher -TrialDirectory $TrialDirectory -CheckOnly
function Assert-Rejected([scriptblock]$Mutation, [string]$Expected) {
    $candidate = $originalText | ConvertFrom-Json
    & $Mutation $candidate
    # Scoped command override affects this invocation only; never rewrite the
    # actual manifest to test refusal behavior.
    function Get-Content {
        param([string]$LiteralPath, [switch]$Raw)
        if ($LiteralPath -ne $manifestPath -or !$Raw) { throw 'Unexpected manifest read in test.' }
        $candidate | ConvertTo-Json -Depth 10
    }
    $message = $null
    try { & $launcher -TrialDirectory $TrialDirectory -CheckOnly | Out-Null }
    catch { $message = $_.Exception.Message }
    if (!$message -or $message -notlike "*$Expected*") {
        throw "Expected rejection '$Expected'; got '$message'."
    }
    Write-Output "Rejected as expected: $Expected"
}
Assert-Rejected { param($x) $x.schema_version = 99 } 'Invalid or relocated trial'
if (($originalText | ConvertFrom-Json).schema_version -eq 4) {
    Assert-Rejected { param($x) $x.script_name = '../unexpected.rsx' } 'Invalid new Study Area trial contract'
    Assert-Rejected { param($x) $x.algorithm = 'r:fgrevisestudyarea' } 'Invalid new Study Area trial contract'
    Assert-Rejected { param($x) $x.provider = '4.1.0-fg-cancel1' } 'Invalid new Study Area trial contract'
    Assert-Rejected { param($x) $x | Add-Member input 'unexpected.gpkg' } 'Invalid new Study Area trial contract'
    Assert-Rejected { param($x) $x.suggested_context = $null } 'New-study destination is required'
    Assert-Rejected { param($x) $x.suggested_context = Join-Path (Split-Path $x.root) 'outside.gpkg' } 'New-study destination must'
    Assert-Rejected { param($x) $x.suggested_context = $x.suggested_output } 'New-study destination must'
    Assert-Rejected { param($x) $x.suggested_output = Join-Path $x.root 'absent/report.html' } 'New-study destination must'
    Assert-Rejected { param($x) $x.suggested_output = Join-Path $x.root 'define study area.html' } 'New-study destination already exists'
    Assert-Rejected { param($x) $x.script_sha256 = ('0' * 64) } 'Trial dependency changed'
    Assert-Rejected { param($x) $x.proj_sha256 = ('0' * 64) } 'Trial dependency changed'
    if ((Get-FileHash -LiteralPath $manifestPath).Hash -ne $originalHash) { throw 'Test modified the manifest.' }
    Write-Output 'PASS: valid new-study preflight and 12 refusal checks; no QGIS process started.'
    return
}
Assert-Rejected { param($x) $x.script_name = '../unexpected.rsx' } 'Invalid saved Study Area trial contract'
Assert-Rejected { param($x) $x.input_sha256 = ('0' * 64) } 'Trial dependency changed'
Assert-Rejected { param($x) $x.input_files = [pscustomobject]@{ '../outside' = ('0' * 64) } } 'Input path escapes trial folder'
Assert-Rejected { param($x) $x.input_files = $null } 'Invalid saved Study Area trial contract'
Assert-Rejected { param($x)
    $key = @($x.input_files.PSObject.Properties)[0].Name
    $x.input_files.$key = ('0' * 64)
} 'Trial dependency changed'
$count = 6
if (($originalText | ConvertFrom-Json).schema_version -eq 3) {
    Assert-Rejected { param($x) $x.provider = '4.1.0-fg-cancel1' } 'Editing trial requires'
    Assert-Rejected { param($x) $x.suggested_context = $null } 'Editing trial requires'
    Assert-Rejected { param($x) $x.suggested_context = $x.input } 'Revised context destination must'
    Assert-Rejected { param($x) $x.suggested_context = Join-Path $x.root 'outside-input-folder.gpkg' } 'Revised context destination must'
    Assert-Rejected { param($x) $x.suggested_context = [IO.Path]::ChangeExtension($x.input, '.html') } 'Revised context destination must'
    Assert-Rejected { param($x) $x.algorithm = 'r:fgreviewstudyarea' } 'Invalid saved Study Area trial contract'
    $count += 6
}
if ((Get-FileHash -LiteralPath $manifestPath).Hash -ne $originalHash) { throw 'Test modified the manifest.' }
Write-Output "PASS: valid preflight and $count refusal checks; no QGIS process started."
