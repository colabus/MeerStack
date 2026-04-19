if ($debug) { Write-Host -ForegroundColor White "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | [Debug] Loading Config .." }

$scriptVersion = "20251118.1"
$connectionString = MeerStack-ConnectionInfo -Server $connectionServer

$config = @{
    Checks = @{ }

    Database = @{
        ConnectionString = $connectionString
    }

    Configuration = @{ Interval = 60 }

    LocalPath = "C:\MeerStack"
}

function Get-ReaderValue {
    param (
        [System.Data.SqlClient.SqlDataReader]$Reader,
        [string]$Column,
        $Default = $null
    )
    try {
        $ordinal = $Reader.GetOrdinal($Column)
    } catch {
        MeerStack-Log -Status "WARN " -Message "[Config] Column '$Column' not found in result set .."

        return $Default
    }
    if ($Reader.IsDBNull($ordinal)) {
        return $Default
    }

    return $Reader.GetValue($ordinal)
}

function MeerStack-Configuration {

    try {
        $config.Checks = @{ }

        $hostName = $m_hostName

        $connectionString = $config.Database.ConnectionString

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
        $sqlCommand = $sqlConnection.CreateCommand()
        $sqlCommand.CommandText = "usp_HostConfiguration_Get"
        $sqlCommand.CommandType = [System.Data.CommandType]::StoredProcedure

        $sqlCommand.Parameters.Add("@Hostname", [System.Data.SqlDbType]::VarChar, 50) | Out-Null
        $sqlCommand.Parameters["@Hostname"].Value = $hostName

        $sqlConnection.Open()
        $reader = $sqlCommand.ExecuteReader()

        if ($reader.Read()) {

            $config.HeartbeatInterval = [int](Get-ReaderValue -Reader $reader -Column "HeartbeatInterval" -Default 90)

            $config.Checks["CPU"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Cpu" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "CpuInterval" -Default 600)
            }

            $config.Checks["Memory"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Memory" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "MemoryInterval" -Default 1800)
            }

            $servicesToCheck = Get-ReaderValue -Reader $reader -Column "ServicesToCheck" -Default ""
            $config.Checks["Services"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Services" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "ServicesInterval" -Default 300)
                ServicesToCheck = if ($servicesToCheck) {
                    $servicesToCheck -split '[,;]' | ForEach-Object { $_.Trim() }
                } else {
                    @()
                }
                Verbose         = ((Get-ReaderValue -Reader $reader -Column "ServicesVerbose" -Default $false) -eq $true)
            }

            $config.Checks["Disks"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Disks" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "DisksInterval" -Default 14400)                 #  4-hours
            }
 
            $config.Checks["Certificates"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Certificates" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "CertificatesInterval" -Default 84600)          # 24-hours
            }
 
            $eventLogsLastUpdated = Get-ReaderValue -Reader $reader -Column "EventLogsLastUpdated" -Default $null
            $config.Checks["EventLogs"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "EventLogs" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "EventLogsInterval" -Default 600)               # 10-minutes
                XmlFilter       = [string](Get-ReaderValue -Reader $reader -Column "EventLogsXmlFilter"   -Default "")
                LastUpdated     = if ($null -ne $eventLogsLastUpdated) { [DateTime]$eventLogsLastUpdated } else { (Get-Date) }
            }
 
            $config.Checks["Sessions"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Sessions" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "SessionsInterval" -Default 300)                #  5-minutes
            }
 
            $config.Checks["Processes"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Processes" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "ProcessesInterval" -Default 300)               #  5-minutes
            }
 
            $config.Checks["Connections"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Connections" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "ConnectionsInterval" -Default 300)             #  5-minutes
            }

            $config.Checks["Software"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Software" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "SoftwareInterval" -Default 84600)              # 24-hours
            }

            $config.Checks["Shares"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Shares" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "SharesInterval" -Default 3600)                 # 60-minutes
            }

            $config.Checks["Tasks"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Tasks" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "TasksInterval" -Default 84600)                 # 24-hours
            }

            $config.Checks["Identities"] = @{
                Enabled         = ((Get-ReaderValue -Reader $reader -Column "Identities" -Default $false) -eq $true)
                Interval        = [int](Get-ReaderValue -Reader $reader -Column "IdentitiesInterval" -Default 84600)            # 24-hours
            }
 
            $config.DatabaseVersion = Get-ReaderValue -Reader $reader -Column "DatabaseVersion" -Default $null

            $config.MeerStackForceExit = Get-ReaderValue -Reader $reader -Column "MeerStackForceExit" -Default $null

            MeerStack-Log -Status "INFO " -Message "[Config] Loaded configuration for $hostname.."

            if ($databaseVersion -ne $config.DatabaseVersion)
            {
                MeerStack-Log -Status "ERROR" -Message "[Config] Script (Database) version $databaseVersion mismatches database version.. $($config.DatabaseVersion)"

                Exit 1
            }

            if ($null -ne $config.MeerStackForceExit -and [DateTime]$config.MeerStackForceExit -gt (Get-Date))
            {
                MeerStack-Log -Status "INFO " -Message "[Main] Forced exit triggered by database (Threshold Date: $($config.MeerStackForceExit.ToString("yyyy-MM-dd HH:mm:ss.fffffff"))) - terminating .."

                Exit 1
            }
        }
        else {
            MeerStack-Log -Status "ERROR" -Message "[Config] Failed to load configuration for $hostname.."

            Exit 1
        }

        $sqlConnection.Close()
    }
    catch {
        MeerStack-Log -Status "ERROR" -Message "[Config] Failed to load configuration: $_"

        exit 1
    }
}

MeerStack-Configuration
