# MeerStack Core Methods

function MeerStack-ConnectionInfo {
    [CmdletBinding()]
    param(
        [string]$ConfigurationFile  = 'MeerStack.config.json',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Server             = '',
        [string]$Database    = 'MeerStack'
    )
    $ConfigurationFile = Join-Path -Path $PSScriptRoot -ChildPath $ConfigurationFile

    $connectionString = New-Object System.Data.SqlClient.SqlConnectionStringBuilder

    $connectionString['Data Source'] = $Server
    $connectionString['Initial Catalog'] = $Database

    if (Test-Path $ConfigurationFile) {
        MeerStack-Log -Status "INFO " -Message "[ConnInfo] Configuration file present, loading.."

        $config = Get-Content -LiteralPath $ConfigurationFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop

        if ([string]::IsNullOrWhiteSpace($config.UserId) -or ([string]::IsNullOrWhiteSpace($config.DpapiPassword))) {
            MeerStack-Log -Status "ERROR" -Message "[ConnInfo] MeerStack.config.json missing all elements.."

            Exit 1
        }
        else {
            $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR( (ConvertTo-SecureString -string ([string]$config.DpapiPassword).ToString())))

            $connectionString['User Id'] = [string]$config.UserId
            $connectionString['Password'] = $password
        }
    }
    else {
        $connectionString['Integrated Security'] = $true
    }

    return $connectionString.connectionString
}

function MeerStack-Log {
    param (
        [string]$Status,
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp | $($Status.PadRight(5).Substring(0, 5)) | $Message"

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
            MeerStack-Log -Status "INFO" -Message "[Process-Logs] Processing $($file.Name)..."

            $payloads = @()

            if ($file.Name -match '^EventLogs') {
                # XML Payload
                $payloads += Get-Content -Path $file.FullName -Raw
            }
            else {
                # XML Payload per Line
                $payloads += Get-Content -Path $file.FullName | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
            }

            foreach ($payload in $payloads) {

                $sqlConn = New-Object System.Data.SqlClient.SqlConnection $connString

                try {
                    $sqlConn.Open()
                    $sqlCmd = $sqlConn.CreateCommand()
                    $sqlCmd.CommandText = "usp_Check_Log_Insert"
                    $sqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure

                    $sqlCmd.Parameters.Add("@Hostname", [System.Data.SqlDbType]::NVarChar, 50).Value = $hostName
                    $sqlCmd.Parameters.Add("@Filename", [System.Data.SqlDbType]::NVarChar, 50).Value = $file.Name
                    $sqlCmd.Parameters.Add("@Payload", [System.Data.SqlDbType]::Xml).Value = $payload

                    $null = $sqlCmd.ExecuteNonQuery()
                }
                catch {
                    MeerStack-Log -Status "ERROR" -Message "[Process-Logs] Failed payload insert in $($file.Name): $_"
                }
                finally {
                    if ($sqlConn.State -eq 'Open') { $sqlConn.Close() }
                    $sqlConn.Dispose()
                }
            }

            MeerStack-Log -Status "INFO" -Message "[Process-Logs] Deleting $($file.Name)..."
            Remove-Item $file.FullName -Force
        }
        catch {
            MeerStack-Log -Status "ERROR" -Message "[Process-Logs] Error processing $($file.Name): $_"
        }
    }
}
