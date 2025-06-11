<#
                      ,'''''-._
                     ;  ,.  <> `-._ 
                     ;  \'   _,--'"
                    ;      (
                    ; ,   ` \
                    ;, ,     \
                   ;    |    |
                   ; |, |    |\
                  ;  |  |    | \
                  |.-\ ,\    |\ :
                  |.- `. `-. | ||
                  :.-   `-. \ ';;
                   .- ,   \;;|
                   ;   ,  |  ,\
                   ; ,    ;    \
                  ;    , /`.  , )
               __,;,   ,'   \  ,|
         _,--''__,|   /      \  :
       ,'_,-''    | ,/        | :
      / /         | ;         ; |
     | |      __,-| |--..__,--| |---.--....___
___,-| |----''    / |         `._`-.          `----
      \ \        `"""             """      --
       `.`.                 --'
         `.`-._        _,             ,-     __,-
            `-.`.
   --'         `;     MeerStack by colabus & jizz

#>


CD "C:\Users\Nick Claridge\OneDrive\GitHub\MeerStack"

$debug = 1

. ".\MeerStackConfig.ps1"

. ".\MeerStackModules.ps1"

. ".\MeerStackMethods.ps1"

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

    Start-Sleep -Seconds 5
}

<#
Check-CPU($config)
Check-Memory($config)
Check-Services($config)
Check-Certificates($config)
Check-Disks($config)
#>