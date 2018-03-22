$pref = $VerbosePreference
$VerbosePreference = 'continue'
$outputPath = "C:\LocalDepot\Output"
$ModuleList = @("PSDscResources", "xPSDesiredStateConfiguration", "WebAdministration", "xWebAdministration", "xNetworking", "xCertificate", "OctopusDSC", "xSmbShare", "xStorage", "xTimeZone", "xSystemVirtualMemory", "xPendingReboot", "SecurityPolicyDsc", "cSystemSecurity", "xComputerManagement")

Configuration RootConfiguration
{
    # Get all ps1 files except this one
    $configsToProcess = Get-ChildItem -Path "$($PSScriptRoot)\EnvData\Production" -Filter '*.ps1'

    # PowerShell Automation cert for variable decryption. 
    # This should be the same thumbprint for the cert that is used in Encrypt-Password.ps1
    $SecretCert = (Get-ChildItem Cert:\LocalMachine\My).where{$_.Thumbprint -eq "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"}

    Import-DscResource -ModuleName PSDscResources -ModuleVersion 2.8.0.0
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 6.4.0.0
    Import-DscResource -ModuleName WebAdministration -ModuleVersion 1.0.0.0
    Import-DscResource -ModuleName xWebAdministration -ModuleVersion 1.18.0.0
    Import-DscResource -ModuleName xSmbShare -ModuleVersion 2.0.0.0
    Import-DscResource -ModuleName xCertificate -ModuleVersion 3.0.0.1
    Import-DscResource -ModuleName xNetworking -ModuleVersion 5.0.0.0
    Import-DscResource -ModuleName xStorage -ModuleVersion 3.2.0.0
    Import-DscResource -ModuleName xTimeZone -ModuleVersion 1.6.0.0
    Import-DscResource -ModuleName xSystemVirtualMemory -ModuleVersion 1.0.0
    Import-DscResource -ModuleName xPendingReboot -ModuleVersion 0.3.0.0
    Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 1.4.0.1
    Import-DscResource -ModuleName cSystemSecurity -ModuleVersion 1.2.0.0
    Import-DscResource -ModuleName xComputerManagement -ModuleVersion 2.0.0.0

    # Start going over each node
    Node $AllNodes.NodeName
    {
        # Import variables
        . .\Functions\Variables.ps1
        Write-Host "Processing configuration for $($Node.NodeName)..." -foregroundcolor Yellow
        foreach ($config in $configsToProcess)
        {
            Write-Verbose "Processing sub-configuration $($config.BaseName)..."
            . "$($config.FullName)" # Import script
            . "$($config.BaseName)" -Node $Node # Invoke configuration
            Write-Verbose "Finished processing sub-configuration $($config.BaseName)."
        }
        Write-Host "Finished Processing configuration for $($Node.NodeName)..." -foregroundcolor Yellow
    }
}

If (!(test-path $outputPath))
{
    New-Item -ItemType Directory -Force -Path $outputPath
}


$list = get-childitem C:\LocalDepot\ConfigData -file -recurse | Sort-Object name
$menu = @{}
for ($i = 1; $i -le $list.count; $i++)
{
    Write-Host "$i. $($list[$i-1].basename)"
    $menu.Add($i, ($list[$i - 1]))
    #counts the number of items in list (this is used for the do until statement)
    $number = $menu.Count
}

do
{
    [int]$ans = Read-Host 'Enter selection'
}
until ($ans -le $number)

$selection = $menu.Item($ans)

$MergedDscConfig = Merge-DscConfigData -BaseConfigFilePath "C:\LocalDepot\Common_ConfigData.psd1" -OverrideConfigFilePath $selection.FullName

RootConfiguration -ConfigurationData $MergedDscConfig -OutputPath $outputPath

Publish-DSCModuleAndMof -Source $outputPath -ModuleNameList $ModuleList

$VerbosePreference = $pref
