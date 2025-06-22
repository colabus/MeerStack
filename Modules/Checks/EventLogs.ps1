function Check-EventLogs {
    param (
        [hashtable]$config
    )

    $hostname = $env:COMPUTERNAME

    $filterXml = $config.Checks.EventLogs.filterXml
    $lastTimeCreated = $config.Checks.EventLogs.lastTimeCreated

    if (-not $filterXml) {
        MeerStack-Log -Component "EventLogs" -Message "No config returned from database."
        return
    }

    # Build an XML document
    $xmlContent = "<EventLogs><Hostname>$($hostName)</Hostname><Timestamp>$($timestamp)</Timestamp><EventLog>`n"

    $events = Get-WinEvent -FilterXml $filterXml

    foreach ($event in $events)
    {
        # Convert event to XML and log
            $xmlContent += [xml]@"
<Event>
  <LogName>$($_.LogName)</LogName>
  <LevelDisplayName>$($_.LevelDisplayName)</LevelDisplayName>
  <TimeCreated>$($_.TimeCreated)</TimeCreated>
  <ProviderName>$($_.ProviderName)</ProviderName>
  <TaskDisplayName>$($_.TaskDisplayName)</TaskDisplayName>
  <Message><![CDATA[$($event.Message)]]></Message>
  <ID>$($_.ID)</ID>
  <RecordID>$($_.RecordID)</RecordID>
</Event>
"@
    }

    $xmlContent += "</EventLog></EventLogs>"

    # Convert string to XML object
    $xml = [xml]$xmlContent

    if ($xml.EventLogs.EventLog.Event.Count -ne 0)
    {
        Check-Log -Component "EventLog" -XmlData $xml
    }
}
