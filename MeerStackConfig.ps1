$config = @{
    Checks = @{
        CPU = @{ Enabled = $true; Interval = 5 }
        Memory = @{ Enabled = $true; Interval = 10 }
        Services = @{ Enabled = $true; Interval = 20; ServicesToCheck = @("Spooler", "W32Time", "FakeServiceName") }
        Bogus = @{ Enabled = $true; Interval = 5 }
    }

    LocalPath = "C:\MeerStack"
}