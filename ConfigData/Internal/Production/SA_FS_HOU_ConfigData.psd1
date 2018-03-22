@{
    AllNodes = 
    @(
        @{
            NodeName    = '*'
            Role        = 'FileServer'
            Product     = 'SaaS'
            DataCenter  = 'Houston'
            Domain      = 'Internal'
            StaticRoute = $true 
            LocalUsers  = @("LocalFSNUser")
        }
        @{ 
            NodeName  = 'SA-HOU-FS-01'
            IPAddress = '10.1.1.198'
        }
        @{ 
            NodeName  = 'SA-HOU-FS-02'
            IPAddress = '10.1.1.199'
        }
    )      
}