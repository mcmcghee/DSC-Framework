Configuration C3_Packages_OSSEC_EnvData
{
    param
    (
        [Hashtable]$Node
    )

    if ($Node.Packages -notcontains 'OSSECAgent') { return }

    #================== OSSEC Agent ==================
    File CopyOSSECAgent 
    {
        Ensure          = "Present"
        MatchSource     = $true
        Checksum        = "SHA-256"
        SourcePath      = Join-Path $Domain.FileShare "packages\$($OSSEC.FileName)"
        DestinationPath = $OSSEC.DestinationPath
    }

    Package OSSECAgent 
    {
        Ensure    = "Present"
        Name      = $OSSEC.Name
        Path      = $OSSEC.DestinationPath
        Arguments = "/S"
        ProductId = ""
        DependsOn = "[File]CopyOSSECAgent"
    }
}
