@{
    AllNodes = 
    @(
        @{
            NodeName    = '*'
            Role        = 'FileServer'
            Product     = 'Consumer'
            DataCenter  = 'Houston'
            Domain      = 'Internal'
            StaticRoute = $true
        }
        #================== FileServers Houston ==================
        @{ 
            NodeName  = 'CS-HOU-FS-01'
            IPAddress = '10.1.1.193'
        }
        @{ 
            NodeName  = 'CS-HOU-FS-02'
            IPAddress = '10.1.1.194'
        }
    )      
}