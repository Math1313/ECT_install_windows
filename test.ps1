## Ask the user the type of installation he wants
## Type 1 is ECT Technologie Installation
## Type 2 is SXP Installation
## Type 3 will end the script
Function ChooseInstallationType
{
    do{
        $continu = $false
        Write-Host "Choisir un type d'installation:"
        Write-Host "1 - ECT Technologie"
        Write-Host "2 - SonXPlus"
        Write-Host "3 - Annuler"
        
        $global:installationType = Read-Host
        
        if($installationType -like "1")
        {
            Write-Host "ECT Technologie"
            $continu = $true
        }elseif($installationType -like "2")
        {
            Write-Host "SonXPlus"
            $continu = $true
        }elseif($installationType -like "3")
        {
            exit
        }else {
            Clear-Host
            Write-Host "Entrez une valeur valide."
        }
    }
    while($continu -eq $false)
}

Function PrintInstallationType
{
    if($installationType -eq 1)
    {
        Write-Host "ECT Technologie - $installationType"
    }elseif($installationType -eq 2)
    {
        Write-Host "SXP - $installationType"
    }
}


ChooseInstallationType

PrintInstallationType
