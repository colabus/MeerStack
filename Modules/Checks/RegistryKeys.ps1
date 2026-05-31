#region Supporting Functions
function Set-RegistryNode {
    param (
        [System.Collections.Specialized.OrderedDictionary]$Tree,
        [string[]]$Parts,
        [string]$ValueName,
        $ValueData
    )
    $node = $Tree
    foreach ($part in $Parts) {
        if (-not $node.Contains($part)) {
            $node[$part] = [ordered]@{}
        }
        $node = $node[$part]
    }
    if (-not [string]::IsNullOrWhiteSpace($ValueName)) {
        $node[$ValueName] = $ValueData
    }
}
function Set-RegistryNodeRecurse {
    param (
        [System.Collections.Specialized.OrderedDictionary]$Tree,
        [string[]]$Parts,
        [Microsoft.Win32.RegistryKey]$Item
    )
    # Walk to the correct node
    $node = $Tree
    foreach ($part in $Parts) {
        if (-not $node.Contains($part)) {
            $node[$part] = [ordered]@{}
        }
        $node = $node[$part]
    }
    # Write values at this level
    foreach ($v in $Item.GetValueNames()) {
        $raw          = $Item.GetValue($v, $null)
        $node[$v]     = if ($null -ne $raw) { $raw.ToString() } else { $null }
    }
    # Recurse into subkeys
    foreach ($subKeyName in $Item.GetSubKeyNames()) {
        try {
            $subKey = $Item.OpenSubKey($subKeyName)
            if (-not $node.Contains($subKeyName)) {
                $node[$subKeyName] = [ordered]@{}
            }
            Set-RegistryNodeRecurse -Tree $node[$subKeyName] -Parts @() -Item $subKey
            $subKey.Close()
        }
        catch {
            continue
        }
    }
}
#endregion Supporting

function Check-RegistryKeys {
    param (
        [hashtable]$config
    )

    $hostName  = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $registryKeysToCheck = $config.Checks.RegistryKeys.RegistryKeysToCheck

    if (-not $registryKeysToCheck -or $registryKeysToCheck.Count -eq 0) {
        MeerStack-Log -Status "INFO " -Message "[Check-RegistryKeys] No registry keys configured."

        return
    }

    $registryKeys = [ordered]@{}

    foreach ($registryKey in $registryKeysToCheck) {
        try {
            $path      = $registryKey.Path
            $valueName = $registryKey.Value
            $recurse   = $registryKey.Recurse -eq $true



            $normalised = $path -replace '^([A-Za-z]+):\\?', '$1\'
            $parts      = $normalised -split '\\' | Where-Object { $_ }

            if (-not (Test-Path -LiteralPath $path)) {
                continue
            }

            $item = Get-Item -LiteralPath $path -ErrorAction Stop

            if (-not [string]::IsNullOrWhiteSpace($valueName)) {
                $raw  = $item.GetValue($valueName, $null)
                $data = if ($null -ne $raw) { $raw.ToString() } else { $null }

                Set-RegistryNode -Tree $registryKeys -Parts $parts -ValueName $valueName -ValueData $data
            } elseif ($recurse) {
                Set-RegistryNodeRecurse -Tree $registryKeys -Parts $parts -Item $item
            } else {
            
                foreach ($v in $item.GetValueNames()) {
                    $raw  = $item.GetValue($v, $null)
                    $data = if ($null -ne $raw) { $raw.ToString() } else { $null }
                    Set-RegistryNode -Tree $registryKeys -Parts $parts -ValueName $v -ValueData $data
                }
            }
        }
        catch {
            continue
        }
    }

    $payload = [ordered]@{
        Hostname  = $hostName
        Timestamp = $timestamp
        RegistryKeys  = @($registryKeys)
    }

    $json = $payload | ConvertTo-Json -Depth 20

    Check-Log -Component "RegistryKeys" -JsonData $json
}