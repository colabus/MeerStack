function Check-Connections {
    param ($config)

    $hostname = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    function Format-Endpoint ([string]$Address, [int]$Port) {
        if ($Address -match ':') { "[$Address]:$Port" } else { "${Address}:${Port}" }
    }

    $tcpConnections = Get-NetTCPConnection -ErrorAction SilentlyContinue | ForEach-Object {
        [ordered]@{
            Protocol      = "TCP"
            LocalAddress  = Format-Endpoint $_.LocalAddress $_.LocalPort
            RemoteAddress = Format-Endpoint $_.RemoteAddress $_.RemotePort
            State         = $_.State.ToString()
            PID           = $_.OwningProcess
            CreationTime  = ($_.CreationTime).ToString("yyyy-MM-dd HH:mm:ss")
        }
    }

    $udpEndpoints = Get-NetUDPEndpoint -ErrorAction SilentlyContinue | ForEach-Object {
        [ordered]@{
            Protocol      = "UDP"
            LocalAddress  = Format-Endpoint $_.LocalAddress $_.LocalPort
            RemoteAddress = "*:*"
            PID           = $_.OwningProcess
            CreationTime  = ($_.CreationTime).ToString("yyyy-MM-dd HH:mm:ss")
        }
    }

    $payload = [ordered]@{
        Hostname    = $hostname
        Timestamp   = $timestamp
        Connections = @($tcpConnections) + @($udpEndpoints)
    }

    $json = $payload | ConvertTo-Json -Depth 2

    Check-Log -Component "Connections" -JsonData $json
}