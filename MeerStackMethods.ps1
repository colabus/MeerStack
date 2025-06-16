# MeerStack Core Methods

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

# MeerStack Checks Methods

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

# MeerStack Database Methods

function Process-Logs {
    param (
        [hashtable]$config
    )

    $logPath = Join-Path $config.LocalPath "\Logs"

    if (-not (Test-Path $logPath)) {
        MeerStack-Log -Status "ERROR" -Message "[Process-Logs] $logPath not found."
        return
    }

    $hostName = $m_hostName
    $connString = $config.Database.ConnectionString

    $logFiles = Get-ChildItem -Path $logPath -Filter *.log -File

    foreach ($file in $logFiles) {
        try {
            $lines = Get-Content -Path $file.FullName
            foreach ($line in $lines) {
                if ([string]::IsNullOrWhiteSpace($line)) { continue }

                MeerStack-Log -Status "INFO " -Message "[Process-Logs] Processing $($file.Name)..."

                $sqlConn = New-Object System.Data.SqlClient.SqlConnection $connString
                $sqlCmd = $sqlConn.CreateCommand()
                $sqlCmd.CommandText = "usp_Check_Log_Insert"
                $sqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure

                $sqlCmd.Parameters.Add("@Hostname", [System.Data.SqlDbType]::NVarChar, 50) | Out-Null
                $sqlCmd.Parameters["@Hostname"].Value = hostName

                $sqlCmd.Parameters.Add("@Filename", [System.Data.SqlDbType]::NVarChar, 50) | Out-Null
                $sqlCmd.Parameters["@Filename"].Value = $file.Name

                $sqlCmd.Parameters.Add("@Payload", [System.Data.SqlDbType]::Xml) | Out-Null
                $sqlCmd.Parameters["@Payload"].Value = $line

                $sqlConn.Open()
                $null = $sqlCmd.ExecuteNonQuery()
                $sqlConn.Close()
            }

            MeerStack-Log -Status "INFO " -Message "[Process-Logs] Deleting $($file.Name)..."
            Remove-Item $file.FullName -Force
        }
        catch {
            MeerStack-Log -Status "ERROR" -Message "Error processing $($file.Name): $_"
        }
    }
}