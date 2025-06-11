function Check-Disks {
    param ($config)

    $hostName = [System.Net.Dns]::GetHostName()
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3"

    $xmlContent = "<Metrics><Hostname>$($hostName)</Hostname><Timestamp>$($timestamp)</Timestamp><Disks>"

    foreach ($drive in $drives) {
        $deviceID = $drive.DeviceID
        $volumeName = $drive.VolumeName
        $sizeGB = [math]::Round($drive.Size / 1GB, 2)
        $freeGB = [math]::Round($drive.FreeSpace / 1GB, 2)
        $usedGB = $sizeGB - $freeGB
        $usedPercent = if ($drive.Size -gt 0) {
            [math]::Round(($usedGB / $sizeGB) * 100, 2)
        } else {
            0
        }

        $xmlContent += @"
<Disk>
<DeviceID>$deviceID</DeviceID>
<VolumeName>$volumeName</VolumeName>
<SizeGB>$sizeGB</SizeGB>
<UsedGB>$usedGB</UsedGB>
<FreeGB>$freeGB</FreeGB>
<UsedPercent>$usedPercent</UsedPercent>
</Disk>
"@
    }

    $xmlContent += "</Disks></Metrics>"

    $xml = [xml]$xmlContent

    Check-Log -Component "Disks" -XmlData $xml
}