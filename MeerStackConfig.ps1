$config = @{
    Checks = @{
        CPU = @{ Enabled = $true; Interval = 60 }
        Memory = @{ Enabled = $true; Interval = 60 }
        Services = @{ Enabled = $true; Interval = 60; ServicesToCheck = @("Spooler", "W32Time", "FakeServiceName") }
        Bogus = @{ Enabled = $true; Interval = 60 }
    }
    
    Database = @{
        ConnectionString = "Server=<Server>;Database=<Database>;Integrated Security=True;"
    }

    LocalPath = "C:\MeerStack"
}