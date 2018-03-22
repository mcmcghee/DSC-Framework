@{
    AllNodes = 
    @(
        @{
            NodeName    = '*'
            Role        = 'FileServer'
            Product     = 'Consumer'
            DataCenter  = 'NewYork'
            Domain      = 'Internal'
            StaticRoute = $true
        }
        #================== FileServers NewYork ==================
        @{ 
            NodeName  = 'CS-NY-FS-01'
            IPAddress = '10.2.1.193'
        }
        @{ 
            NodeName  = 'CS-NY-FS-02'
            IPAddress = '10.2.1.194'
        }
    )      
}