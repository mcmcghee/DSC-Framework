@{
    AllNodes = 
    @(
        @{
            NodeName   = '*'
            Status     = 'Production'
            Role       = 'DomainController'
            Domain     = 'DMZ'
            DataCenter = 'Houston'
            Packages   = @('OSSECAgent')
        }
        #================== Houston DMZ Domain Controllers ==================
        @{
            NodeName  = 'DMZ-HOU-DC-01'
            IPAddress = '10.1.2.5'
        }
        @{
            NodeName  = 'DMZ-HOU-DC-02'
            IPAddress = '10.1.2.6'
        }
        @{
            NodeName  = 'DMZ-HOU-DC-03'
            IPAddress = '10.1.2.7'
        }
        @{
            NodeName  = 'DMZ-HOU-DC-04'
            IPAddress = '10.1.2.8'
        }
    )
}