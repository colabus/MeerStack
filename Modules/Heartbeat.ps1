function Heartbeat {

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $ipAddresses = ([System.Net.Dns]::GetHostAddresses($hostname) |
        Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
        Select-Object -ExpandProperty IPAddressToString) -join ", "

    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $bios = Get-CimInstance Win32_BIOS
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $bootTime = $os.LastBootUpTime
    $uptime = (Get-Date) - $bootTime

        $xml = [xml]@"
<Metrics>
    <Hostname>$($hostName)</Hostname>
    <Timestamp>$($timestamp)</Timestamp>
    <Information>
        <Server>$hostname</Server>
        <IPAddresses>$ipAddresses</IPAddresses>
        <OS>$($os.Caption) $($os.OSArchitecture)</OS>
        <Domain>$($cs.Domain)</Domain>
        <TotalMemoryGB>$([math]::Round($cs.TotalPhysicalMemory / 1GB, 2))</TotalMemoryGB>
        <CPU>$($cpu.Name)</CPU>
        <NumberOfLogicalProcessors>$($cs.NumberOfLogicalProcessors)</NumberOfLogicalProcessors>
        <BootTime>$($bootTime.ToString("yyyy-MM-dd HH:mm:ss"))</BootTime>
    </Information>
</Metrics>
"@

    Check-Log -Component "Heartbeat" -XmlData $xml
}