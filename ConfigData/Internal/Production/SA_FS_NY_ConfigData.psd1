@{
    AllNodes = 
    @(
        @{
            NodeName    = '*'
            Role        = 'FileServer'
            Product     = 'SaaS'
            DataCenter  = 'NewYork'
            Domain      = 'Internal'
            StaticRoute = $true
            LocalUsers  = @("LocalFSNUser")
        }
        #================== FileServers NewYork ==================
        @{ 
            NodeName  = 'SA-NY-FS-01'
            IPAddress = '10.2.1.198'
        }
        @{ 
            NodeName  = 'SA-NY-FS-02'
            IPAddress = '10.2.1.199'
        }
    )      
}