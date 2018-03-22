@{
    AllNodes = 
    @(
        @{
            NodeName     = '*'
            Status       = 'Production'
            Role         = 'SQL'
            Product      = 'Consumer'
            DataCenter   = 'Houston'
            Domain       = 'Internal'
            ExtraFolders = @('H:\Data')
            StaticRoute  = $true
        }
        #================== Database Servers Houston ==================
        @{ 
            NodeName  = 'CS-HOU-SQL-01'
            IPAddress = '10.1.1.171'
        }
        @{ 
            NodeName  = 'CS-HOU-SQL-02'
            IPAddress = '10.1.1.172'
        }
    )      
}