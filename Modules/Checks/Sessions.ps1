function Check-Sessions {
    param ($config)

    $hostname = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $sessionList = quser 2>$null | Select-Object -Skip 1

    $positions = @{
        UserName      = 1
        SessionName   = 23
        Id            = 40
        State         = 46
        IdleTime      = 53
        LogonTime     = 65
    }

    $sessions = foreach ($session in $sessionList) {
        $userName    = $session.Substring($positions['UserName'], 22).Trim()
        $sessionName = $session.Substring($positions['SessionName'], 17).Trim()
        $id          = $session.Substring($positions['Id'], 4).Trim()
        $state       = $session.Substring($positions['State'], 8).Trim() -replace 'Disc', 'Disconnected'

        $idleTime    = $session.Substring($positions['IdleTime'], 10).Trim()

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

        $logonTime   = $session.Substring($positions['LogonTime']).Trim()

        try {
            [ordered]@{
                UserName     = $userName
                SessionName  = $sessionName
                ID           = $id
                State        = $state
                IdleTime     = $idleTime
                LogonTime    = ([datetime]::Parse($logonTime)).ToString("yyyy-MM-dd HH:mm:ss.fff")
            }
        }
        catch {
            continue
        }
    }

    $payload = [ordered]@{
        Hostname  = $hostName
        Timestamp = $timestamp
        Sessions = @($sessions)
    }

    $json = $payload | ConvertTo-Json -Depth 2

    Check-Log -Component "Sessions" -JsonData $json
}