$ErrorActionPreference = 'Stop'
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    & "$PSScriptRoot\dart.ps1" run build_runner build
    if ($LASTEXITCODE -ne 0) { throw 'Drift generation failed.' }
    $stagingPath = Join-Path (Get-Location).Path ('build\schema-export-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $stagingPath -Force | Out-Null
    try {
        & "$PSScriptRoot\dart.ps1" run drift_dev schema dump lib/core/database/app_database.dart $stagingPath
        if ($LASTEXITCODE -ne 0) { throw 'Schema export failed.' }
        $snapshots = @(Get-ChildItem -LiteralPath $stagingPath -File -Filter 'drift_schema_v*.json')
        if ($snapshots.Count -ne 1) { throw 'Expected exactly one exported schema.' }
        $destination = Join-Path 'drift_schemas\momentum' $snapshots[0].Name
        if (Test-Path -LiteralPath $destination) {
            $existing = (Get-Content -LiteralPath $destination -Raw).Replace("`r`n", "`n").Trim()
            $generated = (Get-Content -LiteralPath $snapshots[0].FullName -Raw).Replace("`r`n", "`n").Trim()
            if ($existing -cne $generated) {
                throw 'Frozen schema changed. Increment schemaVersion and implement/test an explicit migration; do not replace the old snapshot.'
            }
            Write-Output 'Frozen schema matches the generated database.'
        } else {
            Copy-Item -LiteralPath $snapshots[0].FullName -Destination $destination
            Write-Output "Created new snapshot: $destination"
        }
    } finally {
        # Only the one generated file and its now-empty directory; never recursive.
        foreach ($snapshot in @(Get-ChildItem -LiteralPath $stagingPath -File -Filter 'drift_schema_v*.json')) {
            Remove-Item -LiteralPath $snapshot.FullName
        }
        Remove-Item -LiteralPath $stagingPath
    }
} finally {
    Pop-Location
}
