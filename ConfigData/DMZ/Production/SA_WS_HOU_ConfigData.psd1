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
            DataCenter     = 'Houston'
            Packages       = @('Tentacle')
        }
        #================== Houston SaaS Web Servers ==================
        @{
            NodeName      = 'SA-HOU-WS-01'
            IPAddress     = '10.1.2.191'
        }
        @{
            NodeName      = 'SA-HOU-WS-02'
            IPAddress     = '10.1.2.192'
        }
        @{
            NodeName      = 'SA-HOU-WS-03'
            IPAddress     = '10.1.2.193'
        }
        @{
            NodeName      = 'SA-HOU-WS-04'
            IPAddress     = '10.1.2.194'
        }
        @{
            NodeName      = 'SA-HOU-WS-05'
            IPAddress     = '10.1.2.195'
        }
        @{
            NodeName      = 'SA-HOU-WS-06'
            IPAddress     = '10.1.2.196'
        }
        @{
            NodeName      = 'SA-HOU-WS-07'
            IPAddress     = '10.1.2.197'
        }
        @{
            NodeName      = 'SA-HOU-WS-08'
            IPAddress     = '10.1.2.198'
        }
    )
}