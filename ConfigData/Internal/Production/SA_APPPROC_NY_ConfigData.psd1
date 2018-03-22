@{
    AllNodes = 
    @(
        @{
            NodeName   = '*'
            Status     = 'Production'
            Role       = 'AppProc'
            Product    = 'SaaS'
            DataCenter = 'NewYork'
            Domain     = 'Internal'
            Packages   = @('Tentacle')
        }
        #================== AppProc NewYork ==================
        @{ 
            NodeName  = 'SA-NY-APPPROC-01'
            IPAddress = '10.2.1.120'
        }
        @{ 
            NodeName  = 'SA-NY-APPPROC-02'
            IPAddress = '10.2.1.121'
        }
        @{ 
            NodeName  = 'SA-NY-APPPROC-03'
            IPAddress = '10.2.1.122'
        }
        @{ 
            NodeName  = 'SA-NY-APPPROC-04'
            IPAddress = '10.2.1.123'
        }
    )      
}