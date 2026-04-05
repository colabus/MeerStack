function Check-Processes {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $processList = Get-CimInstance Win32_Process

    $shaCache = @{}
    $processList |
        Where-Object { $_.ExecutablePath -and (Test-Path $_.ExecutablePath) } |
        Select-Object -ExpandProperty ExecutablePath -Unique |
        ForEach-Object {
            try {
                $shaCache[$_] = (Get-FileHash -Algorithm SHA256 -Path $_ -ErrorAction Stop).Hash
            } catch {
                $shaCache[$_] = $null
            }
        }

    $processes = foreach ($process in $processList) {
        $sha256 = if ($process.ExecutablePath -and $shaCache.ContainsKey($process.ExecutablePath)) {
            $shaCache[$process.ExecutablePath]
        } else {
            $null
        }

        try {
            [ordered]@{
                Name        = $process.Name
                PID         = $process.ProcessId
                ParentPid   = $process.ParentProcessId
                Path        = $process.ExecutablePath
                CommandLine = $process.CommandLine
                StartTime   = if ($process.CreationDate) {
                    $process.CreationDate.ToString("yyyy-MM-dd HH:mm:ss")
                } else { $null }
                SessionId   = $process.SessionId
                SHA256      = $sha256
            }
        }
        catch {
            continue
        }
    }

    $payload = [ordered]@{
        Hostname  = $hostName
        Timestamp = $timestamp
        Processes = @($processes)
    }

    $json = $payload | ConvertTo-Json -Depth 2

    Check-Log -Component "Processes" -JsonData $json
}
