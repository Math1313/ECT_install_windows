
Function PrintECT
{
    Clear-Host
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'DarkBlue' " __      __.__            .___                      _____                                             "
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'DarkBlue' "/  \    /  \__| ____    __| _/______  _  ________ _/ ____\___________                                 "
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'DarkBlue' "\   \/\/   /  |/    \  / __ |/  _ \ \/ \/ /  ___/ \   __\/  _ \_  __ \                                "
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'DarkBlue' " \        /|  |   |  \/ /_/ (  <_> )     /\___ \   |  | (  <_> )  | \/                                "
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'DarkBlue' "  \__/\__/ |__|___|  /\____ |\____/ \/\_//______>  |__|  \____/|__|                                   "
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'DarkBlue' "___________.__                 __                                       ___________           .__     "
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'DarkBlue' "\_   _____/|  |   ____   _____/  |________  ____   ____  ____   _____   \__    ___/___   ____ |  |__  "
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'DarkBlue' " |    __)_ |  | _/ __ \_/ ___\   __\_  __ \/  _ \_/ ___\/  _ \ /     \    |    |_/ __ \_/ ___\|  |  \ "
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'DarkBlue' " |        \|  |_\  ___/\  \___|  |  |  | \(  <_> )  \__(  <_> )  Y Y  \   |    |\  ___/\  \___|   Y  \"
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'DarkBlue' "/_________/|____/\_____>\_____>__|  |__|   \____/ \_____>____/|__|_|__/   |____| \_____>\_____>___|__/"
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'DarkBlue' "                                                                                                      "
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'Red'      '___            __  __          _     _      _   ____  _   ____                                        '
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'Red'      '| _ )  _  _    |  \/  |  __ _  | |_  | |_   / | |__ / / | |__ /                                       '
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'Red'      '| _ \ | || |   | |\/| | / _` | |  _| | ` \  | |  |_ \ | |  |_ \                                       '
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'Red'      '|___/  \_, |   |_|  |_| \__,_|  \__| |_||_| |_| |___/ |_| |___/                                       '
    Write-Host -BackgroundColor 'Gray' -ForegroundColor 'Red'      '       |__/                                                                                           '
}

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
            PrintECT
            Write-Host "Entrez une valeur valide."
        }
    }
    while($continu -eq $false)
}
# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #
#Fonction qui retourne la version de Windows
## 1 = Windows 11
## 0 = Windows 10
Function isWindows11{
    $winver = (Get-ComputerInfo).OsName

    if($winver -like "Microsoft Windows 11*"){
        return 1
    }
    elseif ($winver -like "Microsoft Windows 10*"){
        return 0
    }
}
# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #
#Fonction pour installer Winget
##Winget est utilisé pour installer d'autres programmes directement depuis le Microsoft Store, tels que Adobe Reader ou Lenovo Commercial Vantage.

Function Install-WinGet {
    #Installe la dernière version du paquet depuis GitHub
    [cmdletbinding(SupportsShouldProcess)]
    [alias("iwg")]
    [OutputType("None")]
    [OutputType("Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage")]
    Param(
        [Parameter(HelpMessage = "Display the AppxPackage after installation.")]
        [switch]$Passthru
    )

    Write-Verbose "[$((Get-Date).TimeofDay)] Starting $($myinvocation.mycommand)"

    if ($PSVersionTable.PSVersion.Major -eq 7) {
        Write-Warning "This command does not work in PowerShell 7. You must install in Windows PowerShell."
        return
    }

    #Test pour les voir si les prérequis sont présents
    $Requirement = Get-AppPackage "Microsoft.DesktopAppInstaller"
    if (-Not $requirement) {
        Write-Verbose "Installing Desktop App Installer requirement"
        Try {
            Add-AppxPackage -Path "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -erroraction Stop
        }
        Catch {
            Throw $_
        }
    }

    $uri = "https://api.github.com/repos/microsoft/winget-cli/releases"

    Try {
        Write-Verbose "[$((Get-Date).TimeofDay)] Getting information from $uri"
        $get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop

        Write-Verbose "[$((Get-Date).TimeofDay)] getting latest release"
        $data = $get[0].assets | Where-Object name -Match 'msixbundle'

        $appx = $data.browser_download_url
        Write-Verbose "[$((Get-Date).TimeofDay)] $appx"
        If ($pscmdlet.ShouldProcess($appx, "Downloading asset")) {
            $file = Join-Path -path $env:temp -ChildPath $data.name

            Write-Verbose "[$((Get-Date).TimeofDay)] Saving to $file"
            Invoke-WebRequest -Uri $appx -UseBasicParsing -DisableKeepAlive -OutFile $file

            Write-Verbose "[$((Get-Date).TimeofDay)] Adding Appx Package"
            Add-AppxPackage -Path $file -ErrorAction Stop

            if ($passthru) {
                Get-AppxPackage microsoft.desktopAppInstaller
            }
        }
    }
    Catch {
        Write-Verbose "[$((Get-Date).TimeofDay)] There was an error."
        Throw $_
    }
    Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"
}

# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #
Function WifiConnection {
    # Pour avoir le bon fichier XML, exporter le profile du réseau que vous souhaitez connecter en utilisant "netsh wlan export profile folder="path""
    # Ensuite, mettez le fichier XML dans le dossier "extension" et renommer le fichier utilisé dans les deux commandes suivantes
    netsh wlan add profile filename=".\extension\Wi-Fi 4-ECT-Technicien.xml"
    netsh wlan connect ssid="ECT-Technicien" name="ECT-Technicien"
}

# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #
Function DisableConfigBlueScreen {
    #0 = Off
    #1 = On
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Value 0 -Force
}

# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #
Function UninstallOneDrive {
    try {
    # Exécute la commande PowerShell
    Invoke-Expression -Command "C:\Windows\SysWOW64\OneDriveSetup.exe /uninstall"
    } catch {
    # Si la commande a échoué, exécute une autre commande
    Invoke-Expression -Command "C:\Windows\System32\OneDriveSetup.exe /uninstall"
    }
}
# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #
Function SetDesktopIcons {
    #------------------------------------------------------------------------------------#
    # Desktop
    # Ce PC = {20D04FE0-3AEA-1069-A2D8-08002B30309D}
    # Panneau de configuration = {5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}
    # Utilisateur = {59031a47-3f72-44a7-89c5-5595fe6b30ee}
    # Réseau = {F02C1A0D-BE21-4350-88B0-7367FC96EF3C}
    # Corbeille  = {645FF040-5081-101B-9F08-00AA002F954E}
    $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    $icons = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}", "{645FF040-5081-101B-9F08-00AA002F954E}", "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"


    foreach ($icon in $icons)
    {
        $exist="Get-ItemProperty -Path $path -Name $icon"
        if ($exist)
        {
            Set-ItemProperty -Path $path -Name $icon -Value 0
        }
        Else
        {
            New-ItemProperty -Path $path -Name $icon -Value 0
        }
    }
}
# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #

function SetTaskbarSettings {
    #Barre des tâches
    ## Défini la position des objets de la barre des tâches
    ##(Valeur 0 = Gauche)
    ##(Valeur 1 = Centre)
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Force

    ## Champ de recherche
    ## (Valeur 0 = Pas de loupe)
    ## (Valeur 1 = Juste la loupe)
    ## (Valeur 2 = Loupe + barre de recherche)
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchBoxTaskbarMode" -Value 1 -Type DWord -Force
    #---------------------------
    # (Valeur 0 = Ne pas afficher les icones)
    # (Valeur 1 = Afficher les icones)
    ## Icons de la vu des tâches
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Force
    ## Icone des widgets
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Force
    ## Icone de chat
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -Force
    
}
# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #

