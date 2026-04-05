function Check-Connections {
    param ($config)

    $hostname = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $Connections = netstat -ano 2>$null | Select-Object -Skip 4 | ForEach-Object {
        $parts = $_ -split "\s+" | Where-Object { $_ -ne "" }

        if ($parts[0] -eq "TCP") {
            [ordered]@{
                Protocol      = $parts[0]
                LocalAddress  = $parts[1]
                RemoteAddress = $parts[2]
                State         = $parts[3]
                PID           = $parts[4]
            }
        } elseif ($parts[0] -eq "UDP") {
            [ordered]@{
                Protocol      = $parts[0]
                LocalAddress  = $parts[1]
                RemoteAddress = $parts[2]
                PID           = $parts[3]
            }
        }
    }

    $payload = [ordered]@{
        Hostname    = $hostName
        Timestamp   = $timestamp
        Connections = @($connections)
    }

    $json = $payload | ConvertTo-Json -Depth 2

    Check-Log -Component "Connections" -JsonData $json
}