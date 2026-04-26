$script:processHashCache = @{}

function Check-Processes {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $processList = Get-CimInstance Win32_Process

    foreach ($path in ($processList | Where-Object { $_.ExecutablePath -and (Test-Path $_.ExecutablePath) } | Select-Object -ExpandProperty ExecutablePath -Unique)) {
        $cached    = $script:processHashCache[$path]
        $newestStart = ($processList | Where-Object { $_.ExecutablePath -eq $path } | Measure-Object -Property CreationDate -Maximum).Maximum

        $needsHash = -not $cached -or ($newestStart -and $newestStart -gt $cached.HashedAt)

        if ($needsHash) {
            try {
                $script:processHashCache[$path] = @{
                    Hash     = (Get-FileHash -Algorithm SHA256 -Path $path -ErrorAction Stop).Hash
                    HashedAt = (Get-Date)
                }
            } catch {
                $script:processHashCache[$path] = @{ Hash = $null; HashedAt = (Get-Date) }
            }
        }
    }

    $processes = foreach ($process in $processList) {
        $sha256 = if ($process.ExecutablePath -and $script:processHashCache.ContainsKey($process.ExecutablePath)) {
            $script:processHashCache[$process.ExecutablePath].Hash
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