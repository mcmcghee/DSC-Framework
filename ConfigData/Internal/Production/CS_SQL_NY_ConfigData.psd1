@{
    AllNodes = 
    @(
        @{
            NodeName     = '*'
            Status       = 'Production'
            Role         = 'SQL'
            Product      = 'Consumer'
            DataCenter   = 'NewYork'
            Domain       = 'Internal'
            ExtraFolders = @('H:\Data')
            StaticRoute  = $true
        }
        #================== Database Servers NewYork ==================
        @{ 
            NodeName  = 'CS-NY-SQL-01'
            IPAddress = '10.2.1.171'
        }
        @{ 
            NodeName  = 'CS-NY-SQL-02'
            IPAddress = '10.2.1.172'
        }
    )      
}