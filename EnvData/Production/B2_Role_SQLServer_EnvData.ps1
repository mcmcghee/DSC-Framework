Configuration B2_Role_SQLServer_EnvData
{
    param
    (
        [Hashtable]$Node
    )

    if ($Node.Role -ine 'SQL') { return }

    #================== SQL Server Firewall Rules ==================
    xFirewall MSSQL_1433
    {
        Name        = "MSSQL"
        DisplayName = "MSSQL Inbound Port 1433"
        Ensure      = "Present"
        Action      = "Allow"
        Enabled     = "True"
        Profile     = ("Domain", "Private")
        Direction   = "InBound"
        RemotePort  = ("Any")
        LocalPort   = ("1433")
        Protocol    = "TCP"
        Description = "MSSQL Inbound Port 1433"
    }

    xFirewall MSSQL_1434
    {
        Name        = "MSSQL SQL Browser"
        DisplayName = "MSSQL SQL Browser Port 1434"
        Ensure      = "Present"
        Action      = "Allow"
        Enabled     = "True"
        Profile     = ("Domain", "Private")
        Direction   = "InBound"
        RemotePort  = ("Any")
        LocalPort   = ("1434")
        Protocol    = "TCP"
        Description = "MSSQL SQL Browser Port 1434"
    }

    xFirewall MSSQL_5022
    {
        Name        = "MSSQL Mirroring Port 5022"
        DisplayName = "MSSQL Mirroring Port 5022"
        Ensure      = "Present"
        Action      = "Allow"
        Enabled     = "True"
        Profile     = ("Domain", "Private")
        Direction   = "InBound"
        RemotePort  = ("Any")
        LocalPort   = ("5022")
        Protocol    = "TCP"
        Description = "MSSQL Mirroring Port 5022"
    }

    #================== Set Local Administrators ==================
    Group AddADUserToLocalAdminGroup_SQL
    {
        GroupName        = 'Administrators'   
        Ensure           = 'Present'             
        MembersToInclude = $Product.SQLLocalAdmins
        Credential       = $credential   
    }

    #================== GMSA SecPolicy ==================
    UserRightsAssignment PerformVolumeMaintenanceTasks
    {
        Policy               = "Perform_volume_maintenance_tasks"
        Identity             = $GMSADomain
        #PsDscRunAsCredential = $credential
    }

    UserRightsAssignment LockPagesInMemory
    {
        Policy               = "Lock_pages_in_memory"
        Identity             = $GMSADomain
        #PsDscRunAsCredential = $credential
    }

    #================== Set Service Runas GMSA ==================
    ServiceSet SQLSvcs
    {
        Name       = @( 'MSSQLSERVER', 'SQLSERVERAGENT' )
        Ensure     = 'Present'
        State      = 'Ignore'
        Credential = $svccred
    }

    #================== Set Service Startup Type ==================
    Script MSSQLServer_Delayed
    {
    
        TestScript = {
            $service = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\MSSQLSERVER'
            $service.DelayedStart -eq 1 
        }
        SetScript  = {
            "sc.exe Config MSSQLSERVER Start=Delayed-Auto" | Invoke-Expression
        }
        GetScript  = {@{Result = "MSSQLServer_Delayed"}}
    }


    Script SQLAgent_Delayed
    {
    
        TestScript = {
            $service = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\SQLSERVERAGENT'
            $service.DelayedStart -eq 1
        }
        SetScript  = {
            "sc.exe Config SQLSERVERAGENT Start=Delayed-Auto" | Invoke-Expression
        }
        GetScript  = {@{Result = "SQLAgent_Delayed"}}
    }
    


    #================== Import Cert ==================
    File $CertName
    {
        Ensure          = "Present"
        MatchSource     = $true
        Checksum        = "SHA-256"
        SourcePath      = Join-Path $Domain.FileShare "certs\$($Cert.FileName)"
        DestinationPath = Join-Path "C:\temp" $Cert.FileName
    }

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
    
    #================== Add GMSA to SSL Cert Permissions ==================
    Script SetCertRootPerm
    {
        TestScript = {
            $userName = $using:GMSADomain
            $certThumbprint = $using:Cert.Thumbprint
            $certStoreLocation = "\LocalMachine\My"
            $cert = Get-ChildItem Cert:$certStoreLocation | Where-Object {$_.thumbprint -like $certThumbprint}
            $root = "c:\programdata\microsoft\crypto\rsa\machinekeys"
            $path = Join-Path $root $cert.privatekey.cspkeycontainerinfo.uniquekeycontainername
			
            if (Test-Path $path)
            {
                $userexists = ((get-acl -path $path).Access | Select-Object -ExpandProperty IdentityReference).Value -contains $userName

                if ($userexists)
                {
                    (((get-acl -path $path).Access).where{$_.IdentityReference -eq $userName} | Select-Object -ExpandProperty FileSystemRights) -like "*FullControl*"
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
        SetScript  = {
            $userName = $using:GMSADomain
            $certThumbprint = $using:Cert.Thumbprint
            $certStoreLocation = "\LocalMachine\My"
            $cert = Get-ChildItem Cert:$certStoreLocation | Where-Object {$_.thumbprint -like $certThumbprint}
            $root = "c:\programdata\microsoft\crypto\rsa\machinekeys"
            $path = Join-Path $root $cert.privatekey.cspkeycontainerinfo.uniquekeycontainername
        
            $permission = "FullControl"
            $rule = new-object security.accesscontrol.filesystemaccessrule $userName, $permission, allow
        
            $acl = get-acl -path $path
            $acl.addaccessrule($rule)
            set-acl $path $acl

        }
        GetScript  = {@{Result = "SetCertRootPerm"}}
        DependsOn  = "[xPfxImport]$CertName"
    }
    
    #================== Enable Encrypted SQL Connections ==================
    Script EncryptSQLConEnable
    {
        TestScript = {
            $regInstance = 'MSSQL13.MSSQLSERVER'
            $Value = 'ForceEncryption'

            $reg = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$regInstance\MSSQLServer\SuperSocketNetLib" | Select-Object -ExpandProperty $Value
            $reg -eq 1
        }
        SetScript  = {
            $regInstance = 'MSSQL13.MSSQLSERVER'

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$regInstance\MSSQLServer\SuperSocketNetLib" -Name "ForceEncryption" -Value 1
        }
        GetScript  = {@{Result = "EncryptSQLConEnable"}}
        DependsOn  = "[xPfxImport]$CertName"
    }

    Script EncryptSQLConThumb
    {
        TestScript = {
            $regInstance = 'MSSQL13.MSSQLSERVER'
            $certThumbprint = $using:Cert.Thumbprint
            $Value = 'Certificate'

            $reg = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$regInstance\MSSQLServer\SuperSocketNetLib" | Select-Object -ExpandProperty $Value
            $reg -eq $certThumbprint
        }
        SetScript  = {
            $regInstance = 'MSSQL13.MSSQLSERVER'
            $certThumbprint = $using:Cert.Thumbprint

            Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$regInstance\MSSQLServer\SuperSocketNetLib" | New-ItemProperty -Name "Certificate" -Value $certThumbprint.ToLower() -Force
        }
        GetScript  = {@{Result = "EncryptSQLConThumb"}}
        DependsOn  = "[Script]EncryptSQLConEnable"
    }
}
