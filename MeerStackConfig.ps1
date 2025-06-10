$config = @{
    Checks = @{
        CPU = @{ Enabled = $true; Interval = 300 }
        Memory = @{ Enabled = $true; Interval = 300 }
        Services = @{ Enabled = $true; Interval = 60; ServicesToCheck = @("Spooler", "W32Time", "FakeServiceName") }
    }

    LocalLogPath = "C:\MeerStack\Logs"
}