function Check-CPU {
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

    # CPU
    $cpuNode = $xml.CreateElement("CPU")

    $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

    # CPU elements
    $percentProcessorTimeNode = $xml.CreateElement("PercentProcessorTime")
    $percentProcessorTimeNode.InnerText = $cpuLoad
    $cpuNode.AppendChild($percentProcessorTimeNode) | Out-Null

    $root.AppendChild($cpuNode) | Out-Null

    Check-Log -Component "CPU" -XmlData $xml
}