function Get-DotNetInstallations {
    [CmdletBinding()]
    param()
    $frameworkKeys = @(
        @{ Name = '1.0';        SubKey = 'Microsoft\.NETFramework\Policy\v1.0\3705';       InstallValue = 'Install' }
        @{ Name = '1.1';        SubKey = 'Microsoft\NET Framework Setup\NDP\v1.1.4322';    InstallValue = 'Install' }
        @{ Name = '2.0';        SubKey = 'Microsoft\NET Framework Setup\NDP\v2.0.50727';   InstallValue = 'Install' }
        @{ Name = '3.0';        SubKey = 'Microsoft\NET Framework Setup\NDP\v3.0\Setup';   InstallValue = 'InstallSuccess' }
        @{ Name = '3.5';        SubKey = 'Microsoft\NET Framework Setup\NDP\v3.5';         InstallValue = 'Install' }
    )

    $net45ReleaseMap = [ordered]@{
        533320 = '4.8.1'
        528040 = '4.8'
        461808 = '4.7.2'
        461308 = '4.7.1'
        460798 = '4.7'
        394802 = '4.6.2'
        394254 = '4.6.1'
        393295 = '4.6'
        379893 = '4.5.2'
        378675 = '4.5.1'
        378389 = '4.5'
    }

    $hiveRoot = 'HKLM:\SOFTWARE'
    $results  = New-Object System.Collections.Generic.List[object]

    foreach ($entry in $frameworkKeys) {
        $path = Join-Path $hiveRoot $entry.SubKey
        if (-not (Test-Path -LiteralPath $path)) { continue }

        $p = Get-ItemProperty -LiteralPath $path -ErrorAction SilentlyContinue
        if ("$($p.$($entry.InstallValue))" -ne '1') { continue }

        $results.Add([pscustomobject]@{
            Name    = ".NET Framework $($entry.Name)"
            Version = $p.Version
        })
    }

    $fullPath = Join-Path $hiveRoot 'Microsoft\NET Framework Setup\NDP\v4\Full'

    if (Test-Path -LiteralPath $fullPath) {
        $p = Get-ItemProperty -LiteralPath $fullPath -ErrorAction SilentlyContinue
        if ($p.Release) {
            $release  = [int]$p.Release
            $friendly = $null
            foreach ($kvp in $net45ReleaseMap.GetEnumerator()) {
                if ($release -ge [int]$kvp.Key) { $friendly = $kvp.Value; break }
            }
            if ($friendly) {
                $results.Add([pscustomobject]@{
                    Name    = ".NET Framework $friendly"
                    Version = $p.Version
                })
            }
        }
        elseif ("$($p.Install)" -eq '1') {
            $results.Add([pscustomobject]@{
                Name    = '.NET Framework 4.0'
                Version = $p.Version
            })
        }
    }

    $results | Sort-Object Name -Unique
}

function Check-Software {
    param ($config)

    $hostname = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Software

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

    # SQL Server

    $registryPath = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server'

    $instances = if (Test-Path $registryPath) {
        $instances = (Get-ItemProperty $registryPath -ErrorAction SilentlyContinue).InstalledInstances

        if ($instances) {
            foreach ($instance in $instances) {
                $instanceNamesPath = "$registryPath\Instance Names\SQL"

                $internalName = (Get-ItemProperty $instanceNamesPath -ErrorAction SilentlyContinue).$instance

                if ($internalName) {
                    $setupPath = "$registryPath\$internalName\Setup"
                    $setup = Get-ItemProperty $setupPath -ErrorAction SilentlyContinue

                    try {
                        [ordered]@{
                            InstanceName = $instance
                            Edition      = $setup.Edition
                            Version      = $setup.Version
                            PatchLevel   = $setup.PatchLevel
                            SQLBinRoot   = $setup.SQLBinRoot
                        }
                    }
                    catch {
                        continue
                    }
                }
            }
        }
    }

    # .NET Framework

    $frameworks = foreach ($framework in Get-DotNetInstallations) {
        try {
            [ordered]@{
                Name    = $framework.Name
                Version = $framework.Version
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
        SQLServer = @($instances)
        NETFramework = @($frameworks)
    }

    $json = $payload | ConvertTo-Json -Depth 2

    Check-Log -Component "Software" -JsonData $json
}
