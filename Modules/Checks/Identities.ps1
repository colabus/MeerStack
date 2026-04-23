function Check-Identities {
    param ($config)

    $hostname = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $usersList = Get-LocalUser | Select-Object Name, Enabled, Description, FullName, LastLogon, AccountExpires, PasswordLastSet, PasswordRequired, UserMayChangePassword

    $users = foreach ($user in $usersList) {
        try {
            [ordered]@{
                Name                    = $user.Name
                Enabled                 = $user.Enabled
                Description             = $user.Description
                FullName                = $user.FullName
                LastLogon             = if ($user.LastLogon) { $user.LastLogon.ToString("yyyy-MM-dd HH:mm:ss") } else { $null }
                AccountExpires        = if ($user.AccountExpires) { $user.AccountExpires.ToString("yyyy-MM-dd HH:mm:ss") } else { $null }
                PasswordLastSet       = if ($user.PasswordLastSet) { $user.PasswordLastSet.ToString("yyyy-MM-dd HH:mm:ss") } else { $null }
                PasswordRequired        = $user.PasswordRequired
                UserMayChangePassword   = $user.UserMayChangePassword
            }
        }
        catch {
            continue
        }
    }

    $groups = Get-LocalGroup | Select-Object Name, Description | ForEach-Object {
        $groupName = $_.Name
        $groupDescription = $_.Description

        $members = try {
            Get-LocalGroupMember -Group $groupName | Where-Object { $_.Name } | ForEach-Object {
                [ordered]@{
                    Name        = $_.Name
                    ObjectClass = $_.ObjectClass
                }
            }
        } catch { @() }

        [ordered]@{
            Name        = $groupName
            Description = $groupDescription
            Members     = @($members)
        }
    }

    $payload = [ordered]@{
        Hostname    = $hostName
        Timestamp   = $timestamp
        Identities = [ordered]@{
            Users  = @($users)
            Groups = @($groups)
        }
    }

    $json = $payload | ConvertTo-Json -Depth 5

    Check-Log -Component "Identities" -JsonData $json
}