Configuration A1_Server_Base_EnvData
{
    param
    (
        [Hashtable]$Node
    )
    
    #================== Base Services ==================
    ServiceSet BaseServices
    {
        Name  = @( 'Dhcp', 'MpsSvc', 'HealthService' )
        State = 'Running'
    }

    xTimeZone TimeZone
    {
        IsSingleInstance = "Yes"
        TimeZone         = $Node.TimeZone
    }
    
    if ($Node.DesktopEdition -eq 'FullGUI')
    {
        ServiceSet DisabledServices
        {
            Name        = @( 'XblAuthManager', 'XblGameSave' )
            State       = 'Stopped'
            StartupType = 'Disabled'
        }
    }

    #================== Create Local Users ==================
    foreach ($LocalUser in $Node.LocalUsers) 
    {
        $LocalUserPwd = Unprotect-CmsMessage -To $SecretCert -Content $ConfigurationData.NonNodeData.Creds.Where{$_.Name -eq $LocalUser}.Password
        $LocalUserPwdSecure = $LocalUserPwd | ConvertTo-SecureString -AsPlainText -Force  
        $PasswordCredential = New-Object System.Management.Automation.PSCredential ($LocalUser, $LocalUserPwdSecure)

        User $LocalUser
        {
            Ensure                   = 'Present'
            UserName                 = $LocalUser
            Password                 = $PasswordCredential
            PasswordNeverExpires     = $true
            PasswordChangeNotAllowed = $true
            Disabled                 = $false
        }
    }

    #================== Local Administrators ==================
    foreach ($LocalAdmin in $Node.LocalAdmins) 
    {
        Group $LocalAdmin
        {
            Ensure           = "Present"
            GroupName        = "Administrators"
            MembersToInclude = $LocalAdmin
            Credential       = $credential
        }
    }

    foreach ($ExtraFolder in $Node.ExtraFolders)
    {
        File $ExtraFolder
        {
            Ensure          = "Present"
            Type            = "Directory"
            DestinationPath = $ExtraFolder
            Force           = $true
        }
    }

    if ($Node.StaticRoute -eq $true)
    {
        xRoute StaticRoute
        {
            Ensure            = 'Present'
            InterfaceAlias    = 'Ethernet0'
            AddressFamily     = 'IPv4'
            DestinationPrefix = $DataCenter.StaticRoute.DestinationPrefix
            NextHop           = $DataCenter.StaticRoute.NextHop
            RouteMetric       = $DataCenter.StaticRoute.RouteMetric
        }
    }

    if (!([string]::IsNullOrEmpty($Node.IPAddress)))
    {
        #================== Set Static ==================
        xDhcpClient DisabledDhcpClient
        {
            State          = 'Disabled'
            InterfaceAlias = 'Ethernet0'
            AddressFamily  = 'IPv4'
        }

        xIPAddress NewIPAddress
        {
            IPAddress      = $Node.IPAddress + '/24'
            InterfaceAlias = 'Ethernet0'
            AddressFamily  = 'IPV4'
            DependsOn      = "[xDhcpClient]DisabledDhcpClient"
        }

        xDefaultGatewayAddress SetDefaultGateway
        {
            Address        =  $Network.DefaultGW
            InterfaceAlias = 'Ethernet0'
            AddressFamily  = 'IPv4'
            DependsOn      = "[xIPAddress]NewIPAddress"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = $Network.DNSOrder
            InterfaceAlias = 'Ethernet0'
            AddressFamily  = 'IPv4'
            DependsOn      = "[xIPAddress]NewIPAddress"
        }
        xDnsConnectionSuffix DnsConnectionSuffix
        {
            Ensure                         = 'Present'
            InterfaceAlias                 = 'Ethernet0'
            ConnectionSpecificSuffix       = $Domain.ConnectionSpecificSuffix
            RegisterThisConnectionsAddress = $true
            UseSuffixWhenRegistering       = $true
            DependsOn                      = "[xDnsServerAddress]DnsServerAddress"
        }
    }
    
    #================== Install Role Windows Features ==================
    foreach ($feature in $featuresToInstall)
    {
        if ($feature -eq "NET-Framework-Core")
        {
            Script InstallDotNetFrameworkCore
            {
                TestScript = 
                {
                    (Get-WindowsFeature Net-Framework-Core | Select-Object -ExpandProperty "Installed") -eq $true
                }
                SetScript  = 
                {
                    $Source = $using:Domain.FeatureSource
                    Install-WindowsFeature Net-Framework-Core -source $Source          
                }
                GetScript  = {@{Result = "InstallDotNetFrameworkCore"}
                }
            }

            WindowsFeature $feature
            {
                Name      = $feature
                Ensure    = 'Present'
                DependsOn = "[Script]InstallDotNetFrameworkCore"
            }
        }
        else
        {
            WindowsFeature $feature
            {
                Name   = $feature
                Ensure = 'Present'
            }
        }
    }

    foreach ($additionalfeature in $Node.AdditionalFeatures)
    {
        WindowsFeature $additionalfeature
        {
            Name   = $additionalfeature
            Ensure = 'Present'
        }
    }

    #================== Import Certs ==================
    foreach ($CertRole in $Node.Certs)
    {
        $Cert = $ConfigurationData.NonNodeData.Certs.Where{$_.Name -eq $CertRole}
        $CertName = $Cert.Name
        $CertFileName = $Cert.FileName
        
        File $CertName
        {
            Ensure          = "Present"
            MatchSource     = $true
            Checksum        = "SHA-256"
            SourcePath      = Join-Path $Domain.FileShare "certs\$($Cert.FileName)"
            DestinationPath = Join-Path "C:\temp" $Cert.FileName
        }

        if ($CertFileName -like "*.pfx")
        {
            $CertPassword = $Cert.Password | Unprotect-CmsMessage -To $SecretCert | ConvertTo-SecureString -AsPlainText -Force
            $CertCred = New-Object System.Management.Automation.PSCredential('Pfx', $CertPassword)
            
            xPfxImport $CertName
            {
                Thumbprint = $Cert.Thumbprint
                Path       = Join-Path "C:\temp" $Cert.FileName
                Location   = "LocalMachine"
                Store      = 'My'
                Credential = $CertCred
                Ensure     = "Present"
                DependsOn  = "[File]$CertName"
            }
        }

        if ($CertFileName -like "*.p7b")
        {
            xCertificateImport $CertName
            {
                Thumbprint = $Cert.Thumbprint
                Path       = Join-Path "C:\temp" $Cert.FileName
                Location   = "LocalMachine"
                Store      = 'My'
                Ensure     = "Present"
                DependsOn  = "[File]$CertName"
            }
        }
    }

    #================== TLS Configuration ==================
    # Credit to Alexander Hass. This is his script turned into DSC.
    # http://www.hass.de/content/setup-your-iis-ssl-perfect-forward-secrecy-and-tls-12
    
    $insecureProtocols = @("SSL 2.0", "SSL 3.0", "PCT 1.0", "Multi-Protocol Unified Hello")
    $secureProtocols = @("TLS 1.0", "TLS 1.1", "TLS 1.2")

    $insecureCiphers = @('DES 56/56', 'NULL', 'RC2 128/128', 'RC2 40/128', 'RC2 56/128', 'RC4 128/128', 'RC4 40/128', 'RC4 56/128', 'RC4 64/128', 'Triple DES 168/168')
    $secureCiphers = @('AES 128/128', 'AES 256/256')

    $enableHashes = @("SHA", "SHA256", "SHA384", "SHA512")
    $disableHashes = @("MD5")

    $enableKeyExchangeAlgorithms = @("ECDH", "PKCS")

    $cipherSuitesOrder = @(
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384',
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256',
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA',
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA',
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384',
        'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256',
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA',
        'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA',
        'TLS_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_RSA_WITH_AES_256_CBC_SHA256',
        'TLS_RSA_WITH_AES_128_CBC_SHA256',
        'TLS_RSA_WITH_AES_256_CBC_SHA',
        'TLS_RSA_WITH_AES_128_CBC_SHA'
    )
    $cipherSuitesAsString = [string]::join(',', $cipherSuitesOrder)

    foreach ($cipher in $insecureCiphers)
    {
        xRegistry "Reg-Disable-$cipher"
        {
            Ensure    = "Present"
            Key       = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$cipher"
            ValueType = "Dword"
            ValueName = "Enabled"
            ValueData = "0"
            Force     = $true
        }
    }

    foreach ($cipher in $secureCiphers)
    {
        xRegistry "Reg-Enable-$cipher"
        {
            Ensure    = "Present"
            Key       = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$cipher"
            ValueType = "Dword"
            ValueName = "Enabled"
            ValueData = "-1"
            Force     = $true
        }
    }

    foreach ($hash in $disableHashes)
    {
        Registry "Reg-Disable-$hash"
        {
            Ensure    = "Present"
            Key       = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\$hash"
            ValueType = "Dword"
            ValueName = "Enabled"
            ValueData = "0"
            Force     = $true
        }
    }

    foreach ($hash in $enableHashes)
    {
        Registry "Reg-Enable-$hash"
        {
            Ensure    = "Present"
            Key       = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\$hash"
            ValueType = "Dword"
            ValueName = "Enabled"
            ValueData = "-1"
            Force     = $true
        }
    }

    foreach ($protocol in $insecureProtocols)
    {
        Registry "Reg-Disable-$protocol"
        {
            Ensure    = "Present"
            Key       = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Server"
            ValueType = "Dword"
            ValueName = "Enabled"
            ValueData = "0"
            Force     = $true
        }
    }

    foreach ($protocol in $secureProtocols)
    {
        Registry "Reg-Enable-$protocol"
        {
            Ensure    = "Present"
            Key       = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Server"
            ValueType = "Dword"
            ValueName = "Enabled"
            ValueData = "-1"
            Force     = $true
        }
    }

    foreach ($protocol in $secureProtocols)
    {
        Registry "Reg-Enable2-$protocol"
        {
            Ensure    = "Present"
            Key       = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Server"
            ValueType = "Dword"
            ValueName = "DisabledByDefault"
            ValueData = "0"
            Force     = $true
        }
    }

    Registry "CipherSuiteOrder"
    {
        Ensure    = "Present"
        Key       = "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002"
        ValueType = "String"
        ValueName = "Functions"
        ValueData = $cipherSuitesAsString
        Force     = $true
    }

    
    #================== Windows Update Registry Settings ==================
    # Ensures the WUServer key is present
    Registry WindowsUpdateServer
    {
        Ensure    = "Present"
        Force     = $True
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        ValueType = "String"
        ValueName = "WUServer"
        ValueData = $DataCenter.WSUS
    }

    # Ensures the WUStatusServer Key is present
    Registry WindowsUpdateStatusServer
    {
        Ensure    = "Present"
        Force     = $True
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        ValueType = "String"
        ValueName = "WUStatusServer"
        ValueData = $DataCenter.WSUS
    }

    # Ensures Windows Update is set to Notify Before Download
    Registry WindowsUpdateOptions
    {
        Ensure    = "Present"
        Force     = $True
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
        ValueType = "Dword"
        ValueName = "AUOptions"
        ValueData = "3"
    }

    #Ensures that Windows uses the Server specified previously
    Registry WindowsUpdateServerStatus
    {
        Ensure    = "Present"
        Force     = $True
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
        ValueType = "Dword"
        ValueName = "UseWUServer"
        ValueData = "1"
    }
    
}