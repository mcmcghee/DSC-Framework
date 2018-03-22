Configuration B2_Role_FileServer_EnvData
{
    param
    (
        [Hashtable]$Node
    )

    if ($Node.Role -ine 'FileServer') { return }

    Service SIOS_DataKeeper 
    {
        Name        = "ExtMirrSvc"
        StartupType = "Automatic"
        State       = "Running"
    }

    Service FileServerResourceManager
    {
        Name        = "SrmSvc"
        StartupType = "Disabled"
        State       = "Stopped"
    }
}
