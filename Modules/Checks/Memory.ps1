function Check-Memory {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $memory = Get-CimInstance Win32_OperatingSystem

    $used = ($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory)
    $total = $memory.TotalVisibleMemorySize
    $usedPercent = ($used / $total) * 100

    $memory = [ordered]@{
        Hostname    = $hostname
        Timestamp   = $timestamp

        UsedMB      = $([math]::Round($used,2))
        TotalMB     = $([math]::Round($total,2))
        UsedPercent = $([math]::Round($usedPercent,2))
    }

    $json = $memory | ConvertTo-Json -Depth 1

    Check-Log -Component "Memory" -JsonData $json
}