function SetAlimentationSettings {
    #Alimentation (Délais en minute, 0 = jamais)
    ##Fermer l'écran - Connecter
    powercfg /change monitor-timeout-ac 0
    ##Fermer l'écran - Sur la batterie
    powercfg /change monitor-timeout-dc 0

    ##Mise en veille - Connecter 
    powercfg /change standby-timeout-ac 0
    ##Mise en veille - Sur la batterie
    powercfg /change standby-timeout-dc 0

    ##Arrêter le disque - Connecter
    powercfg /change disk-timeout-ac 0
    ##Arrêter le disque - Sur la batterie
    powercfg /change disk-timeout-dc 20


    ##(Valeur 0 = Ne rien faire)
    ##(Valeur 1 = Mettre en veille)
    ##(Valeur 2 = Mettre en veille, plus puissant)
    ##(Valeur 3 = Éteindre)

    ##Quand le bouton Power est cliqué
    ## Connecter
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 1
    ## Sur la batterie
    powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 1

    ##Quand le bouton de mise en veille est cliqué
    ## Connecter
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
    ## Sur batterie
    powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0

    ##Quand le panneau de l'écran est fermé
    ## Connecter
    powercfg /setACvalueIndex scheme_current sub_buttons lidAction 0
    ## Sur la batterie
    powercfg /setDCvalueIndex scheme_current sub_buttons lidAction 2
}
# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #

