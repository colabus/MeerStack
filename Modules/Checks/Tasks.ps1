function Check-Tasks {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $tasks = Get-ScheduledTask | ForEach-Object {
        $task = $_

        $imagePaths = $task.Actions | Where-Object { $_.CimClass.CimClassName -eq "MSFT_TaskExecAction" -and $_.Execute } | ForEach-Object {
            $exe = [System.Environment]::ExpandEnvironmentVariables($_.Execute.Trim('"'))

            [PSCustomObject]@{
                ImagePath    = $exe
                Arguments    = $_.Arguments
                LastModified = if (Test-Path $exe -ErrorAction SilentlyContinue) {
                    (Get-Item $exe -ErrorAction SilentlyContinue).LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                } else {
                    $null
                }
            }
        }

        if (-not $imagePaths) { return }

        $taskInfo = $null

        try {
            $taskInfo = Get-ScheduledTaskInfo -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction Stop
        }
        catch { }

        [PSCustomObject]@{
            Name        = $task.TaskName
            Path        = $task.TaskPath
            Description = $task.Description
            Author      = $task.Author
            State       = $task.State.ToString()

            Principal   = [PSCustomObject]@{
                UserId    = if ($task.Principal.UserId) {
                    $task.Principal.UserId
                } elseif ($task.Principal.GroupId) {
                    $task.Principal.GroupId
                } else {
                    $null
                }
                LogonType = $task.Principal.LogonType.ToString()
                RunLevel  = $task.Principal.RunLevel.ToString()
            }

            LastRunTime   = if ($taskInfo.LastRunTime) { $taskInfo.LastRunTime.ToString("yyyy-MM-dd HH:mm:ss") } else { $null }
            LastResult    = if ($null -ne $taskInfo.LastTaskResult) { "0x{0:X5}" -f $taskInfo.LastTaskResult } else { $null }
            NextRunTime   = if ($taskInfo.NextRunTime) { $taskInfo.NextRunTime.ToString("yyyy-MM-dd HH:mm:ss") } else { $null }

            Actions     = @($imagePaths)
        }
    }

    $payload = [ordered]@{
        Hostname  = $hostName
        Timestamp = $timestamp
        Tasks     = @($tasks)
    }

    $json = $payload | ConvertTo-Json -Depth 4

    Check-Log -Component "Tasks" -JsonData $json
}
