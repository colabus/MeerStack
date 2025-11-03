function Check-Memory {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
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

    # Memory
    $memoryNode = $xml.CreateElement("Memory")

    $memory = Get-CimInstance Win32_OperatingSystem

    $used = ($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory)
    $total = $memory.TotalVisibleMemorySize
    $usedPercent = ($used / $total) * 100

    # Memory elements
    $usedMBNode = $xml.CreateElement("UsedMB")
    $usedMBNode.InnerText = $([math]::Round($used,2))
    $memoryNode.AppendChild($usedMBNode) | Out-Null

    $totalMBNode = $xml.CreateElement("TotalMB")
    $totalMBNode.InnerText = $([math]::Round($total,2))
    $memoryNode.AppendChild($totalMBNode) | Out-Null

    $usedPercentNode = $xml.CreateElement("UsedPercent")
    $usedPercentNode.InnerText = $([math]::Round($usedPercent,2))
    $memoryNode.AppendChild($usedPercentNode) | Out-Null

    $root.AppendChild($memoryNode) | Out-Null

    Check-Log -Component "Memory" -XmlData $xml
}