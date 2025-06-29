$scriptVersion = "20250616.2"

$config = @{
    Checks = @{ }

    Database = @{
        ConnectionString = $connectionString
    }

    Configuration = @{ Interval = 60 }

    LocalPath = "C:\MeerStack"
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
            $config.Checks["CPU"] = @{
                Enabled  = ($reader["Cpu"] -eq $true)
                Interval = [int]$reader["CpuInterval"]
            }

            $config.Checks["Memory"] = @{
                Enabled  = ($reader["Memory"] -eq $true)
                Interval = [int]$reader["MemoryInterval"]
            }

            $config.Checks["Services"] = @{
                Enabled         = ($reader["Services"] -eq $true)
                Interval        = [int]$reader["ServicesInterval"]
                ServicesToCheck = if ($reader["ServicesToCheck"]) {
                    $reader["ServicesToCheck"] -split '[,;]' | ForEach-Object { $_.Trim() }
                } else {
                    @()
                }
                Verbose         = ($reader["ServicesVerbose"] -eq $true)
            }

            $config.Checks["Disks"] = @{
                Enabled  = ($reader["Disks"] -eq $true)
                Interval = [int]$reader["DisksInterval"]
            }

            $config.Checks["Certificates"] = @{
                Enabled  = ($reader["Certificates"] -eq $true)
                Interval = [int]$reader["CertificatesInterval"]
            }

            $config.Checks["EventLogs"] = @{
                Enabled  = ($reader["EventLogs"] -eq $true)
                Interval = [int]$reader["EventLogsInterval"]
                XmlFilter = [string]$reader["EventLogsXmlFilter"]
                LastUpdated = [DateTime]$reader["EventLogsLastUpdated"]
            }

            $config.Checks["Sessions"] = @{
                Enabled  = ($reader["Sessions"] -eq $true)
                Interval = [int]$reader["SessionsInterval"]
            }

            $config.Checks["Processes"] = @{
                Enabled  = ($reader["Processes"] -eq $true)
                Interval = [int]$reader["ProcessesInterval"]
            }

            $config.ScriptVersion = $reader["ScriptVersion"]

            MeerStack-Log -Status "INFO " -Message "[Config] Loaded configuration for $hostname.."

            if ($scriptVersion -ne $config.ScriptVersion)
            {
                MeerStack-Log -Status "ERROR" -Message "[Config] Script version mismatches database version.."

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
