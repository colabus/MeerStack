function Check-Certificates {
    param (
        [hashtable]$config
    )

    $hostName  = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
 
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "My", "LocalMachine"
    $store.Open("ReadOnly")

    $certificateList = $store.Certificates
 
    $certificates = foreach ($certificate in $certificateList) {
        $template = $null

        foreach ($certExtension in $certificate.Extensions) {
            if ($certExtension.Oid.Value -eq "1.3.6.1.4.1.311.21.7")  # Certificate Template Information
            {
                $template = $certExtension.Format(0) -replace '^Template=', '' -replace '\(1.3.6.1.4.1.311.21.*', ''
            }
        }
 
        try {
            [ordered]@{
                DnsNameList     = $certificate.DnsNameList
                Issuer          = $certificate.Issuer
                NotBefore       = $certificate.NotBefore.ToString("yyyy-MM-dd HH:mm:ss")
                NotAfter        = $certificate.NotAfter.ToString("yyyy-MM-dd HH:mm:ss")
                HasPrivateKey   = $certificate.HasPrivateKey
                SerialNumber    = $certificate.SerialNumber
                Subject         = $certificate.Subject
                Thumbprint      = $certificate.Thumbprint
                Template        = $template
                Version         = $certificate.Version
            }
        }
        catch {
            continue
        }
    }
 
    $payload = [ordered]@{
        Hostname  = $hostName
        Timestamp = $timestamp
        Certificates = @($certificates)
    }

    $json = $payload | ConvertTo-Json -Depth 2

    Check-Log -Component "Certificates" -JsonData $json
}
