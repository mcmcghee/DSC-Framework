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
            DataCenter     = 'NewYork'
            Domain         = 'DMZ'
            Packages       = @('Tentacle')
            ExtraFolders   = @('D:\inetpub\www.contosocorp.com\2017')
        }
        #================== NewYork Consumer Web Servers ==================
        @{
            NodeName      = 'CS-NY-WS-01'
            IPAddress     = '10.2.2.211'
        }
        @{
            NodeName      = 'CS-NY-WS-02'
            IPAddress     = '10.2.2.212'
        }
        @{
            NodeName      = 'CS-NY-WS-03'
            IPAddress     = '10.2.2.213'
        }
        @{
            NodeName      = 'CS-NY-WS-04'
            IPAddress     = '10.2.2.214'
        }
        @{
            NodeName      = 'CS-NY-WS-05'
            IPAddress     = '10.2.2.215'
        }
        @{
            NodeName      = 'CS-NY-WS-06'
            IPAddress     = '10.2.2.216'
        }
        @{
            NodeName      = 'CS-NY-WS-07'
            IPAddress     = '10.2.2.217'
        }
        @{
            NodeName      = 'CS-NY-WS-08'
            IPAddress     = '10.2.2.218'
        }
        @{
            NodeName      = 'CS-NY-WS-09'
            IPAddress     = '10.2.2.219'
        }
        @{
            NodeName      = 'CS-NY-WS-10'
            IPAddress     = '10.2.2.220'
        }
        @{
            NodeName      = 'CS-NY-WS-11'
            IPAddress     = '10.2.2.221'
        }
        @{
            NodeName      = 'CS-NY-WS-12'
            IPAddress     = '10.2.2.222'
        }
        @{
            NodeName      = 'CS-NY-WS-13'
            IPAddress     = '10.2.2.223'
        }
        @{
            NodeName      = 'CS-NY-WS-14'
            IPAddress     = '10.2.2.224'
        }
        @{
            NodeName      = 'CS-NY-WS-15'
            IPAddress     = '10.2.2.225'
        }
        @{
            NodeName      = 'CS-NY-WS-16'
            IPAddress     = '10.2.2.226'
        }
        @{
            NodeName      = 'CS-NY-WS-TEST'
            IPAddress     = '10.2.2.227'
        }
    )      
}