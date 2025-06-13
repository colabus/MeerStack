CD "C:\Users\Nick Claridge\OneDrive\GitHub\MeerStack"

. ".\MeerStackMethods.ps1"

. ".\MeerStackConfig.ps1"

. ".\MeerStackModules.ps1"

$lastRun = @{}

while ($true) {
    $now = Get-Date

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

    Process-Logs($config)

    $now = Get-Date
    $last = $lastRun['Configuration']

    if (-not $last -or ($now - $last).TotalSeconds -ge $config.Configuration.Interval) {
        MeerStack-Log -Status "INFO " -Message "[Main] Refreshing config .."

        MeerStack-Configuration

        $lastRun['Configuration'] = $now
    }

    Start-Sleep -Seconds 5
}
