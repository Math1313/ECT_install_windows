$processList = Get-Process | ? { $_.MainWindowTitle } | Select-Object ProcessName

if($processList.ProcessName -contains "Ninite")
{
    Write-Host "Balls"
}
else {
    Write-Host "Done"
}