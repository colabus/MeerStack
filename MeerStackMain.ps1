CD $PSScriptRoot

$connectionString = "Server=Nick-PC;Database=MeerStack;Integrated Security=True;"

. ".\MeerStackVariables.ps1"

. ".\MeerStackMethods.ps1"

. ".\MeerStackConfig.ps1"

. ".\MeerStackModules.ps1"

$lastRun = @{}

$logFile = Join-Path $config.LocalPath "MeerStack.log"
$zipFile = Join-Path $config.LocalPath "MeerStack.zip"

if (Test-Path $logFile) {
    try {
        if (Test-Path $zipFile) {
            MeerStack-Log -Status "INFO" -Message "[Main] Deleting old compressed log file .."
            Remove-Item $zipFile -Force
        }
        MeerStack-Log -Status "INFO" -Message "[Main] Rotating log file (compress/delete) .."

        Compress-Archive -Path $logFile -DestinationPath $zipFile -Force
        Remove-Item $logFile -Force
    }
    catch {
        MeerStack-Log -Status "ERROR" -Message "[Main] Failed to compress/delete $($logFile): $_"
    }
}

MeerStack-Log -Status "INFO " -Message "[Main] MeerStack Starting - Chirrup! .."

if ($debug) { Write-Host -ForegroundColor Red "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | [Debug] Mode: ON" }

while ($true) {
    $now = Get-Date

    if ($debug) {
        Write-Host -ForegroundColor Yellow "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | [Debug] LastRun variable array:"
        $lastRun | ConvertTo-Json -Depth 10 | Out-String

        Write-Host -ForegroundColor Yellow "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | [Debug] Config variable array:"
        $config | ConvertTo-Json -Depth 10 | Out-String
    }

    # Heartbeat
    $interval = $config.HeartbeatInterval
    $last = $lastRun['Heartbeat']

    if (-not $last -or ($now - $last).TotalSeconds -ge $interval) {

        try {
            MeerStack-Log -Status "INFO " -Message "[Main] Calling.. Heartbeat .."

            Heartbeat
            
            $lastRun['Heartbeat'] = $now
        } catch {
            MeerStack-Log -Status "ERROR" -Message "[Main] Error running Heartbeat: $_"
        }
    }

    # Checks
    foreach ($check in $config.Checks.Keys) {
        $checkConfig = $config.Checks[$check]

        if (-not $checkConfig.Enabled) {
            continue
        }

        $interval = $checkConfig.Interval
        $last = $lastRun[$check]

        if (-not $last -or ($now - $last).TotalSeconds -ge $interval) {
            $functionName = "Check-$check"
            
            if (Get-Command $functionName -ErrorAction SilentlyContinue) {
                try {
                    MeerStack-Log -Status "INFO " -Message "[Main] Calling.. $functionName .."

                    & $functionName $config
                    $lastRun[$check] = $now
                } catch {
                    MeerStack-Log -Status "ERROR" -Message "[Main] Error running $($functionName): $_"
                }
            } else {
                MeerStack-Log -Status "ERROR" -Message "[Main] Check function '$functionName' not found."
            }
        }
    }

    # Process Logs
    Process-Logs($config)

    # Configuration
    $last = $lastRun['Configuration']

    if (-not $last -or ($now - $last).TotalSeconds -ge $config.Configuration.Interval) {
        try {
            MeerStack-Log -Status "INFO " -Message "[Main] Refreshing config .."

            MeerStack-Configuration

            $lastRun['Configuration'] = $now
        } catch {
            MeerStack-Log -Status "ERROR" -Message "[Main] Error running MeerStack-Configuration: $_"
        }
    }

    MeerStack-Log -Status "INFO " -Message "[Main] MeerStack is snoozing - Zzz .."

    Start-Sleep -Seconds (Get-Random -Minimum 60 -Maximum 120)
}
