function Check-Memory {
    param (
        [hashtable]$config
    )

    $hostName = [System.Net.Dns]::GetHostName()
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $os = Get-CimInstance Win32_OperatingSystem
    $used = ($os.TotalVisibleMemorySize - $os.FreePhysicalMemory)
    $total = $os.TotalVisibleMemorySize
    $usedPercent = ($used / $total) * 100

    $xml = [xml] @"
<Metrics>
    <Hostname>$($hostName)</Hostname>
    <Timestamp>$($timestamp)</Timestamp>
    <Memory>
        <UsedMB>$([math]::Round($used,2))</UsedMB>
        <TotalMB>$([math]::Round($total,2))</TotalMB>
        <UsedPercent>$([math]::Round($usedPercent,2))</UsedPercent>
    </Memory>
</Metrics>
"@

    Check-Log -Component "Memory" -XmlData $xml
}