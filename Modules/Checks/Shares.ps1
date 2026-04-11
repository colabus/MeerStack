function Resolve-ShareType {
    param ([uint32]$Type)

    $adminFlag  = 0x80000000
    $isAdmin    = ($Type -band $adminFlag) -ne 0
    $baseType   = $Type -band 0x0000FFFF

    $typeName = switch ($baseType) {
        0 { "Disk Drive" }
        1 { "Print Queue" }
        2 { "Device" }
        3 { "IPC" }
        default { "Unknown ($baseType)" }
    }

    return "{0}{1}" -f $typeName, $(if ($isAdmin) { " (Admin)" } else { "" })
}

function Check-Shares {
    param ($config)

    $hostname = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $sharesList = Get-WmiObject Win32_Share | Select Name, Path, Description, AllowMaximum, Status, @{Name="Type"; Expression={ Resolve-ShareType -Type $_.Type }}

    $shares = foreach ($share in $sharesList) {
        try {
            $shareAccess = @()

            if ($share.Name -ne "IPC$") {
                try {
                    $shareAccess = Get-SmbShareAccess -Name $share.Name -ErrorAction Stop | ForEach-Object {
                        [ordered]@{
                            AccountName        = $_.AccountName
                            AccessRight        = $_.AccessRight.ToString()
                            AccessControlType  = $_.AccessControlType.ToString()
                        }
                    }
                }
                catch {
                    continue
                }
            }

            [ordered]@{
                Name            = $share.Name
                Path            = $share.Path
                Description     = $share.Description
                AllowMaximum    = $share.AllowMaximum
                Status          = $share.Status
                Type            = $share.Type
                Access          = @($shareAccess)
            }
        }
        catch {
            continue
        }
    }

    $payload = [ordered]@{
        Hostname    = $hostName
        Timestamp   = $timestamp
        Shares = @($shares)
    }

    $json = $payload | ConvertTo-Json -Depth 4

    Check-Log -Component "Shares" -JsonData $json
}