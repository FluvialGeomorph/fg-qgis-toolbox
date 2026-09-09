# Restore only audited differing files from the exact installed package version.
# Default is a read-only preflight. Explicit -Apply requires reviewed authority.
param(
    [Parameter(Mandatory=$true)][string]$Installation,
    [Parameter(Mandatory=$true)][string]$EvidenceDirectory,
    [switch]$Apply
)
$ErrorActionPreference = 'Stop'
$targetRoot = (Resolve-Path -LiteralPath $Installation).Path.TrimEnd('\','/')
$evidenceRoot = (Resolve-Path -LiteralPath $EvidenceDirectory).Path
$audit = Get-Content -LiteralPath (Join-Path $evidenceRoot 'audit.json') -Raw | ConvertFrom-Json
if ($targetRoot -ne $audit.installation) { throw 'Installation does not match the reviewed audit.' }
if (Get-Process '*qgis*' -ErrorAction SilentlyContinue) { throw 'Close QGIS before restoring its package data.' }
$inventory = Join-Path $targetRoot 'etc/setup/installed.db'
if ((Get-FileHash -LiteralPath $inventory -Algorithm SHA256).Hash -ne $audit.installed_db_sha256) {
    throw 'Package inventory has changed since the audit; audit again.'
}
$allowed = @('share/proj/CH', 'share/proj/ITRF2008', 'share/proj/ITRF2014',
             'share/proj/proj.db', 'share/proj/proj.ini', 'share/proj/projjson.schema.json')
$work = @()
foreach ($file in $audit.files) {
    if ($file.before_sha256 -eq $file.package_sha256) { continue }
    if ($file.path -notin $allowed) { throw "Unreviewed repair target: $($file.path)" }
    $destination = (Resolve-Path -LiteralPath (Join-Path $targetRoot $file.path)).Path
    if (-not $destination.StartsWith($targetRoot + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Target escapes the installation.'
    }
    if ((Get-Item -LiteralPath $destination).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw 'Refuse reparse-point target.'
    }
    $source = Join-Path $evidenceRoot ('package/' + $file.path)
    $backup = Join-Path $evidenceRoot ('before/' + $file.path)
    if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -ne $file.package_sha256 -or
        (Get-FileHash -LiteralPath $backup -Algorithm SHA256).Hash -ne $file.before_sha256 -or
        (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $file.before_sha256) {
        throw "File changed since audit: $($file.path)"
    }
    $work += [PSCustomObject]@{ path=$file.path; source=$source; destination=$destination;
        expected_sha256=$file.package_sha256; restored=$false }
}
if ($work.Count -ne 6) { throw 'Expected exactly the six reviewed differing files.' }
if (-not $Apply) { $work | Select-Object path,destination; return }
$resultPath = Join-Path $evidenceRoot 'restore-result.json'
if (Test-Path -LiteralPath $resultPath) { throw 'A repair result already exists; inspect it before proceeding.' }
try {
    foreach ($item in $work) {
        Copy-Item -LiteralPath $item.source -Destination $item.destination -Force
        if ((Get-FileHash -LiteralPath $item.destination -Algorithm SHA256).Hash -ne $item.expected_sha256) {
            throw "Read-back mismatch: $($item.path)"
        }
        $item.restored = $true
    }
    if ((Get-FileHash -LiteralPath $inventory -Algorithm SHA256).Hash -ne $audit.installed_db_sha256) {
        throw 'Unexpected package inventory change.'
    }
} finally {
    $work | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $resultPath -Encoding utf8
}
$work | Select-Object path,restored
