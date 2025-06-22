function Check-EventLogs {
    param (
        [hashtable]$config
    )

    $hostname = $env:COMPUTERNAME
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $filterXml = $config.Checks.EventLogs.filterXml
    $lastTimeCreated = $config.Checks.EventLogs.lastTimeCreated

    $time = (Get-Date).AddDays(-1).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

    $filterXml = @"
    <QueryList>
    <Query Id="0" Path="Application">
        <Select Path="Application">
        *[System[TimeCreated[@SystemTime &gt; '$time'] ]]
        </Select>
        <Suppress Path="Application">*[System[((Provider[@Name = 'Windows Error Reporting'] and EventID = 1001) or (Provider[@Name = 'SecurityCenter'] and EventID = 15) or (Provider[@Name = 'Microsoft-Windows-RestartManager'] and EventID = 10001))]]</Suppress>
    </Query>
    <Query Id="1" Path="Security">
        <Select Path="Security">
        *[System[TimeCreated[@SystemTime &gt; '$time'] and EventID = 1102 and EventRecordID = 112284]]
        </Select>
    </Query>
    </QueryList>
    "@

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
