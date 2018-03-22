Configuration B2_Role_AppProcServer_EnvData
{
    param
    (
        [Hashtable]$Node
    )

    if ($Node.Role -ine 'AppProc') { return }

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
        DriveLetter = "H"
        FSLabel     = "Data"
    }

    #================== Pagefile on P Drive ==================
    xSystemVirtualMemory MovePagefile
    {
        ConfigureOption = "SystemManagedSize"
        DriveLetter     = "P:"
        DependsOn       = "[xDisk]PageFileVolume"
    }
        
    #================== Check for PageFile on P Drive ==================
    Script RebootPF 
    {
        TestScript = 
        {
            $Path = "P:\pagefile.sys"
            $parent = Split-Path $Path
            [System.IO.Directory]::EnumerateFiles($Parent) -contains $Path
        }
        SetScript  = 
        {
            Restart-Computer -Force
        }
        GetScript  = {@{Result = "RebootPF"}}
    }

    #================== MSMQ ==================
    Service MSMQ
    {
        Name        = "MSMQ"
        StartupType = "Automatic"
        State       = "Running"
        DependsOn   = "[WindowsFeature]MSMQ"
    }

    #================== Install Font ==================
    File CopyFont
    {
        Ensure          = "Present"
        MatchSource     = $true
        Checksum        = "SHA-256"
        SourcePath      = Join-Path $Domain.FileShare "fonts\OCRAEXT.TTF"
        DestinationPath = "C:\fonts\OCRAEXT.TTF"
    }

    Script InstallFont
    {
        TestScript = {
            [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
            $objFonts = New-Object System.Drawing.Text.InstalledFontCollection
            $ocr = $objFonts.Families | Where-Object { $_ -like "*OCR*" }
            if (!($ocr))
            {
                return $false
            }
            else
            {
                return $true
            }
        }
        SetScript  = {
            $sa = New-Object -comobject Shell.Application 
            $Fonts = $sa.NameSpace(0x14)
            Get-ChildItem  "c:\fonts\*.ttf" | ForEach-Object { $fonts.CopyHere($_.FullName) }
        }
        GetScript  = {@{Result = "InstallOCRFont"}}
        DependsOn  = "[File]CopyOCRFont"
    }
} 