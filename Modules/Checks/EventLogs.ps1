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

    # Build an XML document
    $xmlContent = "<EventLogs><Hostname>$($hostName)</Hostname><Timestamp>$($timestamp)</Timestamp><EventLog>`n"

    $events = Get-WinEvent -FilterXml $filterXml -ErrorAction SilentlyContinue

    if (-not $events) {
        MeerStack-Log -Status "INFO" -Message "[Check-EventLogs] No matching events found."
    }

    foreach ($event in $events)
    {
        # Convert event to XML and log
            $xmlContent += @"
<Event>
  <LogName>$($event.LogName)</LogName>
  <LevelDisplayName>$($event.LevelDisplayName)</LevelDisplayName>
  <TimeCreated>$($event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss.fffffff"))</TimeCreated>
  <ProviderName>$($event.ProviderName)</ProviderName>
  <TaskDisplayName>$($event.TaskDisplayName)</TaskDisplayName>
  <Message><![CDATA[$($event.Message)]]></Message>
  <ID>$($event.Id)</ID>
  <RecordID>$($event.RecordID)</RecordID>
</Event>
"@
    }

    $xmlContent += "</EventLog></EventLogs>"

    # Convert string to XML object
    $xml = [xml]$xmlContent

    if ($xml.EventLogs.EventLog.Event.Count -ne 0)
    {
        Check-Log -Component "EventLogs" -XmlData $xml
    }
}
