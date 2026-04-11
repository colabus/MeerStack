function Resolve-ExecutablePath {
    param ([string]$fileName)

    if ([System.IO.Path]::IsPathRooted($fileName) -and (Test-Path $fileName)) {
        return @($fileName)
    }

    $searchDirectories = [System.Collections.Generic.List[string]]::new()

    $searchDirectories.Add([System.Environment]::ExpandEnvironmentVariables("%SystemRoot%\System32"))
    $searchDirectories.Add([System.Environment]::ExpandEnvironmentVariables("%SystemRoot%"))

    $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)

    foreach ($dir in ($machinePath -split ';' | Where-Object { $_ })) {
        $searchDirectories.Add([System.Environment]::ExpandEnvironmentVariables($dir))
    }

    foreach ($dir in $searchDirectories) {
        $full = Join-Path $dir $fileName
        if (Test-Path $full -ErrorAction SilentlyContinue) {
            return $full
        }
    }

    return $fileName
}

function Check-Tasks {
    param (
        [hashtable]$config
    )

    $hostName = $m_hostName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $tasks = Get-ScheduledTask | ForEach-Object {
        $task = $_

        $imagePaths = $task.Actions | Where-Object { $_.CimClass.CimClassName -eq "MSFT_TaskExecAction" -and $_.Execute } | ForEach-Object {
            $execute = [System.Environment]::ExpandEnvironmentVariables($_.Execute.Trim('"'))
            $imagePath = Resolve-ExecutablePath($execute)

            [PSCustomObject]@{
                Execute         = $execute
                ImagePath       = $imagePath
                Arguments       = $_.Arguments
                LastModified    = if (Test-Path $exe -ErrorAction SilentlyContinue) {
                    (Get-Item $exe -ErrorAction SilentlyContinue).LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                } else {
                    $null
                }
            }
        }

        if (-not $imagePaths -or $task.Author -match '^Microsoft.*') { return }

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
