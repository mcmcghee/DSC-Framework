Configuration B2_Role_WebServer_EnvData
{
    param
    (
        [Hashtable]$Node
    )

    if ($Node.Role -ine 'Web-Server') { return }
    
    #================== Web Servers Firewall ==================
    xFirewall HTTPS
    {
        Name        = "Web"
        DisplayName = "Inbound access for web requests"
        Ensure      = "Present"
        Action      = "Allow"
        Enabled     = "True"
        Profile     = ("Domain", "Private", "Public")
        Direction   = "InBound"
        RemotePort  = ("Any")
        LocalPort   = ("80", "443")
        Protocol    = "TCP"
        Description = "Inbound access for web requests"
    }

    #================== Disk Configuration ==================
    xDisk PageFileVolume
    {
        DiskId      = 1
        DriveLetter = "P"
        FSLabel     = "PageFile"
    }

    xDisk DataVolume
    {
        DiskId      = 2
        DriveLetter = "D"
        FSLabel     = "Data"
    }

    #================== Pagefile on P Drive ==================
    xSystemVirtualMemory MovePagefile
    {
        ConfigureOption = "SystemManagedSize"
        DriveLetter     = "P:"
        DependsOn       = "[xDisk]PageFileVolume"
    }

    #================== File System ==================
    File DataFolder 
    {
        Ensure          = "Present"
        Type            = "Directory"
        DestinationPath = "D:\inetpub"
        DependsOn       = @('[xDisk]DataVolume')
    }

    File LogFolder 
    {
        Ensure          = "Present"
        Type            = "Directory"
        DestinationPath = "D:\LogFiles"
        DependsOn       = @('[xDisk]DataVolume')
    }

    Service IISAdmin 
    {
        Name        = "IISAdmin"
        StartupType = "Automatic"
        State       = "Running"
        DependsOn   = "[WindowsFeature]Web-WebServer"
    }

    Service W3SVC 
    {
        Name        = "W3SVC"
        StartupType = "Automatic"
        State       = "Running"
        DependsOn   = "[WindowsFeature]Web-WebServer"
    }

    #================== Stop Default Website ==================
    xWebsite DefaultSite
    {
        Ensure       = "Absent"
        Name         = "Default Web Site"
        State        = "Stopped"
        PhysicalPath = "C:\inetpub\wwwroot"
        DependsOn    = "[Service]W3SVC"
    }

    #================== IIS URL Rewrite Module ==================
    File CopyUrlRewrite 
    {
        Ensure          = "Present"
        MatchSource     = $true
        Checksum        = "SHA-256"
        SourcePath      = Join-Path -Path $Domain.FileShare 'packages\rewrite_amd64.msi'
        DestinationPath = "C:\temp\rewrite_amd64.msi"
        DependsOn       = "[WindowsFeature]Web-WebServer"
    }

    Package UrlRewrite 
    {
        Ensure    = "Present"
        Name      = "IIS URL Rewrite Module 2"
        Path      = "C:\temp\rewrite_amd64.msi"
        Arguments = "/qn"
        ProductId = "{08F0318A-D113-4CF0-993E-50F191D397AD}"
        DependsOn = "[File]CopyUrlRewrite"
    }

    #================== WebDeploy ==================
    File CopyWebDeploy 
    {
        Ensure          = "Present"
        MatchSource     = $true
        Checksum        = "SHA-256"
        SourcePath      = Join-Path -Path $Domain.FileShare "packages\WebDeploy_amd64_en-US.msi"
        DestinationPath = "C:\temp\WebDeploy_amd64_en-US.msi"
        DependsOn       = "[WindowsFeature]Web-Mgmt-Service"
    }

    Package InstallWebDeploy 
    {
        Ensure    = "Present"
        Path      = "C:\temp\WebDeploy_amd64_en-US.msi"
        Name      = "Microsoft Web Deploy 3.6"
        ProductId = "{ED4CC1E5-043E-4157-8452-B5E533FE2BA1}"
        Arguments = "/qn ADDLOCAL=ALL"
        DependsOn = "[File]CopyWebDeploy"
    }

    Registry EnableIISRemoting 
    {
        Ensure    = "Present"
        Key       = "HKLM:\SOFTWARE\Microsoft\WebManagement\Server"
        ValueType = "Dword"
        ValueName = "EnableRemoteManagement"
        ValueData = "1"
        Force     = $true
        DependsOn = "[Package]InstallWebDeploy"
    }

    Service WebDeploy 
    {
        Name        = "MsDepSvc"
        StartupType = "Automatic"
        State       = "Running"
        DependsOn   = "[Registry]EnableIISRemoting"
    }

    Service WebMgmt 
    {
        Name        = "WMSVC"
        StartupType = "Automatic"
        State       = "Running"
        DependsOn   = "[Registry]EnableIISRemoting"
    }

    #================== Import SSL Certs ==================
    $Certs = @()
    foreach ($WebSiteRole in $Node.WebSites) 
    {
        $WebSite = $ConfigurationData.NonNodeData.WebSites.Where{$_.Name -eq $WebSiteRole}
        foreach ($sslHostNames in $WebSite.HTTPSHostNames) 
        {
            foreach ($WebSiteCert in $sslHostNames.Certificate) 
            {
                Write-Verbose "Certificate needed: $WebSiteCert"
                $Certs += $WebSiteCert
            }
        }
    }

    $uCerts = $Certs | Select-Object -Unique
    Write-Verbose "Certificates to install: $uCerts"

    foreach ($uCert in $uCerts) 
    {
        $Cert = $ConfigurationData.NonNodeData.Certs.Where{$_.Name -eq $uCert}
        $CertFileName = $Cert.FileName
        $CertName = $Cert.Name + "_Cert"

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

        if ($CertFileName -like "*.p7b" -or $CertFileName -like "*.cer")
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

    #================== IIS Website Configuration ==================
    foreach ($WebSiteRole in $Node.WebSites) 
    {
        $WebSite = $ConfigurationData.NonNodeData.WebSites.Where{$_.Name -eq $WebSiteRole}
        $WebSiteName = $WebSite.Name + "_Site"
        Write-Verbose $WebSiteName

        #================== Create Host File Entries ==================
        foreach ($HostsMap in $WebSite.HostsFile) 
        {
            if ($DataCenter.Name -eq $HostsMap.DataCenter)
            {
                foreach ($Entry in $HostsMap.Entries) 
                {
                    xHostsFile $Entry.Name
                    {
                        HostName  = $Entry.Name
                        IPAddress = $Entry.Destination
                        Ensure    = 'Present'
                    }
                }
            }
        }
        
        #================== Configure Virtual Directories ==================
        foreach ($WebVirtualDirectory in $WebSite.WebVirtualDirectories) 
        {
            $WebVirtualDirectoryName = $WebSite.Name + "_" + ($WebVirtualDirectory.Name).Replace("/", "") + "_Virt"
            $WebVirtualDirectoryPath = $WebSite.Name + "_" + $WebVirtualDirectory.PhysicalPath + "_Path"
            $FolderName = $WebVirtualDirectoryName + $WebVirtualDirectory.PhysicalPath
            Write-Verbose $WebVirtualDirectoryName

            File $WebVirtualDirectoryPath 
            {
                Ensure          = "Present"
                Type            = "Directory"
                DestinationPath = $WebVirtualDirectory.PhysicalPath
            }
            
            xWebVirtualDirectory $WebVirtualDirectoryName
            {
                Name           = $WebVirtualDirectory.Name
                Ensure         = $WebVirtualDirectory.Ensure
                Website        = $WebSite.Name
                PhysicalPath   = $WebVirtualDirectory.PhysicalPath
                WebApplication = $WebVirtualDirectory.WebApplication
                DependsOn      = "[xWebSite]" + $WebSite.Name + "_Site"
            }
        }

        #================== Configure AppPools ==================
        foreach ($WebAppPoolGroup in $WebSite.WebAppPools) 
        {
            foreach ($WebAppPool in $WebAppPoolGroup.Names) 
            {
                $WebAppName = $WebAppPool + "_Pool"
                Write-Verbose $WebAppName

                if ($WebAppPoolGroup.Settings.IdentityType -eq 'SpecificUser') 
                {
                    $WebAppSvcPwd = Unprotect-CmsMessage -To $SecretCert -Content $ConfigurationData.NonNodeData.Creds.Where{$_.Name -eq $WebAppPoolGroup.Settings.WebAppSvcAct}.Password
                    $WebAppSvcPwdSecure = $WebAppSvcPwd | ConvertTo-SecureString -AsPlainText -Force            
                    $WebAppSvcCred = New-Object System.Management.Automation.PSCredential($WebAppPoolGroup.Settings.WebAppSvcAct, $WebAppSvcPwdSecure)
                
                    $RestartScheduleStart = $WebAppPoolGroup.Settings.RestartSchedule
                    if (!([string]::IsNullOrEmpty($Node.IPAddress)))
                    {
                        $Multiplier = [int]($Node.IPAddress).Substring(($Node.IPAddress).Length - 1)
                    }
                    else
                    {
                        $Multiplier = 1
                    }
                    $timeOffset = New-TimeSpan -Minutes ($Multiplier * 10)
                    $RestartSchedule = ($RestartScheduleStart + $timeOffset).ToString()

                    xWebAppPool $WebAppName
                    {
                        Name                  = $WebAppPool
                        AutoStart             = $WebAppPoolGroup.Settings.AutoStart
                        State                 = $WebAppPoolGroup.Settings.State
                        startMode             = $WebAppPoolGroup.Settings.startMode
                        ManagedPipelineMode   = $WebAppPoolGroup.Settings.ManagedPipelineMode
                        ManagedRuntimeVersion = $WebAppPoolGroup.Settings.ManagedRuntimeVersion
                        IdentityType          = $WebAppPoolGroup.Settings.IdentityType
                        Credential            = $WebAppSvcCred
                        Enable32BitAppOnWin64 = $WebAppPoolGroup.Settings.Enable32BitAppOnWin64
                        RestartSchedule       = $RestartSchedule
                        IdleTimeout           = $WebAppPoolGroup.Settings.IdleTimeout
                        RestartTimeLimit      = $WebAppPoolGroup.Settings.RestartTimeLimit
                        DependsOn             = $WebAppPoolGroup.Settings.DependsOn
                    }
                }
                else
                {
                    xWebAppPool $WebAppName
                    {
                        Name                  = $WebAppPool
                        AutoStart             = $WebAppPoolGroup.Settings.AutoStart
                        State                 = $WebAppPoolGroup.Settings.State
                        startMode             = $WebAppPoolGroup.Settings.startMode
                        ManagedPipelineMode   = $WebAppPoolGroup.Settings.ManagedPipelineMode
                        ManagedRuntimeVersion = $WebAppPoolGroup.Settings.ManagedRuntimeVersion
                        IdentityType          = $WebAppPoolGroup.Settings.IdentityType
                        Enable32BitAppOnWin64 = $WebAppPoolGroup.Settings.Enable32BitAppOnWin64
                        RestartSchedule       = $WebAppPoolGroup.Settings.RestartSchedule
                        IdleTimeout           = $WebAppPoolGroup.Settings.IdleTimeout
                        RestartTimeLimit      = $WebAppPoolGroup.Settings.RestartTimeLimit
                        DependsOn             = $WebAppPoolGroup.Settings.DependsOn
                    }
                }
            }
        }

        #================== Configure WebSites ==================
        File $WebSiteName 
        {
            Ensure          = "Present"
            Type            = "Directory"
            DestinationPath = $WebSite.PhysicalPath
            DependsOn       = "[WindowsFeature]Web-WebServer"
        }
        Write-Verbose "Creating $WebSiteName"
        xWebSite $WebSiteName
        {
            Name            = $WebSite.Name
            Ensure          = $WebSite.Ensure
            State           = $WebSite.State
            ApplicationPool = $WebSite.ApplicationPool
            PhysicalPath    = $WebSite.PhysicalPath
            LogPath         = $WebSite.LogPath
            DependsOn       = $WebSite.DependsOn
            BindingInfo =
            @(
                foreach ($hostName in $WebSite.HTTPHostname)
                {
                    MSFT_xWebBindingInformation
                    {
                        Protocol  = $WebSite.HTTPProtocol
                        Port      = $WebSite.HTTPPort
                        Hostname  = $hostName
                        IPAddress = "*"
                    } 
                }
                foreach ($sslHostNames in $WebSite.HTTPSHostnames)
                {
                    $Cert = $ConfigurationData.NonNodeData.Certs.Where{$_.Name -eq $sslHostNames.Certificate}
                    foreach ($sslHostName in $sslHostNames.Names)
                    {
                        MSFT_xWebBindingInformation
                        {
                            Protocol              = $WebSite.HTTPSProtocol
                            Port                  = $WebSite.HTTPSPort
                            HostName              = $sslHostName
                            IPAddress             = "*"
                            CertificateStoreName  = $WebSite.CertificateStoreName
                            CertificateThumbprint = $Cert.Thumbprint
                            SSLFlags              = $WebSite.SSLFlags
                        } 
                    }
                }
            ) 
        }
    
        #================== Configure Web Applications ==================
        foreach ($WebApplication in $WebSite.WebApplications) 
        {
            Write-Verbose "Creating WebApplication $WebApplicationName"
            $WebApplicationName = $WebSite.Name + "_" + ($WebApplication.Name).Replace("/", "") + "_App"
            $WebApplicationPath = $WebSite.Name + "_" + $WebApplication.PhysicalPath + "_WebAppPath"
            $FolderName = $WebApplicationName + $WebApplication.PhysicalPath + "_WebAppPath"

            File $FolderName 
            {
                Ensure          = "Present"
                Type            = "Directory"
                DestinationPath = $WebApplication.PhysicalPath
            }
            
            xWebApplication $WebApplicationName
            {
                Name         = $WebApplication.Name
                Ensure       = $WebApplication.Ensure
                Website      = $WebSite.Name
                PhysicalPath = $WebApplication.PhysicalPath
                WebAppPool   = $WebApplication.WebAppPool
                DependsOn    = "[xWebAppPool]" + $WebApplication.WebAppPool + "_Pool"
            }
        }

        #================== Remove Deprecated Folders ==================
        foreach ($folder in $WebSite.DeprecatedFolders) 
        {
            File $folder 
            {
                Ensure          = "Absent"
                Type            = "Directory"
                DestinationPath = $folder
                Force           = $true
                Recurse         = $true
            }
        }
    }
    
    #================== Initial Web Deploy ==================
    Write-Verbose "Web Deploy"
    if ($StagingServer -like "*-STG*") 
    {
        Script DeployWS 
        {
            TestScript           = 
            {
                Test-Path -Path "HKLM:\SOFTWARE\DSC-Software\WebDeployPkgInstalled"
            }
            SetScript            = 
            {
                $MSDeployPath = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy" | Select-Object -Last 1).GetValue("InstallPath") + 'msdeploy.exe'
                & $msDeployPath "-verb:sync", "-source:webServer,computerName=$using:StagingServerQ,includeACLs=true" "-dest:webServer,ComputerName=""localhost"""
                if ($LASTEXITCODE -eq 0)
                {
                    New-Item -Path "HKLM:\SOFTWARE\DSC-Software\WebDeployPkgInstalled" -Force
                }
            }
            GetScript            = {@{Result = "DeployWS"}
            }
            DependsOn            = "[Package]InstallWebDeploy"
            #PsDscRunAsCredential = $credential
        }
    }

    #================== IIS Global Configuration ==================
    Write-Verbose "IIS Logging"
    xIISLogging Logging
    {
        LogPath              = 'C:\LogFiles'
        Logflags             = @('Date', 'Time', 'ClientIP', 'UserName', 'SiteName', 'ComputerName', 'ServerIP', 'Method', 'UriStem', 'UriQuery', 'HttpStatus', 'Win32Status', 'BytesSent', 'BytesRecv', 'TimeTaken', 'ServerPort', 'UserAgent', 'Referer', 'ProtocolVersion', 'Host', 'HttpSubStatus')
        LoglocalTimeRollover = $true
        LogPeriod            = 'Hourly'
        LogFormat            = 'W3C'
        DependsOn            = "[WindowsFeature]Web-WebServer"
    }

    Write-Verbose "IISLogHeaders"
    Script IISLogHeaders 
    {
        TestScript = 
        {
            if ((Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/siteDefaults/logFile/customFields" -name "Collection"))
            { 
                $logfields = (Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/siteDefaults/logFile/customFields" -name "Collection").logfieldname
                if ($logfields -contains "CF-Connecting-IP" -and $logfields -contains "X-ClientSide")
                {
                    return $true
                }
                else
                {
                    return $false
                }
            }
            else 
            { 
                return $false 
            }
        }
        SetScript  = 
        {
            Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/siteDefaults/logFile/customFields" -name "." -value @{logFieldName = 'CF-Connecting-IP'; sourceName = 'CF-Connecting-IP'; sourceType = 'RequestHeader'} -Verbose
            Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/siteDefaults/logFile/customFields" -name "." -value @{logFieldName = 'X-ClientSide'; sourceName = 'X-ClientSide'; sourceType = 'RequestHeader'} -Verbose   
        }
        GetScript  = {@{Result = "IISLogHeaders"}
        }
        DependsOn  = "[WindowsFeature]Web-WebServer"
    }

    #================== Remove x-powered-by ==================
    Write-Verbose "RemoveXPoweredBy"
    Script RemoveXPoweredBy 
    {
        TestScript = 
        {
            $wyd = (Get-WebConfiguration //httpProtocol/customHeaders | Select-Object -Expand Collection).where{$_.name -eq "x-powered-by"}
            if ($wyd)
            {
                return $false
            }
            else
            {
                return $true
            }
        }
        SetScript  = 
        {
            Clear-WebConfiguration "/system.webServer/httpProtocol/customHeaders/add[@name='X-Powered-By']" -Force
        }
        GetScript  = {@{Result = "RemoveXPoweredBy"}
        }
    }

    #================== Remove Server Header ==================
    Write-Verbose "RemoveServerHeader"
    Script RemoveServerHeader 
    {
        TestScript = 
        {
            (Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/security/requestFiltering" -name "removeServerHeader").Value
        }
        SetScript  = 
        {
            Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/security/requestFiltering" -name "removeServerHeader" -value "True"
        }
        GetScript  = {@{Result = "RemoveServerHeader"}
        }
    }

    #================== Remove x-aspnet-version ==================
    Write-Verbose "RemoveASPnetHeader"
    Script RemoveASPnetHeader 
    {
        TestScript = 
        {
            Get-IISConfigSection -SectionPath "system.web/httpRuntime" | Get-IISConfigAttributeValue -AttributeName "enableVersionHeader"
        }
        SetScript  = 
        {
            Get-IISConfigSection -SectionPath "system.web/httpRuntime" | Set-IISConfigAttributeValue -AttributeName "enableVersionHeader" -AttributeValue $false
        }
        GetScript  = {@{Result = "RemoveASPnetHeader"}
        }
    }

    #================== Rewrite x-aspnetmvc-version ==================
    Write-Verbose "RewriteASPnetMVCHeader"
    Script RewriteASPnetMVCHeader 
    {
        TestScript = 
        {
            if (-not(Get-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundrules/rule[@name='RESPONSE_X-AspNetMvc-Version']" -name "."))
            {
                return $false
            }
            else
            {
                return $true
            }
        }
        SetScript  = 
        {
            Add-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundrules" -name "." -value @{name = 'RESPONSE_X-AspNetMvc-Version'}
            Set-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundRules/rule[@name='RESPONSE_X-AspNetMvc-Version']/match" -name "serverVariable" -value "RESPONSE_X-AspNetMvc-Version"
            Set-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundRules/rule[@name='RESPONSE_X-AspNetMvc-Version']/match" -name "pattern" -value ".*"
            Set-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundRules/rule[@name='RESPONSE_X-AspNetMvc-Version']/action" -name "type" -value "Rewrite"
            Set-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundRules/rule[@name='RESPONSE_X-AspNetMvc-Version']/action" -name "value" -value ""
        }
        GetScript  = {@{Result = "RewriteASPnetMVCHeader"}
        }
    }

    #================== Rewrite Server Header ==================
    Write-Verbose "RewriteServerHeader"
    Script RewriteServerHeader 
    {
        TestScript = 
        {
            if (-not(Get-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundrules/rule[@name='RESPONSE_SERVER']" -name "."))
            {
                return $false
            }
            else
            {
                return $true
            }
        }
        SetScript  = 
        {
            Add-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundrules" -name "." -value @{name = 'RESPONSE_SERVER'}
            Set-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundRules/rule[@name='RESPONSE_SERVER']/match" -name "serverVariable" -value "RESPONSE_SERVER"
            Set-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundRules/rule[@name='RESPONSE_SERVER']/match" -name "pattern" -value ".*"
            Set-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundRules/rule[@name='RESPONSE_SERVER']/action" -name "type" -value "Rewrite"
            Set-WebConfigurationProperty -pspath "iis:\" -filter "system.webServer/rewrite/outboundRules/rule[@name='RESPONSE_SERVER']/action" -name "value" -value ""
        }
        GetScript  = {@{Result = "RewriteServerHeader"}
        }
    }
}
