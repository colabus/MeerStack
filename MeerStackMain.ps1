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

function Write-Log {
    param (
        [string]$Component,
        [xml]$XmlData
    )

    $xmlString = $XmlData.OuterXml

    $line = "$xmlString"

    $dateStamp = Get-Date -Format "yyyyMMddHHmmss"

    $logFile = Join-Path $config.LocalLogPath "$Component-$dateStamp.log"

    # Ensure the directory exists
    $logDir = Split-Path -Path $logFile -Parent
    if (-not (Test-Path -Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    Add-Content -Path $logFile -Value $line
}

Check-CPU($config)
Check-Memory($config)
Check-Services($config)
Check-Certificates($config)
Check-Disks($config)