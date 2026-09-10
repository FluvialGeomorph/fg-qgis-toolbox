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
Assert-Rejected { param($x) $x.script_name = '../unexpected.rsx' } 'Invalid saved Study Area trial contract'
Assert-Rejected { param($x) $x.input_sha256 = ('0' * 64) } 'Trial dependency changed'
Assert-Rejected { param($x) $x.input_files = [pscustomobject]@{ '../outside' = ('0' * 64) } } 'Input path escapes trial folder'
Assert-Rejected { param($x) $x.input_files = $null } 'Invalid saved Study Area trial contract'
Assert-Rejected { param($x)
    $key = @($x.input_files.PSObject.Properties)[0].Name
    $x.input_files.$key = ('0' * 64)
} 'Trial dependency changed'
if ((Get-FileHash -LiteralPath $manifestPath).Hash -ne $originalHash) { throw 'Test modified the manifest.' }
Write-Output 'PASS: valid preflight and six refusal checks; no QGIS process started.'
