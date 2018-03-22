@{
    AllNodes = 
    @(
        @{
            NodeName   = '*'
            Status     = 'Production'
            Role       = 'AppProc'
            Product    = 'Consumer'
            DataCenter = 'Houston'
            Domain     = 'Internal'
            Packages   = @('Tentacle')
        }
        #================== AppProc Houston ==================
        @{ 
            NodeName  = 'CS-HOU-APPPROC-01'
            IPAddress = '10.1.1.125'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-02'
            IPAddress = '10.1.1.126'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-03'
            IPAddress = '10.1.1.127'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-04'
            IPAddress = '10.1.1.128'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-05'
            IPAddress = '10.1.1.129'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-06'
            IPAddress = '10.1.1.130'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-07'
            IPAddress = '10.1.1.131'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-08'
            IPAddress = '10.1.1.132'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-09'
            IPAddress = '10.1.1.133'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-10'
            IPAddress = '10.1.1.134'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-11'
            IPAddress = '10.1.1.135'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-12'
            IPAddress = '10.1.1.136'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-13'
            IPAddress = '10.1.1.137'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-14'
            IPAddress = '10.1.1.138'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-15'
            IPAddress = '10.1.1.139'
        }
        @{ 
            NodeName  = 'CS-HOU-APPPROC-16'
            IPAddress = '10.1.1.140'
        }
    )      
}