function Heartbeat {

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $xml = New-Object System.Xml.XmlDocument

    $root = $xml.CreateElement("Heartbeat")
    $xml.AppendChild($root) | Out-Null

    $hostnameElement = $xml.CreateElement("Hostname")
    $hostnameElement.InnerText = $hostname
    $root.AppendChild($hostnameElement) | Out-Null

    $timestampElement = $xml.CreateElement("Timestamp")
    $timestampElement.InnerText = $timestamp
    $root.AppendChild($timestampElement) | Out-Null

    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $bios = Get-CimInstance Win32_BIOS
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $bootTime = $os.LastBootUpTime
    $uptime = (Get-Date) - $bootTime

    $heartbeat = @{
        IPAddresses                 = ([System.Net.Dns]::GetHostAddresses($hostname) |
            Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
            Select-Object -ExpandProperty IPAddressToString) -join ", "
        OS                          = "$($os.Caption) $($os.OSArchitecture)"
        CurrentTimeZone             = $($os.CurrentTimeZone)
        Domain                      = $($cs.Domain)
        TotalMemoryGB               = $([math]::Round($cs.TotalPhysicalMemory / 1GB, 2))
        CPU                         = $($cpu.Name)
        NumberOfLogicalProcessors   = $($cs.NumberOfLogicalProcessors)
        BootTime                    = $($bootTime.ToString("yyyy-MM-dd HH:mm:ss"))
        MeerStackScriptName         = $MyInvocation.ScriptName
        MeerStackScriptVersion      = $scriptVersion
    }

    foreach ($pair in $heartbeat.GetEnumerator()) {
        $heartbeatElement = $xml.CreateElement($pair.Key)
        $heartbeatElement.InnerText = $pair.Value
        $root.AppendChild($heartbeatElement) | Out-Null
    }

    Check-Log -Component "Heartbeat" -XmlData $xml
}
