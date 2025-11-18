function Check-Connections {
    param ($config)

    $hostname = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $xml = New-Object System.Xml.XmlDocument
    $root = $xml.CreateElement("Metrics")
    $xml.AppendChild($root) | Out-Null

    $hostnameElement = $xml.CreateElement("Hostname")
    $hostnameElement.InnerText = $hostname
    $root.AppendChild($hostnameElement) | Out-Null

    $timestampElement = $xml.CreateElement("Timestamp")
    $timestampElement.InnerText = $timestamp
    $root.AppendChild($timestampElement) | Out-Null

    $ConnectionsNode = $xml.CreateElement("Connections")

    $Connections = netstat -ano 2>$null | Select-Object -Skip 4

    foreach ($line in $Connections) {
        $parts = $line -split "\s+" | Where-Object { $_ -ne "" }

        $ConnectionNode = $xml.CreateElement("Connection")

        $Connection = @{
            Protocol        = $parts[0]
            LocalAddress    = $parts[1]
            RemoteAddress   = $parts[2]
            State           = $parts[3]
            PID             = $parts[4]
        }

        foreach ($pair in $Connection.GetEnumerator()) {
            $ConnectionElement = $xml.CreateElement($pair.Key)
            $ConnectionElement.InnerText = $pair.Value
            $ConnectionNode.AppendChild($ConnectionElement) | Out-Null
        }

        $ConnectionsNode.AppendChild($ConnectionNode) | Out-Null
    }

    $root.AppendChild($ConnectionsNode) | Out-Null

    Check-Log -Component "Connections" -XmlData $xml
}