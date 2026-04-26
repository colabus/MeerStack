function Heartbeat {

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $bios = Get-CimInstance Win32_BIOS
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $bootTime = $os.LastBootUpTime
    $uptime = (Get-Date) - $bootTime

    $resourceMemory = "{0:N2} MB" -f ((Get-Process -Id $PID).WorkingSet64 / 1MB)

    $logFileSize = "{0:N2} MB" -f ((Get-Item -LiteralPath (Join-Path $config.LocalPath "MeerStack.log") -ErrorAction SilentlyContinue).Length / 1MB)

    $firewallActiveProfile = (Get-NetFirewallSetting -PolicyStore ActiveStore).ActiveProfile
    $firewallProfileEnabled = (Get-NetFirewallProfile -Name ($firewallActiveProfile  -split ',\s*')).Enabled -contains $true

    $rebootRequired = $false

    $checks = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    )

    foreach ($path in $checks) {
        if (Test-Path $path) {
            $rebootRequired = $true
        }
    }

    $heartbeat = [ordered]@{
        Hostname    = $hostname
        Timestamp   = $timestamp

        IPAddresses                 = ([System.Net.Dns]::GetHostAddresses($hostname) |
            Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
            Select-Object -ExpandProperty IPAddressToString) -join ", "
        OS                          = "$($os.Caption) $($os.OSArchitecture)"
        CurrentTimeZone             = $($os.CurrentTimeZone)
        BIOS                        = @{
            Name                    = $($bios.Name)
            Version                 = $($bios.Version)
            Manufacturer            = $($bios.Manufacturer)
            ReleaseDate             = $($bios.ReleaseDate.ToString("yyyy-MM-dd HH:mm:ss"))
        }
        Domain                      = $($cs.Domain)
        LogonServer                 = $(try {
            if ((Get-CimInstance Win32_ComputerSystem).PartOfDomain) {
                [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().FindDomainController().Name
            } else {
                $m_hostName
            }
        } catch {
            $null
        })
        TotalMemoryGB               = $([math]::Round($cs.TotalPhysicalMemory / 1GB, 2))
        CPU                         = $($cpu.Name)
        NumberOfLogicalProcessors   = $($cs.NumberOfLogicalProcessors)
        BootTime                    = $($bootTime.ToString("yyyy-MM-dd HH:mm:ss"))

        # Firewall
        FirewallActiveProfile       = $firewallActiveProfile.ToString()
        FirewallProfileEnabled      = $firewallProfileEnabled
        
        # MeerStack
        MeerStackScriptName         = $MyInvocation.ScriptName
        MeerStackScriptVersion      = $scriptVersion
        MeerStackDatabaseVersion    = $databaseVersion
        MeerStackScriptStartTime    = $($m_scriptStartTime.ToString("yyyy-MM-dd HH:mm:ss"))

        MeerStackLogFileSize        = $logFileSize
        
        # PowerShell
        PSVersion                   = $PSVersionTable.PSVersion.ToString()
        PSEdition                   = $PSVersionTable.PSEdition

        # Reboot Required
        RebootRequired              = $rebootRequired

        # Resources
        ResourceMemory              = $resourceMemory
    }

    $json = $heartbeat | ConvertTo-Json -Depth 2

    Check-Log -Component "Heartbeat" -JsonData $json
}
