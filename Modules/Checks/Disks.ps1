function Check-Disks {
    param (
        [hashtable]$config
    )

    $hostName  = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
 
    $xml  = New-Object System.Xml.XmlDocument
    $root = $xml.CreateElement("Metrics")
    $xml.AppendChild($root) | Out-Null
 
    $hostnameElement = $xml.CreateElement("Hostname")
    $hostnameElement.InnerText = $hostName
    $root.AppendChild($hostnameElement) | Out-Null
 
    $timestampElement = $xml.CreateElement("Timestamp")
    $timestampElement.InnerText = $timestamp
    $root.AppendChild($timestampElement) | Out-Null
 
    # Disks
    $disksNode = $xml.CreateElement("Disks")
    $disksNode.SetAttribute("version", "2.0")

    $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3"
 
    foreach ($drive in $drives) {
        $sizeGB             = [math]::Round($drive.Size / 1GB, 2)
        $freeGB             = [math]::Round($drive.FreeSpace / 1GB, 2)
        $usedGB             = $sizeGB - $freeGB
        $usedPercent        = if ($drive.Size -gt 0) {
            [math]::Round(($usedGB / $sizeGB) * 100, 2)
        } else {
            0
        }
        $description        = $drive.Description
        $fileSystem         = $drive.FileSystem
        $volumeSerialNumber = $drive.VolumeSerialNumber
 
        $diskNode = $xml.CreateElement("Disk")
 
        $disk = @{
            DeviceID            = $drive.DeviceID
            VolumeName          = $drive.VolumeName
            SizeGB              = $sizeGB
            UsedGB              = $usedGB
            FreeGB              = $freeGB
            UsedPercent         = $usedPercent
            Description         = $description
            FileSystem          = $fileSystem
            VolumeSerialNumber  = $volumeSerialNumber
        }
 
        foreach ($pair in $disk.GetEnumerator()) {
            $element = $xml.CreateElement($pair.Key)
            $element.InnerText = $pair.Value
            $diskNode.AppendChild($element) | Out-Null
        }
 
        $disksNode.AppendChild($diskNode) | Out-Null
    }
 
    $root.AppendChild($disksNode) | Out-Null
 
    Check-Log -Component "Disks" -XmlData $xml
}