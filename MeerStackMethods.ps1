function Check-Log {
    param (
        [string]$Component,
        [xml]$XmlData
    )

    $xmlString = $XmlData.OuterXml

    $line = "$xmlString"

    $dateStamp = Get-Date -Format "yyyyMMddHHmmss"

    $localLogPath = $config.LocalPath + "\Logs"

    $logFile = Join-Path $localLogPath "$Component-$dateStamp.log"

    # Ensure the directory exists
    $logDir = Split-Path -Path $logFile -Parent
    if (-not (Test-Path -Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    Add-Content -Path $logFile -Value $line
}

function MeerStack-Log {
    param (
        [string]$Status,
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp | $Status | $Message"

    $logFile = Join-Path $config.LocalPath "MeerStack.log"

    if (-not (Test-Path -Path $config.LocalPath)) {
        New-Item -Path $config.LocalPath -ItemType Directory -Force | Out-Null
    }

    Add-Content -Path $logFile -Value $line
}