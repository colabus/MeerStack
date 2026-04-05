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

    $events = Get-WinEvent -FilterXml $filterXml -ErrorAction SilentlyContinue

    if (-not $events) {
        MeerStack-Log -Status "INFO" -Message "[Check-EventLogs] No matching events found."

        return
    }

    $eventList = foreach ($event in $events) {
        try {
            [ordered]@{
                LogName          = $event.LogName
                LevelDisplayName = $event.LevelDisplayName
                TimeCreated      = $event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss.fffffff")
                ProviderName     = $event.ProviderName
                TaskDisplayName  = $event.TaskDisplayName
                Message          = $event.Message
                Id               = $event.Id
                RecordId         = $event.RecordId
                MachineName      = $event.MachineName
            }
        }
        catch {
            continue
        }
    }

    $payload = [ordered]@{
        Hostname  = $hostName
        Timestamp = $timestamp
        EventLog  = @($eventList)
    }

    $json = $payload | ConvertTo-Json -Depth 2

    Check-Log -Component "EventLogs" -JsonData $json
}
