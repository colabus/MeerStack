function Check-Software {
    param ($config)

    $hostname = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $paths = @(
        # 64-bit software (system-wide)
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        # 32-bit software on 64-bit systems (system-wide)
        'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        # Current user 64-bit
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        # Current user 32-bit
        'HKCU:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    $softwareList = Get-ItemProperty $paths -ErrorAction SilentlyContinue | 
        Where-Object { $_.DisplayName -ne $null } |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
        Sort-Object DisplayName, 
        @{ Expression = { [string]::IsNullOrEmpty($_.DisplayVersion) }; Ascending = $true },
        @{ Expression = { [string]::IsNullOrEmpty($_.InstallDate) };    Ascending = $true } |
        Group-Object DisplayName |
        ForEach-Object { $_.Group | Select-Object -First 1 }

    $software = foreach ($software in $softwareList) {
        try {
            [ordered]@{
                DisplayName     = $software.DisplayName
                DisplayVersion  = $software.DisplayVersion
                Publisher       = $software.Publisher
                InstallDate     = $software.InstallDate
            }
        }
        catch {
            continue
        }
    }

    $payload = [ordered]@{
        Hostname  = $hostName
        Timestamp = $timestamp
        Software = @($software)
    }

    $json = $payload | ConvertTo-Json -Depth 2

    Check-Log -Component "Software" -JsonData $json
}