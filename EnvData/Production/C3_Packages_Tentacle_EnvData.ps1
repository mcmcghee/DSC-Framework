Configuration C3_Packages_Tentacle_EnvData
{
    param
    (
        [Hashtable]$Node
    )

    if ($Node.Packages -notcontains 'Tentacle') { return }

    #================== Octopus Tentacle Agent ==================
    File CopyTentacleAgent 
    {
        Ensure          = "Present"
        MatchSource     = $true
        Checksum        = "SHA-256"
        SourcePath      = Join-Path -Path $Domain.FileShare "packages\$tentacleFileName"
        DestinationPath = "C:\temp\$tentacleFileName"
    }

    File CopyOctopusCert 
    {
        Ensure          = "Present"
        MatchSource     = $true
        Checksum        = "SHA-256"
        SourcePath      = Join-Path -Path $Domain.FileShare 'packages\OctopusCertificate.txt'
        DestinationPath = "C:\temp\OctopusCertificate.txt"
        DependsOn       = "[File]CopyTentacleAgent"
    }

    Package TentacleAgent 
    {
        Ensure    = "Present"
        Name      = "Octopus Deploy Tentacle"
        Path      = "C:\temp\$tentacleFileName"
        ProductId = $tentacleProductID
        DependsOn = "[File]CopyOctopusCert"
    }
            
    File OctopusDeployFolder 
    {
        Type            = 'Directory'
        DestinationPath = $octopusDeployRoot
        Ensure          = "Present"
    }

    Script ConfigureTentacleAgent 
    {
        SetScript  = 
        {
            & $using:octopusTentacleExe create-instance --console --instance "Tentacle" --config "C:\Octopus\Tentacle\Tentacle.config" *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
            if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: create-instance" }
            & $using:octopusTentacleExe import-certificate --console --instance "Tentacle" -f "C:\temp\OctopusCertificate.txt" *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
            if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: new-certificate" }
            & $using:octopusTentacleExe configure --console --instance "Tentacle" --reset-trust *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
            if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: reset-trust" }
            & $using:octopusTentacleExe configure --console --instance "Tentacle" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10933" *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
            if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: configure" }
            & $using:octopusTentacleExe configure --console --instance "Tentacle" --trust "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
            if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: configure" }
            & $using:octopusTentacleExe service --console --instance "Tentacle" --install --start *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
            if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: service" }
            [System.IO.FIle]::WriteAllText($using:octopusConfigStateFile, $LASTEXITCODE, [System.Text.Encoding]::ASCII)
        }
        TestScript = 
        {
            ((Test-Path $using:octopusConfigStateFile) -and ([System.IO.FIle]::ReadAllText($using:octopusConfigStateFile).Trim()) -eq '0')
        }
        GetScript  = { @{} }
        DependsOn  = @('[File]OctopusDeployFolder', '[Package]TentacleAgent')
    }

    Service OctopusDeployTentacle 
    {
        Name        = "OctopusDeploy Tentacle"
        StartupType = "Automatic"
        State       = "Running"
        DependsOn   = "[Script]ConfigureTentacleAgent"
    }
    
    xFirewall Octopus
    {
        Name        = "Octopus"
        DisplayName = "Octopus Inbound Port 10933"
        Ensure      = "Present"
        Action      = "Allow"
        Enabled     = "True"
        Profile     = ("Domain", "Private")
        Direction   = "InBound"
        RemotePort  = ("Any")
        LocalPort   = ("10933")
        Protocol    = "TCP"
        Description = "Octopus Inbound Port 10933"
    }
}
