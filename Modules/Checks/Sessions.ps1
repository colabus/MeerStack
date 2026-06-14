function Check-Sessions {
    param ($config)

    $hostname  = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $quser = quser 2>$null

    $sessions = if ($quser -and $quser.Count -gt 1) {
        $headerIndex = ($quser | Select-String -Pattern '^\s*USERNAME\s+SESSIONNAME').LineNumber

        if (-not $headerIndex) { return }

        $headerIndex = $headerIndex - 1

        $header     = $quser[$headerIndex]
        $colSession = $header.IndexOf('SESSIONNAME')
        $colState   = $header.IndexOf('STATE')

        foreach ($line in ($quser | Select-Object -Skip ($headerIndex + 1))) {

            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            $userName = $line.Substring(1, $colSession - 1).Trim()

            $middle      = $line.Substring($colSession, $colState - $colSession).Trim()
            $middleParts = $middle -split '\s+'
            $id          = $middleParts[-1]
            $sessionName = if ($middleParts.Count -gt 1) { $middleParts[0] } else { '' }

            if ($id -notmatch '^\d+$') { continue }

            $tail = $line.Substring($colState).Trim()

            if ($tail -notmatch '^(?<state>\S+)\s+(?<idle>\S+)\s+(?<logon>.+?)\s*$') { continue }

            $state    = $matches['state'] -replace 'Disc', 'Disconnected'
            $idle  = $matches['idle']
            $logon = $matches['logon']

            if ($idle -match '^(\d+)\+(\d{1,2}):(\d{2})$') {
                $idleMinutes = [int]$matches[1] * 1440 + [int]$matches[2] * 60 + [int]$matches[3]
            } elseif ($idle -match '^(\d{1,2}):(\d{2})$') {
                $idleMinutes = [int]$matches[1] * 60 + [int]$matches[2]
            } elseif ($idle -match '^(\d+)$') {
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
                    LogonTime   = ([datetime]::Parse($logon)).ToString("yyyy-MM-dd HH:mm:ss.fff")
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