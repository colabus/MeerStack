$config = @{
    Checks = @{ }

    Database = @{
        ConnectionString = "Server=Nick-PC;Database=MeerStack;Integrated Security=True;"
    }

    LocalPath = "C:\MeerStack"
}

try {
    $hostName = [System.Net.Dns]::GetHostName()

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
        }

        MeerStack-Log -Status "INFO " -Message "[Main] Loaded configuration for $hostname.."
    }
    else {
        MeerStack-Log -Status "ERROR" -Message "[Main] Failed to load configuration for $hostname.."

        Exit 1
    }

    $sqlConnection.Close()
}
catch {
    MeerStack-Log -Status "ERROR" -Message "[Main] Failed to load configuration: $_"

    exit 1
}