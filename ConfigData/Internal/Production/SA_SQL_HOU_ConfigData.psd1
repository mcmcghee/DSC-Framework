@{
    AllNodes = 
    @(
        @{
            NodeName    = '*'
            Status      = 'Production'
            Role        = 'SQL'
            Product     = 'SaaS'
            DataCenter  = 'Houston'
            Domain      = 'Internal'
            StaticRoute = $true
        }
        #================== Database Servers Houston ==================
        @{ 
            NodeName  = 'SA-HOU-SQL-01'
            IPAddress = '10.1.1.181'
        }
        @{ 
            NodeName  = 'SA-HOU-SQL-02'
            IPAddress = '10.1.1.182'
        }
    )      
}