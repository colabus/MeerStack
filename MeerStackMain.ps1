CD $PSScriptRoot

$connectionString = "Server=Nick-PC;Database=MeerStack;Integrated Security=True;"

. ".\MeerStackVariables.ps1"

. ".\MeerStackMethods.ps1"

. ".\MeerStackConfig.ps1"

. ".\MeerStackModules.ps1"

$lastRun = @{}

while ($true) {
    $now = Get-Date

    # Heartbeat
    try {
        MeerStack-Log -Status "INFO " -Message "[Main] Calling.. Heartbeat .."

        Heartbeat
    } catch {
        MeerStack-Log -Status "ERROR" -Message "[Main] Error running Heartbeat: $_"
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

    Start-Sleep -Seconds 60
}
