@{
    AllNodes = 
    @(
        @{
            NodeName   = '*'
            Status     = 'Production'
            Role       = 'AppProc'
            Product    = 'SaaS'
            DataCenter = 'Houston'
            Domain     = 'Internal'
            Packages   = @('Tentacle')
        }
        #================== AppProc Houston ==================
        @{ 
            NodeName  = 'SA-HOU-APPPROC-01'
            IPAddress = '10.1.1.120'
        }
        @{ 
            NodeName  = 'SA-HOU-APPPROC-02'
            IPAddress = '10.1.1.121'
        }
        @{ 
            NodeName  = 'SA-HOU-APPPROC-03'
            IPAddress = '10.1.1.122'
        }
        @{ 
            NodeName  = 'SA-HOU-APPPROC-04'
            IPAddress = '10.1.1.123'
        }
    )      
}