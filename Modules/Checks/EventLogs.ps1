function Check-EventLogs {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $filterXml = $config.Checks.EventLogs.XmlFilter
    $lastTimeCreated = ($config.Checks.EventLogs.LastUpdated.ToUniversalTime()).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

    if (-not $filterXml) {
        MeerStack-Log -Status "INFO" -Message "[Check-EventLogs] No config returned from database."
        return
    }

    $filterXml = $filterXml -f $lastTimeCreated

    $xml = New-Object System.Xml.XmlDocument
    $root = $xml.CreateElement("Metrics")
    $xml.AppendChild($root) | Out-Null

    $hostnameElement = $xml.CreateElement("Hostname")
    $hostnameElement.InnerText = $hostname
    $root.AppendChild($hostnameElement) | Out-Null

    $timestampElement = $xml.CreateElement("Timestamp")
    $timestampElement.InnerText = $timestamp
    $root.AppendChild($timestampElement) | Out-Null

    $eventLogNode = $xml.CreateElement("EventLog")

    $events = Get-WinEvent -FilterXml $filterXml -ErrorAction SilentlyContinue

    if (-not $events) {
        MeerStack-Log -Status "INFO" -Message "[Check-EventLogs] No matching events found."
    }
    else
    {
        foreach ($event in $events)
        {
            try {
                $eventNode = $xml.CreateElement("Event")

                $properties = @{
                    LogName             = $event.LogName
                    LevelDisplayName    = $event.LevelDisplayName
                    TimeCreated         = $event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss.fffffff")
                    ProviderName        = $event.ProviderName
                    TaskDisplayName     = $event.TaskDisplayName
                    Message             = $event.Message
                    Id                  = $event.Id
                    RecordID            = $event.RecordID
                    MachineName         = $event.MachineName
                }

                foreach ($pair in $properties.GetEnumerator()) {
                    $node = $xml.CreateElement($pair.Key)
                    
                    if ($pair.Key -eq "Message") {
                        $cdata = $xml.CreateCDataSection($pair.Value)
                        $node.AppendChild($cdata) | Out-Null
                    }
                    else {
                        $node.InnerText = $pair.Value
                    }
                    
                    $eventNode.AppendChild($node) | Out-Null
                }

                $eventLogNode.AppendChild($eventNode) | Out-Null
            }
             catch {
                continue
            }
        }

        $root.AppendChild($eventLogNode) | Out-Null

        Check-Log -Component "EventLogs" -XmlData $xml
    }
}
