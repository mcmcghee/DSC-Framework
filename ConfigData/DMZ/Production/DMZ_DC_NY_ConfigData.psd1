@{
    AllNodes = 
    @(
        @{
            NodeName   = '*'
            Status     = 'Production'
            Role       = 'DomainController'
            Domain     = 'DMZ'
            DataCenter = 'NewYork'
            Packages   = @('OSSECAgent')
        }
        #================== NewYork DMZ Domain Controllers ==================
        @{
            NodeName  = 'DMZ-NY-DC-01'
            IPAddress = '10.2.2.5'
        }
        @{
            NodeName  = 'DMZ-NY-DC-02'
            IPAddress = '10.2.2.6'
        }
        @{
            NodeName  = 'DMZ-NY-DC-03'
            IPAddress = '10.2.2.7'
        }
        @{
            NodeName  = 'DMZ-NY-DC-04'
            IPAddress = '10.2.2.8'
        }
    )
}