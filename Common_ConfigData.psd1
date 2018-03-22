@{ 
    # Node specific data 
    AllNodes    = @(
        @{ 
            NodeName        = '*'
            TimeZone        = 'Eastern Standard Time'
            DesktopEdition  = 'FullGUI'      
            CertificateFile = "C:\publicKeys\DscPublicKey.cer"
            Thumbprint      = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        }
    )

    NonNodeData = @{
        DataCenters = @(
            @{
                Name        = 'Houston'
                WSUS        = 'https://hou-wsus-01.int.contoso.com:8531'
                StaticRoute = @(
                    @{
                        DestinationPrefix = '10.1.2.0/24'
                        NextHop           = '10.1.1.254'
                        RouteMetric       = 1
                    }
                )
                Networks    = @(
                    @{ 
                        Domain    = 'Internal'
                        DNSOrder  = '10.1.1.66', '10.1.1.71', '10.2.1.20', '10.2.1.43'
                        DefaultGW = '10.1.1.1'                        
                    }
                    @{ 
                        Domain    = 'DMZ'
                        DNSOrder  = '10.1.2.3', '10.1.2.4', '10.2.2.5', '10.2.2.6'
                        DefaultGW = '10.1.2.254'                   
                    }
                )
            }
            
            @{
                Name        = 'NewYork'
                WSUS        = 'https://ny-wsus-01.int.contoso.com:8531'
                StaticRoute = @(
                    @{
                        DestinationPrefix = '10.2.2.0/24'
                        NextHop           = '10.2.1.254'
                        RouteMetric       = 1
                    }
                )
                Networks    = @(
                    @{ 
                        Domain    = 'Internal'
                        DNSOrder  = '10.2.1.20', '10.2.1.43', '10.1.1.66', '10.1.1.71'
                        DefaultGW = '10.2.1.1'         
                    }
                    @{ 
                        Domain    = 'DMZ'
                        DNSOrder  = '10.2.2.5', '10.2.2.6', '10.1.2.3', '10.1.2.4'
                        DefaultGW = '10.2.2.254'           
                    }
                )
            }
        )    

        Domains     = @(
            @{
                Name                     = 'Internal'
                ConnectionSpecificSuffix = 'int.contoso.com'
                FileShare                = '\\int.contoso.com\shares\dsc'
                FeatureSource            = '\\int.contoso.com\shares\deploy\win2016\sources'      
            }
    
            @{
                Name                     = 'DMZ'
                ConnectionSpecificSuffix = 'dmz.contoso.com'
                FileShare                = '\\dmz.contoso.com\shares\dsc'
                FeatureSource            = '\\dmz.contoso.com\shares\deploy\win2016\sources\sxs'     
            }
        ) 

        Roles       = @(
            @{
                Name            = 'Web-Server'
                WindowsFeatures = @(
                    "NET-Framework-Features",
                    "NET-Framework-Core",
                    "NET-Framework-45-Features",
                    "NET-Framework-45-Core",
                    "NET-Framework-45-ASPNET",
                    "NET-WCF-Services45",
                    "NET-WCF-HTTP-Activation45",
                    "NET-WCF-MSMQ-Activation45",
                    "NET-WCF-Pipe-Activation45",
                    "NET-WCF-TCP-Activation45",
                    "NET-WCF-TCP-PortSharing45",
                    "Web-Server",
                    "FileAndStorage-Services",
                    "File-Services",
                    "FS-FileServer",
                    "Storage-Services",
                    "Web-WebServer",
                    "Web-Common-Http",
                    "Web-Default-Doc",
                    "Web-Dir-Browsing",
                    "Web-Http-Errors",
                    "Web-Static-Content",
                    "Web-Http-Redirect",
                    "Web-Health",
                    "Web-Http-Logging",
                    "Web-Log-Libraries",
                    "Web-ODBC-Logging",
                    "Web-Request-Monitor",
                    "Web-Http-Tracing",
                    "Web-Performance",
                    "Web-Stat-Compression",
                    "Web-Security",
                    "Web-Filtering",
                    "Web-Basic-Auth",
                    "Web-App-Dev",
                    "Web-Net-Ext",
                    "Web-Net-Ext45",
                    "Web-ASP",
                    "Web-Asp-Net",
                    "Web-Asp-Net45",
                    "Web-CGI",
                    "Web-ISAPI-Ext",
                    "Web-ISAPI-Filter",
                    "Web-Includes",
                    "Web-Mgmt-Tools",
                    "Web-Mgmt-Compat",
                    "Web-Metabase",
                    "Web-Lgcy-Scripting",
                    "Web-WMI",
                    "Web-Mgmt-Service",
                    "MSMQ",
                    "MSMQ-Services",
                    "MSMQ-Server",
                    "FS-SMB1",
                    "Telnet-Client",
                    "PowerShellRoot",
                    "PowerShell",
                    "PowerShell-V2",
                    "WAS",
                    "WAS-Process-Model",
                    "WAS-Config-APIs",
                    "WoW64-Support"
                )
            }
            @{
                Name            = 'SQL'
                WindowsFeatures = @(
                    "Failover-Clustering",
                    "FileAndStorage-Services",
                    "File-Services",
                    "FS-FileServer",
                    "Storage-Services",
                    "NET-Framework-Features",
                    "NET-Framework-Core",
                    "NET-Framework-45-Features",
                    "NET-Framework-45-Core",
                    "NET-WCF-Services45",
                    "NET-WCF-TCP-PortSharing45",
                    "RSAT-AD-PowerShell",
                    "RSAT-Clustering",
                    "RSAT-Clustering-Mgmt",
                    "RSAT-Clustering-PowerShell"
                )
            }
    
            @{
                Name            = 'FileServer'
                WindowsFeatures = @(
                    "FileAndStorage-Services",
                    "File-Services",
                    "FS-FileServer",
                    "FS-Data-Deduplication",
                    "FS-DFS-Namespace",
                    "FS-DFS-Replication",
                    "FS-Resource-Manager",
                    "Storage-Services",
                    "NET-Framework-45-Features",
                    "NET-Framework-45-Core",
                    "NET-Framework-45-ASPNET",
                    "NET-WCF-Services45",
                    "NET-WCF-MSMQ-Activation45",
                    "NET-WCF-Pipe-Activation45",
                    "NET-WCF-TCP-Activation45",
                    "NET-WCF-TCP-PortSharing45",
                    "Failover-Clustering",
                    "MSMQ",
                    "MSMQ-Services",
                    "MSMQ-Server",
                    "MSMQ-Directory",
                    "Multipath-IO",
                    "RDC",
                    "RSAT",
                    "RSAT-Feature-Tools",
                    "RSAT-SMTP",
                    "RSAT-Clustering",
                    "RSAT-Clustering-Mgmt",
                    "RSAT-Clustering-PowerShell",
                    "RSAT-Role-Tools",
                    "RSAT-AD-Tools",
                    "RSAT-AD-PowerShell",
                    "RSAT-ADDS",
                    "RSAT-AD-AdminCenter",
                    "RSAT-ADDS-Tools",
                    "RSAT-ADLDS",
                    "UpdateServices-RSAT",
                    "UpdateServices-API",
                    "UpdateServices-UI",
                    "RSAT-File-Services",
                    "RSAT-FSRM-Mgmt",
                    "PowerShellRoot",
                    "PowerShell",
                    "PowerShell-ISE",
                    "WAS",
                    "WAS-Process-Model",
                    "WAS-NET-Environment",
                    "WAS-Config-APIs",
                    "WoW64-Support"
                )
            }
            @{
                Name            = 'DomainController'
                WindowsFeatures = @(
                    "AD-Domain-Services",
                    "DNS",
                    "GPMC",
                    "RSAT-AD-Tools",
                    "RSAT-AD-PowerShell",
                    "RSAT-ADDS",
                    "RSAT-AD-AdminCenter",
                    "RSAT-ADDS-Tools",
                    "RSAT-DNS-Server"
                )
            }
        ) 

        Products    = @(
            @{
                Name           = 'Consumer'
                SQLCert        = 'CSSQLCL'
                SQLgmsa        = 'CS-SQL-SVC'
                SQLLocalAdmins = @('INTERNAL\DBA')
                SQLListener    = 'cs-sql-cl.int.contoso.com'
                DataCenters    = @(
                    @{
                        Name       = 'Houston'
                        WebStaging = 'CS-HOU-WS-STG.dmz.contoso.com'
                    }
                    @{
                        Name       = 'NewYork'
                        WebStaging = 'CS-NY-WS-STG.dmz.contoso.com'
                    }
                )
            }
            @{
                Name           = 'SaaS'
                SQLCert        = 'SASQLCL'
                SQLgmsa        = 'SA-SQL-SVC'
                SQLLocalAdmins = @('INTERNAL\DBA')
                SQLListener    = 'sa-sql-cl.int.contoso.com'
                DataCenters    = @(
                    @{
                        Name       = 'Houston'
                        WebStaging = 'SA-HOU-WS-STG.dmz.contoso.com'
                    }
                    @{
                        Name       = 'NewYork'
                        WebStaging = 'SA-NY-WS-STG.dmz.contoso.com'
                    }
                )
            }
        )

        Packages    = @(
            @{
                PackageName     = 'OSSEC'
                Version         = "2.8.3"
                Name            = "OSSEC HIDS 2.8.3"
                FileName        = "ossec-agent-win32-2.8.3.exe"      
                DestinationPath = "C:\temp\ossec-agent-win32-2.8.3.exe"
            }
            @{
                PackageName        = 'Tentacle'
                Version            = "3.14.159"
                FileName           = "Octopus.Tentacle.3.14.159-x64.msi"
                ProductID          = "{E6BBA549-82C2-44F2-BB0D-C13E13D0A037}"
                DeployRoot         = 'C:\Octopus\DSC'
                RegistrationUri    = 'https://octopusdeploy.int.contoso.com'
                RegistrationApiKey = 'API-XXXXXXXXXXXXXXXXXXXXXXXX'
            }
        )

        Certs       = @(
            @{
                Name       = 'ContosoCorp'
                FileName   = 'ContosoCorp.pfx'
                Thumbprint = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                Password   = @'
                -----BEGIN CMS-----
                MIIBqAYJKoZIhvcNAQcDoIIBmTCCAZUCAQAxggFQMIIBTAIBADA0MCAxHjAcBgNVBAMMFWxlZWhv
                bG1AbWljcm9zb2Z0LmNvbQIQQYHsbcXnjIJCtH+OhGmc1DANBgkqhkiG9w0BAQcwAASCAQAnkFHM
                proJnFy4geFGfyNmxH3yeoPvwEYzdnsoVqqDPAd8D3wao77z7OhJEXwz9GeFLnxD6djKV/tF4PxR
                E27aduKSLbnxfpf/sepZ4fUkuGibnwWFrxGE3B1G26MCenHWjYQiqv+Nq32Gc97qEAERrhLv6S4R
                G+2dJEnesW8A+z9QPo+DwYU5FzD0Td0ExrkswVckpLNR6j17Yaags3ltNVmbdEXekhi6Psf2MLMP
                TSO79lv2L0KeXFGuPOrdzPAwCkV0vNEqTEBeDnZGrjv/5766bM3GW34FXApod9u+VSFpBnqVOCBA
                DVDraA6k+xwBt66cV84OHLkh0kT02SIHMDwGCSqGSIb3DQEHATAdBglghkgBZQMEASoEEJbJaiRl
                KMnBoD1dkb/FzSWAEBaL8xkFwCu0e1ZtDj7nSJc=
                -----END CMS-----
'@   
            }
            @{
                Name       = 'ContosoWildCard'
                FileName   = 'ContosoWildCard.pfx'
                Thumbprint = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                Password   = @'
                -----BEGIN CMS-----
                MIIBqAYJKoZIhvcNAQcDoIIBmTCCAZUCAQAxggFQMIIBTAIBADA0MCAxHjAcBgNVBAMMFWxlZWhv
                bG1AbWljcm9zb2Z0LmNvbQIQQYHsbcXnjIJCtH+OhGmc1DANBgkqhkiG9w0BAQcwAASCAQAnkFHM
                proJnFy4geFGfyNmxH3yeoPvwEYzdnsoVqqDPAd8D3wao77z7OhJEXwz9GeFLnxD6djKV/tF4PxR
                E27aduKSLbnxfpf/sepZ4fUkuGibnwWFrxGE3B1G26MCenHWjYQiqv+Nq32Gc97qEAERrhLv6S4R
                G+2dJEnesW8A+z9QPo+DwYU5FzD0Td0ExrkswVckpLNR6j17Yaags3ltNVmbdEXekhi6Psf2MLMP
                TSO79lv2L0KeXFGuPOrdzPAwCkV0vNEqTEBeDnZGrjv/5766bM3GW34FXApod9u+VSFpBnqVOCBA
                DVDraA6k+xwBt66cV84OHLkh0kT02SIHMDwGCSqGSIb3DQEHATAdBglghkgBZQMEASoEEJbJaiRl
                KMnBoD1dkb/FzSWAEBaL8xkFwCu0e1ZtDj7nSJc=
                -----END CMS-----
'@
            }
            @{
                Name       = 'SaaSWildCard'
                FileName   = 'SaaSWildCard.pfx'
                Thumbprint = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                Password   = @'
                -----BEGIN CMS-----
                MIIBqAYJKoZIhvcNAQcDoIIBmTCCAZUCAQAxggFQMIIBTAIBADA0MCAxHjAcBgNVBAMMFWxlZWhv
                bG1AbWljcm9zb2Z0LmNvbQIQQYHsbcXnjIJCtH+OhGmc1DANBgkqhkiG9w0BAQcwAASCAQAnkFHM
                proJnFy4geFGfyNmxH3yeoPvwEYzdnsoVqqDPAd8D3wao77z7OhJEXwz9GeFLnxD6djKV/tF4PxR
                E27aduKSLbnxfpf/sepZ4fUkuGibnwWFrxGE3B1G26MCenHWjYQiqv+Nq32Gc97qEAERrhLv6S4R
                G+2dJEnesW8A+z9QPo+DwYU5FzD0Td0ExrkswVckpLNR6j17Yaags3ltNVmbdEXekhi6Psf2MLMP
                TSO79lv2L0KeXFGuPOrdzPAwCkV0vNEqTEBeDnZGrjv/5766bM3GW34FXApod9u+VSFpBnqVOCBA
                DVDraA6k+xwBt66cV84OHLkh0kT02SIHMDwGCSqGSIb3DQEHATAdBglghkgBZQMEASoEEJbJaiRl
                KMnBoD1dkb/FzSWAEBaL8xkFwCu0e1ZtDj7nSJc=
                -----END CMS-----
'@
            }

            @{
                Name       = 'OnlineSaaSWildCard'
                FileName   = 'OnlineSaaSWildCard.pfx'
                Thumbprint = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                Password   = @'
                -----BEGIN CMS-----
                MIIBqAYJKoZIhvcNAQcDoIIBmTCCAZUCAQAxggFQMIIBTAIBADA0MCAxHjAcBgNVBAMMFWxlZWhv
                bG1AbWljcm9zb2Z0LmNvbQIQQYHsbcXnjIJCtH+OhGmc1DANBgkqhkiG9w0BAQcwAASCAQAnkFHM
                proJnFy4geFGfyNmxH3yeoPvwEYzdnsoVqqDPAd8D3wao77z7OhJEXwz9GeFLnxD6djKV/tF4PxR
                E27aduKSLbnxfpf/sepZ4fUkuGibnwWFrxGE3B1G26MCenHWjYQiqv+Nq32Gc97qEAERrhLv6S4R
                G+2dJEnesW8A+z9QPo+DwYU5FzD0Td0ExrkswVckpLNR6j17Yaags3ltNVmbdEXekhi6Psf2MLMP
                TSO79lv2L0KeXFGuPOrdzPAwCkV0vNEqTEBeDnZGrjv/5766bM3GW34FXApod9u+VSFpBnqVOCBA
                DVDraA6k+xwBt66cV84OHLkh0kT02SIHMDwGCSqGSIb3DQEHATAdBglghkgBZQMEASoEEJbJaiRl
                KMnBoD1dkb/FzSWAEBaL8xkFwCu0e1ZtDj7nSJc=
                -----END CMS-----
'@      
            }
            @{
                Name       = 'CSSQLCL'
                FileName   = 'CSSQLCL.pfx'
                Thumbprint = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                Password   = @'
                -----BEGIN CMS-----
                MIIBqAYJKoZIhvcNAQcDoIIBmTCCAZUCAQAxggFQMIIBTAIBADA0MCAxHjAcBgNVBAMMFWxlZWhv
                bG1AbWljcm9zb2Z0LmNvbQIQQYHsbcXnjIJCtH+OhGmc1DANBgkqhkiG9w0BAQcwAASCAQAnkFHM
                proJnFy4geFGfyNmxH3yeoPvwEYzdnsoVqqDPAd8D3wao77z7OhJEXwz9GeFLnxD6djKV/tF4PxR
                E27aduKSLbnxfpf/sepZ4fUkuGibnwWFrxGE3B1G26MCenHWjYQiqv+Nq32Gc97qEAERrhLv6S4R
                G+2dJEnesW8A+z9QPo+DwYU5FzD0Td0ExrkswVckpLNR6j17Yaags3ltNVmbdEXekhi6Psf2MLMP
                TSO79lv2L0KeXFGuPOrdzPAwCkV0vNEqTEBeDnZGrjv/5766bM3GW34FXApod9u+VSFpBnqVOCBA
                DVDraA6k+xwBt66cV84OHLkh0kT02SIHMDwGCSqGSIb3DQEHATAdBglghkgBZQMEASoEEJbJaiRl
                KMnBoD1dkb/FzSWAEBaL8xkFwCu0e1ZtDj7nSJc=
                -----END CMS-----
'@      
            }
            @{
                Name       = 'SASQLCL'
                FileName   = 'SASQLCL.pfx'
                Thumbprint = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                Password   = @'
                -----BEGIN CMS-----
                MIIBqAYJKoZIhvcNAQcDoIIBmTCCAZUCAQAxggFQMIIBTAIBADA0MCAxHjAcBgNVBAMMFWxlZWhv
                bG1AbWljcm9zb2Z0LmNvbQIQQYHsbcXnjIJCtH+OhGmc1DANBgkqhkiG9w0BAQcwAASCAQAnkFHM
                proJnFy4geFGfyNmxH3yeoPvwEYzdnsoVqqDPAd8D3wao77z7OhJEXwz9GeFLnxD6djKV/tF4PxR
                E27aduKSLbnxfpf/sepZ4fUkuGibnwWFrxGE3B1G26MCenHWjYQiqv+Nq32Gc97qEAERrhLv6S4R
                G+2dJEnesW8A+z9QPo+DwYU5FzD0Td0ExrkswVckpLNR6j17Yaags3ltNVmbdEXekhi6Psf2MLMP
                TSO79lv2L0KeXFGuPOrdzPAwCkV0vNEqTEBeDnZGrjv/5766bM3GW34FXApod9u+VSFpBnqVOCBA
                DVDraA6k+xwBt66cV84OHLkh0kT02SIHMDwGCSqGSIb3DQEHATAdBglghkgBZQMEASoEEJbJaiRl
                KMnBoD1dkb/FzSWAEBaL8xkFwCu0e1ZtDj7nSJc=
                -----END CMS-----
'@      
            }
        )

        Creds       = @(
            @{
                Name     = 'INTERNAL\svc_web'
                Password = @'
                -----BEGIN CMS-----
                MIIBqAYJKoZIhvcNAQcDoIIBmTCCAZUCAQAxggFQMIIBTAIBADA0MCAxHjAcBgNVBAMMFWxlZWhv
                bG1AbWljcm9zb2Z0LmNvbQIQQYHsbcXnjIJCtH+OhGmc1DANBgkqhkiG9w0BAQcwAASCAQAnkFHM
                proJnFy4geFGfyNmxH3yeoPvwEYzdnsoVqqDPAd8D3wao77z7OhJEXwz9GeFLnxD6djKV/tF4PxR
                E27aduKSLbnxfpf/sepZ4fUkuGibnwWFrxGE3B1G26MCenHWjYQiqv+Nq32Gc97qEAERrhLv6S4R
                G+2dJEnesW8A+z9QPo+DwYU5FzD0Td0ExrkswVckpLNR6j17Yaags3ltNVmbdEXekhi6Psf2MLMP
                TSO79lv2L0KeXFGuPOrdzPAwCkV0vNEqTEBeDnZGrjv/5766bM3GW34FXApod9u+VSFpBnqVOCBA
                DVDraA6k+xwBt66cV84OHLkh0kT02SIHMDwGCSqGSIb3DQEHATAdBglghkgBZQMEASoEEJbJaiRl
                KMnBoD1dkb/FzSWAEBaL8xkFwCu0e1ZtDj7nSJc=
                -----END CMS-----
'@
            }
            @{
                Name     = 'INTERNAL\CS-SQL-SVC'
                Password = @'
                -----BEGIN CMS-----
                MIIBqAYJKoZIhvcNAQcDoIIBmTCCAZUCAQAxggFQMIIBTAIBADA0MCAxHjAcBgNVBAMMFWxlZWhv
                bG1AbWljcm9zb2Z0LmNvbQIQQYHsbcXnjIJCtH+OhGmc1DANBgkqhkiG9w0BAQcwAASCAQAnkFHM
                proJnFy4geFGfyNmxH3yeoPvwEYzdnsoVqqDPAd8D3wao77z7OhJEXwz9GeFLnxD6djKV/tF4PxR
                E27aduKSLbnxfpf/sepZ4fUkuGibnwWFrxGE3B1G26MCenHWjYQiqv+Nq32Gc97qEAERrhLv6S4R
                G+2dJEnesW8A+z9QPo+DwYU5FzD0Td0ExrkswVckpLNR6j17Yaags3ltNVmbdEXekhi6Psf2MLMP
                TSO79lv2L0KeXFGuPOrdzPAwCkV0vNEqTEBeDnZGrjv/5766bM3GW34FXApod9u+VSFpBnqVOCBA
                DVDraA6k+xwBt66cV84OHLkh0kT02SIHMDwGCSqGSIb3DQEHATAdBglghkgBZQMEASoEEJbJaiRl
                KMnBoD1dkb/FzSWAEBaL8xkFwCu0e1ZtDj7nSJc=
                -----END CMS-----
'@
            }
            @{
                Name     = 'INTERNAL\SA-SQL-SVC'
                Password = @'
                -----BEGIN CMS-----
                MIIBqAYJKoZIhvcNAQcDoIIBmTCCAZUCAQAxggFQMIIBTAIBADA0MCAxHjAcBgNVBAMMFWxlZWhv
                bG1AbWljcm9zb2Z0LmNvbQIQQYHsbcXnjIJCtH+OhGmc1DANBgkqhkiG9w0BAQcwAASCAQAnkFHM
                proJnFy4geFGfyNmxH3yeoPvwEYzdnsoVqqDPAd8D3wao77z7OhJEXwz9GeFLnxD6djKV/tF4PxR
                E27aduKSLbnxfpf/sepZ4fUkuGibnwWFrxGE3B1G26MCenHWjYQiqv+Nq32Gc97qEAERrhLv6S4R
                G+2dJEnesW8A+z9QPo+DwYU5FzD0Td0ExrkswVckpLNR6j17Yaags3ltNVmbdEXekhi6Psf2MLMP
                TSO79lv2L0KeXFGuPOrdzPAwCkV0vNEqTEBeDnZGrjv/5766bM3GW34FXApod9u+VSFpBnqVOCBA
                DVDraA6k+xwBt66cV84OHLkh0kT02SIHMDwGCSqGSIb3DQEHATAdBglghkgBZQMEASoEEJbJaiRl
                KMnBoD1dkb/FzSWAEBaL8xkFwCu0e1ZtDj7nSJc=
                -----END CMS-----
'@          
            }
            @{
                Name     = 'LocalFSNUser'
                Password = @'
                -----BEGIN CMS-----
                MIIBqAYJKoZIhvcNAQcDoIIBmTCCAZUCAQAxggFQMIIBTAIBADA0MCAxHjAcBgNVBAMMFWxlZWhv
                bG1AbWljcm9zb2Z0LmNvbQIQQYHsbcXnjIJCtH+OhGmc1DANBgkqhkiG9w0BAQcwAASCAQAnkFHM
                proJnFy4geFGfyNmxH3yeoPvwEYzdnsoVqqDPAd8D3wao77z7OhJEXwz9GeFLnxD6djKV/tF4PxR
                E27aduKSLbnxfpf/sepZ4fUkuGibnwWFrxGE3B1G26MCenHWjYQiqv+Nq32Gc97qEAERrhLv6S4R
                G+2dJEnesW8A+z9QPo+DwYU5FzD0Td0ExrkswVckpLNR6j17Yaags3ltNVmbdEXekhi6Psf2MLMP
                TSO79lv2L0KeXFGuPOrdzPAwCkV0vNEqTEBeDnZGrjv/5766bM3GW34FXApod9u+VSFpBnqVOCBA
                DVDraA6k+xwBt66cV84OHLkh0kT02SIHMDwGCSqGSIb3DQEHATAdBglghkgBZQMEASoEEJbJaiRl
                KMnBoD1dkb/FzSWAEBaL8xkFwCu0e1ZtDj7nSJc=
                -----END CMS-----
'@          
            }
        )

        WebSites    = @(
            #================== 'www.contosocorp.com' Site Configuration ==================
            @{
                Name                  = "www.contosocorp.com"
                Ensure                = "Present"
                State                 = "Started"
                ApplicationPool       = "www.contosocorp.com"
                PhysicalPath          = "D:\inetpub\www.contosocorp.com\contosocorp.com"
                LogPath               = "D:\LogFiles"
                DependsOn             = @('[xWebAppPool]www.contosocorp.com_Pool', '[xPfxImport]ContosoCorp')
                HTTPProtocol          = 'http'
                HTTPPort              = '80'
                HTTPHostname          = ''
                HTTPSProtocol         = 'https'
                HTTPSPort             = '443'
                HTTPSHostnames        = @(
                    @{
                        Names       = ''
                        Certificate = "ContosoCorp"
                    }
                )
                CertificateStoreName  = 'MY'
                SslFlags              = '0'
                HostsFile             = @("contosocorp.com", "www.contosocorp.com")
                DeprecatedFolders     = @("D:\inetpub\www.contosocorp.com\old", "D:\inetpub\www.contosocorp.com\old2")
                WebVirtualDirectories = @(
                    @{
                        Name           = "PartnerPortal/api"
                        Ensure         = "Present"
                        PhysicalPath   = "D:\inetpub\www.contosocorp.com\PartnerPortal\api"
                        WebApplication = ""
                    }
                    @{
                        Name           = "Support"
                        Ensure         = "Present"
                        PhysicalPath   = "D:\inetpub\www.contosocorp.com\support"
                        WebApplication = ""
                    }
                )
                WebAppPools           = @(
                    @{
                        Names    = @("www.contosocorp.com")
                        Settings = @{ 
                            AutoStart             = $true
                            State                 = "Started"
                            ManagedPipelineMode   = "Integrated"
                            ManagedRuntimeVersion = "v4.0"
                            IdentityType          = "SpecificUser"
                            WebAppSvcAct          = "INTERNAL\svc_web"
                            Enable32BitAppOnWin64 = $false
                            RestartSchedule       = New-TimeSpan -Hours 4 -Minutes 0
                            IdleTimeout           = (New-TimeSpan -Minutes 0).ToString()
                            RestartTimeLimit      = "00:00:00"
                            startMode             = "AlwaysRunning"
                            DependsOn             = "[WindowsFeature]Web-WebServer"
                        }
                    }
                    @{
                        Names    = @("Support")
                        Settings = @{ 
                            AutoStart             = $true
                            State                 = "Started"
                            ManagedPipelineMode   = "Integrated"
                            ManagedRuntimeVersion = "v4.0"
                            IdentityType          = "SpecificUser"
                            WebAppSvcAct          = "INTERNAL\svc_web"
                            Enable32BitAppOnWin64 = $true
                            RestartSchedule       = New-TimeSpan -Hours 4 -Minutes 0
                            IdleTimeout           = (New-TimeSpan -Minutes 0).ToString()
                            RestartTimeLimit      = "00:00:00"
                            startMode             = "AlwaysRunning"
                            DependsOn             = "[WindowsFeature]Web-WebServer"
                        }
                    }
                )
                WebApplications       = @(
                    @{
                        Name         = "PartnerPortal"
                        Ensure       = "Present"
                        PhysicalPath = "D:\inetpub\www.contosocorp.com\PartnerPortal"
                        WebAppPool   = "www.contosocorp.com"
                    }
                    @{
                        Name         = "support"
                        Ensure       = "Present"
                        PhysicalPath = "D:\inetpub\www.contosocorp.com\support"
                        WebAppPool   = "www.contosocorp.com"
                    }
                )
                NTFSPerms             = @(
                    @{
                        Path       = 'D:\inetpub\www.contosocorp.com'
                        Type       = 'Directory'
                        Users      = 'online\svc_spt_con'
                        Permission = 'Modify'
                    }
                )
            }
            #================== 'contoso.com' Site Configuration ==================
            @{
                Name                  = "contoso.com"
                Ensure                = "Present"
                State                 = "Started"
                ApplicationPool       = "contoso.com"
                PhysicalPath          = "D:\inetpub\contoso.com\contoso.com"
                LogPath               = "D:\LogFiles"
                DependsOn             = @('[xWebAppPool]contoso.com_Pool')
                HTTPProtocol          = 'http'
                HTTPPort              = '80'
                HTTPHostname          = @('www.contoso.com', 'contoso.com')
                HTTPSProtocol         = 'https'
                HTTPSPort             = '443'
                HTTPSHostnames        = @(
                    @{
                        Names       = @('www.contoso.com', 'contoso.com')
                        Certificate = "ContosoWildCard"
                    }
                )
                CertificateStoreName  = 'MY'
                SslFlags              = '1'
                WebVirtualDirectories = @()
                WebAppPools           = @(
                    @{
                        Names    = @("contoso.com")
                        Settings = @{ 
                            AutoStart             = $true
                            State                 = "Started"
                            ManagedPipelineMode   = "Integrated"
                            ManagedRuntimeVersion = "v4.0"
                            IdentityType          = "SpecificUser"
                            WebAppSvcAct          = "INTERNAL\svc_web"
                            Enable32BitAppOnWin64 = $false
                            RestartSchedule       = New-TimeSpan -Hours 4 -Minutes 0
                            IdleTimeout           = (New-TimeSpan -Minutes 0).ToString()
                            RestartTimeLimit      = "00:00:00"
                            startMode             = "AlwaysRunning"
                            DependsOn             = "[WindowsFeature]Web-WebServer"
                        }
                    }
                )
                WebApplications       = @(
                    @{
                        Name         = "account"
                        Ensure       = "Present"
                        PhysicalPath = "D:\inetpub\contoso.com\account"
                        WebAppPool   = "contoso.com"
                    }
                )
            }

            #================== 'saas.contoso.com' Site Configuration ==================
            @{
                Name                 = "saas.contoso.com"
                Ensure               = "Present"
                State                = "Started"
                ApplicationPool      = "saas.contoso.com"
                PhysicalPath         = "D:\inetpub\saas.contoso.com"
                LogPath              = "D:\LogFiles"
                DependsOn            = "[xWebAppPool]saas.contoso.com_Pool"
                HTTPProtocol         = 'http'
                HTTPPort             = '80'
                HTTPHostname         = @("saas.contoso.com", "rw.saas.contoso.com", "1.saas.contoso.com", "online.contoso.com")
                HTTPSProtocol        = 'https'
                HTTPSPort            = '443'
                HTTPSHostnames       = @(
                    @{
                        Names       = @("saas.contoso.com", "rw.saas.contoso.com", "1.saas.contoso.com")
                        Certificate = "SaaSWildCard"
                    }
                    @{
                        Names       = "online.contoso.com"
                        Certificate = "OnlineSaaSWildCard"
                    }
                )
                CertificateStoreName = 'MY'
                SslFlags             = '1'
                HostsFile            = @(
                    @{
                        DataCenter = "NewYork"
                        Entries    = @(
                            @{
                                Name        = "1.saas.contoso.com"
                                Destination = "127.0.0.1"
                            }
                            @{
                                Name        = "rw.saas.contoso.com"
                                Destination = "127.0.0.1"
                            }
                            @{
                                Name        = "saas.contoso.com"
                                Destination = "127.0.0.1"
                            }
                        )
                    }
                    @{
                        DataCenter = "Houston"
                        Entries    = @(
                            @{
                                Name        = "1.saas.contoso.com"
                                Destination = "127.0.0.1"
                            }
                            @{
                                Name        = "rw.saas.contoso.com"
                                Destination = "127.0.0.1"
                            }
                            @{
                                Name        = "saas.contoso.com"
                                Destination = "127.0.0.1"
                            }
                        )
                    }
                )
                DeprecatedFolders    = @()
                WebAppPools          = @(
                    @{
                        Names    = @("saas.contoso.com", "saas.contoso.com-account", "saas.contoso.com-support")
                        Settings = @{ 
                            AutoStart             = $true
                            State                 = "Started"
                            ManagedPipelineMode   = "Integrated"
                            ManagedRuntimeVersion = "v4.0"
                            IdentityType          = "SpecificUser"
                            WebAppSvcAct          = "INTERNAL\svc_web"
                            Enable32BitAppOnWin64 = $false
                            RestartSchedule       = New-TimeSpan -Hours 4 -Minutes 0
                            IdleTimeout           = (New-TimeSpan -Minutes 0).ToString()
                            RestartTimeLimit      = "00:00:00"
                            startMode             = "AlwaysRunning"
                            DependsOn             = "[WindowsFeature]Web-WebServer"
                        }
                    }
                )
                WebApplications      = @(
                    @{
                        Name         = "account"
                        Ensure       = "Present"
                        PhysicalPath = "D:\inetpub\saas.contoso.com\myaccount"
                        WebAppPool   = "saas.contoso.com-account"
                    }
                    @{
                        Name         = "support"
                        Ensure       = "Present"
                        PhysicalPath = "D:\inetpub\saas.contoso.com\support"
                        WebAppPool   = "saas.contoso.com-support"
                    }
                )
            }
        )
    }
}