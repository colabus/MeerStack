CD $PSScriptRoot

$outputScript = ".\MeerStackBootstrap.ps1"

$orderedFiles = @(
    ".\MeerStackVariables.ps1",
    ".\MeerStackMethods.ps1",
    ".\MeerStackConfig.ps1",

    ".\Modules\Checks\Heartbeat.ps1",

    ".\Modules\Checks\Cpu.ps1",
    ".\Modules\Checks\Memory.ps1",
    ".\Modules\Checks\Services.ps1",
    ".\Modules\Checks\Certificates.ps1",
    ".\Modules\Checks\Disks.ps1",

    ".\Modules\Checks\EventLogs.ps1",

    ".\MeerStackMain.ps1"
)

$header = @'
$connectionString = "Server=Nick-PC;Database=MeerStack;Integrated Security=True;"
$scriptVersion = "20250616.2"

<#
                      ,'''''-._
                     ;  ,.  <> `-._ 
                     ;  \'   _,--'"
                    ;      (
                    ; ,   ` \
                    ;, ,     \
                   ;    |    |
                   ; |, |    |\
                  ;  |  |    | \
                  |.-\ ,\    |\ :
                  |.- `. `-. | ||
                  :.-   `-. \ ';;
                   .- ,   \;;|
                   ;   ,  |  ,\
                   ; ,    ;    \
                  ;    , /`.  , )
               __,;,   ,'   \  ,|
         _,--''__,|   /      \  :
       ,'_,-''    | ,/        | :
      / /         | ;         ; |
     | |      __,-| |--..__,--| |---.--....___
___,-| |----''    / |         `._`-.          `----
      \ \        `"""             """      --
       `.`.                 --'
         `.`-._        _,             ,-     __,-
            `-.`.
   --'         `;     MeerStack by colabus & insig

#>

'@

$header = $header + @"

#  Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

"@

Set-Content -Path $outputScript -Value $header

foreach ($file in $orderedFiles) {
    if (-not (Test-Path $file)) {
        Write-Warning "File not found: $file .."
        continue
    }

    Write-Host "Including: $file .."

    $content = Get-Content $file -Raw

    $cleaned = $content -split "`n" | Where-Object {
        $_ -notmatch '^\s*\.\s+["'']'
    }

    $minified = $cleaned `
        -replace '^\s*#.*', '' `
        -replace '^\s*CD.*', '' `
        -replace '\s*#.*$', '' `
        -replace '^\s*$', '' `
        -replace '[ \t]{2,}', ' ' `
        -replace '^\s*\$connectionString.*', '' `
        -replace '^\s*\$scriptVersion.*', '' `
        -join "`n"

    $minified = $minified -replace '(\n){2,}', "`n"

    Add-Content -Path $outputScript -Value $minified
}

Write-Host "Packaged script written to: $outputScript"