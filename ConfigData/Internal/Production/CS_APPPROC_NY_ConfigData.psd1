@{
    AllNodes = 
    @(
        @{
            NodeName   = '*'
            Status     = 'Production'
            Role       = 'AppProc'
            Product    = 'Consumer'
            DataCenter = 'NewYork'
            Domain     = 'Internal'
            Packages   = @('Tentacle')
        }
        #================== AppProc NewYork ==================
        @{ 
            NodeName  = 'CS-NY-APPPROC-01'
            IPAddress = '10.2.1.125'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-02'
            IPAddress = '10.2.1.126'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-03'
            IPAddress = '10.2.1.127'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-04'
            IPAddress = '10.2.1.128'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-05'
            IPAddress = '10.2.1.129'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-06'
            IPAddress = '10.2.1.130'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-07'
            IPAddress = '10.2.1.131'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-08'
            IPAddress = '10.2.1.132'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-09'
            IPAddress = '10.2.1.133'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-10'
            IPAddress = '10.2.1.134'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-11'
            IPAddress = '10.2.1.135'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-12'
            IPAddress = '10.2.1.136'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-13'            
            IPAddress = '10.2.1.137'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-14'
            IPAddress = '10.2.1.138'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-15'
            IPAddress = '10.2.1.139'
        }
        @{ 
            NodeName  = 'CS-NY-APPPROC-16'
            IPAddress = '10.2.1.140'
        }
    )      
}