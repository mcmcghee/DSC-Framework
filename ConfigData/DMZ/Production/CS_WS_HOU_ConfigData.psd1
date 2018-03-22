@{
    AllNodes = 
    @(
        @{
            NodeName       = '*'
            Status         = 'Production'
            DesktopEdition = 'Core'
            Role           = 'Web-Server'
            WebSites       = @('www.contosocorp.com', 'www.contoso.com')
            Product        = 'Consumer'
            DataCenter     = 'Houston'
            Domain         = 'DMZ'
            Packages       = @('OSSECAgent', 'Tentacle')
            ExtraFolders   = @('D:\inetpub\www.contosocorp.com\2017')
        }
        #================== Houston Consumer Web Servers ==================
        @{
            NodeName      = 'CS-HOU-WS-01'
            IPAddress     = '10.1.2.211'
        }
        @{
            NodeName      = 'CS-HOU-WS-02'
            IPAddress     = '10.1.2.212'
        }
        @{
            NodeName      = 'CS-HOU-WS-03'
            IPAddress     = '10.1.2.213'
        }
        @{
            NodeName      = 'CS-HOU-WS-04'
            IPAddress     = '10.1.2.214'
        }
        @{
            NodeName      = 'CS-HOU-WS-05'
            IPAddress     = '10.1.2.215'
        }
        @{
            NodeName      = 'CS-HOU-WS-06'
            IPAddress     = '10.1.2.216'
        }
        @{
            NodeName      = 'CS-HOU-WS-07'
            IPAddress     = '10.1.2.217'
        }
        @{
            NodeName      = 'CS-HOU-WS-08'
            IPAddress     = '10.1.2.218'
        }
        @{
            NodeName      = 'CS-HOU-WS-09'
            IPAddress     = '10.1.2.219'
        }
        @{
            NodeName      = 'CS-HOU-WS-10'
            IPAddress     = '10.1.2.220'            
        }
        @{
            NodeName      = 'CS-HOU-WS-11'
            IPAddress     = '10.1.2.221'
        }
        @{
            NodeName      = 'CS-HOU-WS-12'
            IPAddress     = '10.1.2.222'
        }
        @{
            NodeName      = 'CS-HOU-WS-13'
            IPAddress     = '10.1.2.223'
        }
        @{
            NodeName      = 'CS-HOU-WS-14'
            IPAddress     = '10.1.2.224'
        }
        @{
            NodeName      = 'CS-HOU-WS-15'
            IPAddress     = '10.1.2.225'
        }
        @{
            NodeName      = 'CS-HOU-WS-16'
            IPAddress     = '10.1.2.226'
        }
    )      
}