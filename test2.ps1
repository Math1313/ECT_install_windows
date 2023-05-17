function  ValidateConnection{
    $connectionStatus = @()
    foreach($adapter in Get-NetAdapter)
    {
        if($adapter.Name -notlike "*Bluetooth*")
        {
            $connectionStatus += $adapter.Status
        }
    }

    return $connectionStatus
}

$connectionStatus = ValidateConnection
if ($connectionStatus -notcontains "Up")
{
    netsh wlan add profile filename=".\extension\Wi-Fi 4-ECT-Technicien.xml"
    netsh wlan connect ssid="ECT-Technicien" name="ECT-Technicien"

    Write-Host "Tentative de connexion. Le script se poursuivra dans 10 secondes..."
    Start-Sleep -Seconds 10
    $connectionStatus = ValidateConnection
    if($connectionStatus -notcontains "Up")
    {
        $window = New-Object -ComObject Wscript.Shell
        $window.popup("Le script va s'arrêter.",0, "Erreur de connexion")
        exit
    }
    else {
        "Au moins une connexion est OK, le script va continuer normalement."
    }
}
else{
    "Au moins une connexion est OK, le script va continuer normalement."
}