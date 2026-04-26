function Check-Sessions {
    param ($config)

    $hostname = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $quser = quser 2>$null

    $sessions = if ($quser -and $quser.Count -gt 1) {
        $header     = $quser[0]

        $colSession = $header.IndexOf('SESSIONNAME')
        $colId      = $header.IndexOf('ID')
        $colState   = $header.IndexOf('STATE')
        $colIdle    = $header.IndexOf('IDLE TIME')
        $colLogon   = $header.IndexOf('LOGON TIME')

        foreach ($line in ($quser | Select-Object -Skip 1)) {
            $userName    = $line.Substring(1, $colSession - 1).Trim()
            $sessionName = $line.Substring($colSession, $colId - $colSession).Trim()
            $id          = $line.Substring($colId, $colState - $colId).Trim()
            $state       = $line.Substring($colState, $colIdle - $colState).Trim() -replace 'Disc', 'Disconnected'
            $idleStr     = $line.Substring($colIdle, $colLogon - $colIdle).Trim()
            $logonStr    = $line.Substring($colLogon).Trim()

            if ($idleStr -match '^(\d+)\+(\d{1,2}):(\d{2})$') {
                $idleMinutes = [int]$matches[1] * 1440 + [int]$matches[2] * 60 + [int]$matches[3]
            } elseif ($idleStr -match '^(\d{1,2}):(\d{2})$') {
                $idleMinutes = [int]$matches[1] * 60 + [int]$matches[2]
            } elseif ($idleStr -match '^(\d+)$') {
                $idleMinutes = [int]$matches[1]
            } else {
                $idleMinutes = 0
            }

            try {
                [ordered]@{
                    UserName    = $userName
                    SessionName = $sessionName
                    ID          = $id
                    State       = $state
                    IdleTime    = $idleMinutes
                    LogonTime   = ([datetime]::Parse($logonStr)).ToString("yyyy-MM-dd HH:mm:ss.fff")
                }
            }
            catch {
                continue
            }
        }
    }

    $payload = [ordered]@{
        Hostname  = $hostname
        Timestamp = $timestamp
        Sessions  = @($sessions)
    }

    $json = $payload | ConvertTo-Json -Depth 2

    Check-Log -Component "Sessions" -JsonData $json
}