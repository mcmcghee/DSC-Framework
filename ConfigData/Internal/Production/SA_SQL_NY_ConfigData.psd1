@{
    AllNodes = 
    @(
        @{
            NodeName    = '*'
            Status      = 'Production'
            Role        = 'SQL'
            Product     = 'SaaS'
            DataCenter  = 'NewYork'
            Domain      = 'Internal'
            StaticRoute = $true
        }
        #================== Database Servers NewYork ==================
        @{ 
            NodeName  = 'SA-NY-SQL-01'
            IPAddress = '10.2.1.181'
        }
        @{ 
            NodeName  = 'SA-NY-SQL-02'
            IPAddress = '10.2.1.182'
        }
    )      
}