function InstallPrograms {
    # Programme
    ##Installer Adobe Acrobat Reader
    if(isWindows11)
    {
        winget install --id "Adobe.Acrobat.Reader.32-bit" --accept-package-agreements --accept-source-agreements
        PrintECT
    }else{
        #Start-Process Powershell.exe -Argumentlist "-file .\extension\adobeAcrobat.ps1"
        #.\extension\installReader.exe
        Start-Process Powershell.exe -Argumentlist "-ExecutionPolicy", "Bypass", "-File", ".\extension\adobeAcrobat.ps1"
    }

    ##Manufacturier
    ##Permet d'obtenir le manufacturier du PC
    $make = (Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer

    ##Si la manufacturier est Dell, installe Support Assist
    if($make -eq "Dell Inc.")
    {
        .\extension\SupportAssistInstaller.exe
    }elseif($make -eq "LENOVO") ##Si le manufacturier est Lenovo, installe Lenovo Commercial Vantage
    {
        if(isWindows11)
        {
            winget install "Lenovo Commercial Vantage" --disable-interactivity --accept-package-agreements
            PrintECT
        }else{
            Write-Host "Please Install Lenovo Commercial Vantage Manually"
        }
    }

    ## Lance Ninite
    ## Pour fonctionner, il faut avoir un fichier nommer niniteECT.exe ou niniteSXP.exe dans le dossier extension
    ## Il est également possible de changer le nom et le chemin d'accès du fichier dans le code ci-dessous
    ## La close If permet de savoir quel fichier ninite utilisé, car Son X Plus et Electrocom n'utilise pas le même
    if($installationType -eq 1) ## Type 1 est pour Electrocom
    {
        .\extension\niniteECT.exe
    }elseif ($installationType -eq 2) ## Type 2 est pour Son X Plus
    {
        .\extension\niniteSXP.exe
        if(isWindows11)
        {
            winget install --id "9WZDNCRF0083" --accept-package-agreements --accept-source-agreements
        }else{
            Write-Host "Please Install Messenger Manually"
        }
    }
}
# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #

function SetDefaultWebBrowser {
    # Attend que Chrome soit installer avant de le mettre comme application par défaut
    # SetUserFTA.exe est un outil qui permet de changer le programme par défaut pour chaque extension de fichier
    do{
        Start-Sleep -s 10
        if(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe' -erroraction 'silentlycontinue')
        {
            .\extension\SetUserFTA\SetUserFTA.exe .htm ChromeHTML
            .\extension\SetUserFTA\SetUserFTA.exe .html ChromeHTML
            .\extension\SetUserFTA\SetUserFTA.exe http ChromeHTML
            .\extension\SetUserFTA\SetUserFTA.exe https ChromeHTML
            .\extension\SetUserFTA\SetUserFTA.exe .webp ChromeHTML
            "Google Chrome Is Installed And Set As Default !"
        } else
        {
            PrintECT
            "Google Chrome Is Not Installed Yet..."
        }
        
    }
    while (!(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe' -erroraction 'silentlycontinue'))

    # Regarde si Adobe Acrobat Reader est installé
    #if(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\AcroRd32.exe' -erroraction 'silentlycontinue')
    #{
    #    .\extension\SetUserFTA\SetUserFTA.exe .pdf AcroExch.Document.DC
    #    "Adobe Acrobate Reader Is Installed And Set As Default !"
    #} else
    #{
    #    "Adobe Acrobate Reader Could Not Be Install..."
    #    "Please Install It Manually."
    #}
    
}

function SetDefaultPDFReader{
    $time = 0
    do{
        $time += 10
        Start-Sleep -s 10
        if(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\AcroRd32.exe' -erroraction 'silentlycontinue')
        {
            if(isWindows11)
            {
                .\extension\SetUserFTA\SetUserFTA.exe .pdf AcroExch.Document.DC
            }else
            {
                .\extension\SetUserFTA\SetUserFTA.exe .pdf Acrobat.Document.DC
            }
            "Adobe Acrobate Reader Is Installed And Set As Default !"
            break
        }
        elseif(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Acrobat.exe' -erroraction 'silentlycontinue')
        {
            if(isWindows11)
            {
                .\extension\SetUserFTA\SetUserFTA.exe .pdf AcroExch.Document.DC
            }else
            {
                .\extension\SetUserFTA\SetUserFTA.exe .pdf Acrobat.Document.DC
            }
            "Adobe Acrobate Reader Is Installed And Set As Default !"
            break
        }
        else
        {
            PrintECT
            "Adobe Acrobat Reader Is Not Installed Yet... ($time s)"
        }
    }
    while(!(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\AcroRd32.exe' -ErrorAction 'SilentlyContinue') -or !(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Acrobat.exe' -ErrorAction 'SilentlyContinue'))
}
# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #
function CleanDesktop {

    $DesktopPath = "C:\Users\Public\Desktop"
    # Comme TeamViewer est le dernier logiciel installé par ninite,
    # cette section va attendre que ce logiciel soit installé avant de déplacer les applications dans un dossier programme
    Write-Host "Cleaning Desktop..."
    do{
        Start-Sleep -s 10
        if(Get-ItemProperty "C:\Users\Public\Desktop\TeamViewer.lnk" -erroraction 'silentlycontinue')
        {
            #Nettoie le bureau
            ## Cette section crée un dossier "Programme" sur le bureau
            ## Tous les logiciels installés sur le bureau seront deplacés dans ce dossier
            mkdir $DesktopPath\Programmes
            Get-Item -Path "C:\Users\Public\Desktop\*.lnk" | Move-Item -Destination $DesktopPath"\Programmes"

            Write-Host "Desktop Is Now Clean !"
        } else
        {
            PrintECT
            Write-Host "Waiting For Ninite To Be Done... ('CTRL + C' To Stop)"
        }
        
    }
    while (!(Get-ItemProperty $DesktopPath"\Programmes\TeamViewer.lnk" -erroraction 'silentlycontinue'))

}
# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #

Function OptimizeAndRestorePoint{
    Optimize-Volume -DriveLetter C
    Enable-ComputerRestore -Drive "C:"
    vssadmin resize shadowstorage /for=C: /on=C: /maxsize=10GB
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value 0 -PropertyType DWORD -Force
    Checkpoint-Computer -Description "1"
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Force
}

Function EndOfScript
{
    $window = New-Object -ComObject Wscript.Shell

    if(isWindows11)
    {
        $window.popup("Every Thing Should Be Install.",0, "Windows 11 Install")
    }elseif (!isWindows11)
    {
        if($installationType -eq 1)
        {
            $window.popup("Please Install Adobe And Lenovo Manually If Needed !",0, "Windows 10 Install")
        } elseif($installationType -eq 2)
        {
            $window.popup("Please Install Adobe, Messenger and Lenovo Manually If Needed !",0, "Windows 10 Install")
        }
    }
}
# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------------------------ #
# Cette section ne fait qu'invoquer des fonctions qui ont été défini plus haut
PrintECT

ChooseInstallationType

WifiConnection

UninstallOneDrive

if(isWindows11)
{
    Install-WinGet
}

DisableConfigBlueScreen

SetDesktopIcons

SetTaskbarSettings

SetAlimentationSettings

InstallPrograms

SetDefaultWebBrowser

SetDefaultPDFReader

CleanDesktop

OptimizeAndRestorePoint

EndOfScript

# Redémarrer explorer.exe pour s'assurer que les changements ont été appliqués
Stop-Process -Name explorer