CD "C:\Users\Nick Claridge\OneDrive\GitHub\MeerStack"

$debug = 1

. ".\MeerStackConfig.ps1"

. ".\Modules\Cpu.ps1"
. ".\Modules\Memory.ps1"
. ".\Modules\Services.ps1"

function Write-Log {
    param (
        [string]$Component,
        [xml]$XmlData
    )

    $xmlString = $XmlData.OuterXml

    $line = "$xmlString"

    $logFile = Join-Path $config.LocalLogPath "$Component.log"

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