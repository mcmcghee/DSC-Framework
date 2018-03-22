@{
    AllNodes = 
    @(
        @{
            NodeName       = '*'
            Status         = 'Production'
            DesktopEdition = 'Core'
            Role           = 'Web-Server'
            WebSites       = @('saas.contoso.com')
            Domain         = 'DMZ'
            Product        = 'SaaS'
            DataCenter     = 'NewYork'
            Packages       = @('Tentacle')
        }
        #================== NewYork SaaS Web Servers ==================
        @{
            NodeName      = 'SA-NY-WS-TEST'
            IPAddress     = '10.2.2.190'
        }
        @{
            NodeName      = 'SA-NY-WS-01'
            IPAddress     = '10.2.2.191'
        }
        @{
            NodeName      = 'SA-NY-WS-02'
            IPAddress     = '10.2.2.192'
        }
        @{
            NodeName      = 'SA-NY-WS-03'
            IPAddress     = '10.2.2.193'
        }
        @{
            NodeName      = 'SA-NY-WS-04'
            IPAddress     = '10.2.2.194'
        }
        @{
            NodeName      = 'SA-NY-WS-05'
            IPAddress     = '10.2.2.195'
        }
        @{
            NodeName      = 'SA-NY-WS-06'
            IPAddress     = '10.2.2.196'
        }
        @{
            NodeName      = 'SA-NY-WS-07'
            IPAddress     = '10.2.2.197'
        }
        @{
            NodeName      = 'SA-NY-WS-08'
            IPAddress     = '10.2.2.198'
        }
    )
}