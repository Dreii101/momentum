param([int]$Runs = 3)
$ErrorActionPreference = 'Stop'
$project = Split-Path $PSScriptRoot -Parent
$exe = (Resolve-Path (Join-Path $project 'build/windows/x64/runner/Release/momentum.exe')).Path
$directory = Join-Path $env:APPDATA 'dev.momentum/momentum/phase13_performance'
$results = @()
for ($run = 1; $run -le $Runs; $run++) {
    $started = [DateTime]::UtcNow
    $app = Start-Process -FilePath $exe -WorkingDirectory (Split-Path $exe) -WindowStyle Hidden -PassThru
    try {
        $result = Join-Path $directory ('result-' + $app.Id + '.json')
        $deadline = [DateTime]::UtcNow.AddSeconds(40)
        while (-not (Test-Path -LiteralPath $result) -and [DateTime]::UtcNow -lt $deadline -and -not $app.HasExited) {
            Start-Sleep -Milliseconds 100
            $app.Refresh()
        }
        if (-not (Test-Path -LiteralPath $result)) { throw "No benchmark report for PID $($app.Id). Build performance_app.dart first." }
        $r = Get-Content -LiteralPath $result -Raw | ConvertFrom-Json
        if ($r.seededThisRun -or $r.buildMode -ne 'release' -or $r.tasks -ne 1000 -or $r.notes -ne 250) {
            throw 'Prepare the reference dataset once before measuring existing-data release startup.'
        }
        $ready = if ($r.readyUtc -is [DateTime]) { $r.readyUtc.ToUniversalTime() } else { [DateTime]::Parse($r.readyUtc, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind) }
        $r | Add-Member processStartUtc $started.ToString('o')
        $r | Add-Member processToReadyMs ([math]::Round(($ready - $started).TotalMilliseconds, 2))
        $app.Refresh()
        $r | Add-Member workingSetMiB ([math]::Round($app.WorkingSet64 / 1MB, 1))
        $r | Add-Member freeHostGiB ([math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2))
        $results += $r
    } finally {
        $app.Refresh()
        if (-not $app.HasExited -and $app.Path -eq $exe) { Stop-Process -Id $app.Id }
    }
}
[ordered]@{
    observedUtc = [DateTime]::UtcNow.ToString('o')
    executableSha256 = (Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash.ToLowerInvariant()
    aotSha256 = (Get-FileHash -LiteralPath (Join-Path (Split-Path $exe) 'data/app.so') -Algorithm SHA256).Hash.ToLowerInvariant()
    runs = $results
} | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $project 'docs/evidence/phase13-performance.json')
$results | Select-Object pid, processToReadyMs, searchFirstMs, searchWarmP95Ms, workingSetMiB, freeHostGiB
