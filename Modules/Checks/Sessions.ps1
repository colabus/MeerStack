function Check-Sessions {
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

    $sessionsNode = $xml.CreateElement("Sessions")

    $sessions = quser 2>$null | Select-Object -Skip 1

    $positions = @{
        UserName      = 1
        SessionName   = 23
        Id            = 40
        State         = 46
        IdleTime      = 53
        LogonTime     = 65
    }

    foreach ($line in $sessions) {
        $userName    = $line.Substring($positions['UserName'], 22).Trim()
        $sessionName = $line.Substring($positions['SessionName'], 17).Trim()
        $id          = $line.Substring($positions['Id'], 4).Trim()
        $state       = $line.Substring($positions['State'], 8).Trim() -replace 'Disc', 'Disconnected'

        $idleTime    = $line.Substring($positions['IdleTime'], 10).Trim()

        if ($idleTime -match '^(\d+)\+(\d{1,2}):(\d{2})$') {
            $days = [int]$matches[1]
            $hours = [int]$matches[2]
            $minutes = [int]$matches[3]
        } elseif ($idleTime -match '^(\d{1,2}):(\d{2})$') {
            $days = 0
            $hours = [int]$matches[1]
            $minutes = [int]$matches[2]
        } elseif ($idleTime -match '^(\d{1,2})$') {
            $days = 0
            $hours = 0
            $minutes = [int]$matches[1]
        } else {
            $days = 0
            $hours = 0
            $minutes = 0
        }

        $idleTime = ($days * 1440) + ($hours * 60) + $minutes

        $logonTime   = $line.Substring($positions['LogonTime']).Trim()

        $sessionNode = $xml.CreateElement("Session")

        $session = @{
            UserName     = $userName
            SessionName  = $sessionName
            ID           = $id
            State        = $state
            IdleTime     = $idleTime
            LogonTime    = ([datetime]::Parse($logonTime)).ToString("yyyy-MM-dd HH:mm:ss.fff")
        }

        foreach ($pair in $session.GetEnumerator()) {
            $sessionElement = $xml.CreateElement($pair.Key)
            $sessionElement.InnerText = $pair.Value
            $sessionNode.AppendChild($sessionElement) | Out-Null
        }

        $sessionsNode.AppendChild($sessionNode) | Out-Null
    }

    $root.AppendChild($sessionsNode) | Out-Null

    Check-Log -Component "Sessions" -XmlData $xml
}