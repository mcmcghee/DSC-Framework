<#
.SYNOPSIS
This is an idea I'm playing around with. This file will contain mappings between the $AllNodes and $NonNodeData hashtables. 
These variables will generate per node and be available inside the "Node $AllNodes.NodeName" loop specified in RootConfiguration.ps1.
#>

#================== Base Variables ==================

# Domain Variables
$Domain = $ConfigurationData.NonNodeData.Domains.Where{$_.Name -eq $Node.Domain}
$DomainName = $Domain.Name

# Network Variables
$DataCenter = $ConfigurationData.NonNodeData.DataCenters.Where{$_.Name -eq $Node.DataCenter}
$Network = $DataCenter.Networks.Where{$_.Domain -eq $Node.Domain}

# Product Variables
$Product = $ConfigurationData.NonNodeData.Products.Where{$_.Name -eq $Node.Product}
$ProductName = $Node.Product

# Windows Features Variables
$featuresToInstall = $ConfigurationData.NonNodeData.Roles.Where{$_.Name -eq $Node.Role}.WindowsFeatures

#================== WebServer Role Variables ==================# 
if ($Node.Role -eq 'Web-Server')
{ 
    # Staging Server Variables
    $StagingServer = ($ConfigurationData.NonNodeData.Products.Where{$_.Name -eq $Node.Product}).DataCenters.Where{$_.Name -eq $Node.DataCenter}.WebStaging
    $StagingServerQ = '""' + $StagingServer + '""'
}

#================== AppProc Role Variables ==================#  
if ($Node.Role -eq 'AppProc')
{ 

}

#================== SQL Role Variables ==================#
if ($Node.Role -eq 'SQL')
{
    # SQL GMSA Variables
    $GMSA = $Product.SQLgmsa
    $GMSADomain = $DomainName + "\" + $GMSA + "$"
    $secpasswd = ConvertTo-SecureString ' ' -AsPlainText -Force
    $svccred = New-Object System.Management.Automation.PSCredential ($GMSADomain, $secpasswd)

    # SQL Cert Variables
    $Cert = $ConfigurationData.NonNodeData.Certs.Where{$_.Name -eq $Product.SQLCert}
    $CertName = $Cert.Name
    $CertPassword = $Cert.Password | Unprotect-CmsMessage -To $SecretCert | ConvertTo-SecureString -AsPlainText -Force
    $CertCred = New-Object System.Management.Automation.PSCredential('Pfx', $CertPassword)
}

#================== FS Role Variables ==================#
if ($Node.Role -eq 'FS')
{
    
}

#================== OSSEC Package Variables ==================#
if ($Node.Packages -contains 'OSSECAgent')
{ 
    $OSSEC = $ConfigurationData.NonNodeData.Packages.Where{$_.PackageName -eq 'OSSEC'}
}

#================== Tentacle Package Variables ==================#
if ($Node.Packages -contains 'Tentacle')
{ 
    $tentacle = $ConfigurationData.NonNodeData.Packages.Where{$_.PackageName -eq 'Tentacle'}
    $tentacleVersion = $tentacle.Version
    $tentacleFileName = $tentacle.FileName
    $tentacleProductID = $tentacle.ProductID
    $octopusDeployRoot = $tentacle.DeployRoot
    $tentacleRegistrationApiKey = $tentacle.RegistrationApiKey
    $tentacleRegistrationUri = $tentacle.RegistrationUri
    $octopusConfigStateFile = Join-Path -Path $octopusDeployRoot -ChildPath 'config.statefile'
    $octopusConfigLogFile = Join-Path -Path $octopusDeployRoot -ChildPath "OctopusTentacle.config.log"
    $octopusTentacleExe = Join-Path -Path $env:ProgramFiles -ChildPath 'Octopus Deploy\Tentacle\Tentacle.exe'

    if ($Node.Role -eq 'AppProc')
    {
        # Calc Service Account Variables
        $CalcTentacleSvcAccount = $Product.CalcTentacleAccount
        $CalcTentacleSvcPwd = Unprotect-CmsMessage -To $SecretCert -Content $ConfigurationData.NonNodeData.Creds.Where{$_.Name -eq $CalcTentacleSvcAccount}.Password
        $CalcTentacleSvcPwdSecure = $CalcTentacleSvcPwd | ConvertTo-SecureString -AsPlainText -Force  
        $CalcTentacleSvcCred = New-Object System.Management.Automation.PSCredential ($CalcTentacleSvcAccount, $CalcTentacleSvcPwdSecure)
    }
}