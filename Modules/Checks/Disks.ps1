function Check-Disks {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $diskList = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3"
 
    $disks = foreach ($disk in $diskList) {
        $sizeGB             = [math]::Round($disk.Size / 1GB, 2)
        $freeGB             = [math]::Round($disk.FreeSpace / 1GB, 2)
        $usedGB             = $sizeGB - $freeGB
        $usedPercent        = if ($disk.Size -gt 0) {
            [math]::Round(($usedGB / $sizeGB) * 100, 2)
        } else {
            0
        }
        $description        = $disk.Description
        $fileSystem         = $disk.FileSystem
        $volumeSerialNumber = $disk.VolumeSerialNumber

        try {
            [ordered]@{
                DeviceID            = $disk.DeviceID
                VolumeName          = $disk.VolumeName
                SizeGB              = $sizeGB
                UsedGB              = $usedGB
                FreeGB              = $freeGB
                UsedPercent         = $usedPercent
                Description         = $description
                FileSystem          = $fileSystem
                VolumeSerialNumber  = $volumeSerialNumber
            }
        }
        catch {
            continue
        }
    }
 
    $payload = [ordered]@{
        Hostname  = $hostName
        Timestamp = $timestamp
        Disks = @($disks)
    }

    $json = $payload | ConvertTo-Json -Depth 2

    Check-Log -Component "Disks" -JsonData $json
}