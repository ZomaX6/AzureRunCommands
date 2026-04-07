param (
    [string]$ACMAuri = "https://gbl.his.arc.azure.com/azcmagent/latest/AzureConnectedMachineAgent.msi",
    [string]$ACMAfile = "AzureConnectedMachineAgent.msi",
    [string]$ACMAlog = "C:\Program Files\AzureConnectedMachineAgent\agent_install.log"
)

$ErrorActionPreference = "Stop"
function Write-Log {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true, Position=0)]
        [ValidateSet("ERROR", "INFO", "SUCCESS")]
        [ValidateNotNull()]
        [string]$Level,
        [parameter(Mandatory = $true, Position=1)]
        [string]$String,
        [parameter(Position=2)]
        [string]$FileName = "ACMA_update", #Change log filename, should uniquely refer to the script
        [parameter(Position=3)]
        [bool]$ConsoleVerbose = $true #Verbose output in console
    )
    $Date = (Get-Date).ToString("dd.MM.yyyy HH:mm:ss.fff")
    $LogDate = (Get-Date).ToString("yyyy-MM-dd")
    $LogFileName = "{0}_{1}.txt" -f $LogDate, $FileName
    $LogFile = Join-Path $PSScriptRoot -ChildPath "ScriptLogs" $LogFileName
    $Output = "{0}|{1}|{2}|{3}" -f $Date, $FileName, $Level, $String
    $Output | Out-File $LogFile -Append
    if ($ConsoleVerbose) {
        Write-Verbose $Output -Verbose
    }
}

Write-Log INFO "Skripta startovana"

$ACMApath = Join-Path $env:TEMP -ChildPath $ACMAfile

try {
    Invoke-WebRequest -Uri $ACMAuri-OutFile $ACMApath
    Write-Log SUCCESS "Instalacija skinuta"
}
catch {
    Write-Log ERROR "Dogodila se greska prilikom skidanja instalacije | Error: $_"
    Write-Log INFO "Skripta zavrsena"
    exit
}

$ACMAargs = '/i $ACMApath /quiet /norestart /log $ACMAlog'
try {
    Start-Process msiexec.exe -ArgumentList $ACMAargs -NoNewWindow -Wait
    Write-Log SUCCESS "Instalacija uspesno trigerovana, za detaljan log pogledaj $ACMAlog"
}
catch {
    Write-Log ERROR "Dogodila se neka greska prilikom trigerovanja instalacije | Error: $_"
}

try {
    Remove-Item -Path $ACMApath -Force
    Write-Log SUCCESS "Instalacija obrisana"
}
catch {
    Write-Log ERROR "Dogodila se greska prilikom brisanja instalacije | Error: $_"
}

Write-Log INFO "Skripta zavrsena"