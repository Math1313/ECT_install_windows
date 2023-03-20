#Function to install Winget
##Winget is use to install other program directly from the Microsoft Store like Adobe Reader or Lenovo Commercial Vantage

Function Install-WinGet {
    #Install the latest package from GitHub
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

    #test for requirement
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
        #$data = $get | Select-Object -first 1
        $data = $get[0].assets | Where-Object name -Match 'msixbundle'

        $appx = $data.browser_download_url
        #$data.assets[0].browser_download_url
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
    } #Try
    Catch {
        Write-Verbose "[$((Get-Date).TimeofDay)] There was an error."
        Throw $_
    }
    Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"
}

Function SetDesktopIcons {
    #------------------------------------------------------------------------------------#
    # Desktop
    # This PC = {20D04FE0-3AEA-1069-A2D8-08002B30309D}
    # Configuration Panel = {5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}
    # User = {59031a47-3f72-44a7-89c5-5595fe6b30ee}
    # Network = {F02C1A0D-BE21-4350-88B0-7367FC96EF3C}
    # RecycleBin  = {645FF040-5081-101B-9F08-00AA002F954E}
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

function SetTaskbarSettings {
    #Taskbar
    ## Define taskbar position
    ##(Value 0 = Left)
    ##(Value 1 = Center)
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Force

    ## Search box
    ## (Value 0 = No magnifying glass)
    ## (Value 1 = Only magnifying glass)
    ## (Value 2 = Magnifying glass with search box)
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchBoxTaskbarMode" -Value 1 -Type DWord -Force
    ## TaskView Icon
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Force
    ## Widget Icon
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Force
    ## Chat Icon
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -Force
    
}

function SetAlimentationSettings {
    #Alimentation (Delay in minute, 0 = never)
    ##Shutdown screen - Connected 
    powercfg /change monitor-timeout-ac 0
    ##Shutdown screen - On battery
    powercfg /change monitor-timeout-dc 0

    ##Standby - Connected 
    powercfg /change standby-timeout-ac 0
    ##Standby screen - On battery
    powercfg /change standby-timeout-dc 0

    ##Stop Disk - Connected
    powercfg /change disk-timeout-ac 0
    ##Stop Disk - On battery
    powercfg /change disk-timeout-dc 20


    ##(Value 0 = Do nothing)
    ##(Value 1 = Sleep)
    ##(Value 2 = Stanby / Sleep more than sleep)
    ##(Value 3 = Shutdown)

    ##When power button is clicked
    ## Connected
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 1
    ## On battery
    powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 1

    ##When sleep button is clicked
    ## Connected
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
    ## On battery
    powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0

    ##When lid is closed
    ## Connected
    powercfg /setACvalueIndex scheme_current sub_buttons lidAction 0
    ## On battery
    powercfg /setDCvalueIndex scheme_current sub_buttons lidAction 2
}

function InstallPrograms {
    # Program
    ##Install Acrobat Reader
    winget install --id "Adobe.Acrobat.Reader.32-bit" --accept-package-agreements --accept-source-agreements

    ##Manufacturer
    ##Get manufacturer of the PC
    $make = (Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer

    ##Get the path to where it install the manufacturer setup file
    $location = Get-Location
    $filename = "\manufacturer.exe"
    $filepath = "$location$filename"

    ##Remove the previous manufacturer setup from previous installation
    if(Test-Path -Path $filepath)
    {
        Remove-Item manufacturer.exe
    }

    ##If manufacturer is Dell, download SupportAssist
    if($make -eq "Dell Inc.")
    {
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile("https://downloads.dell.com/serviceability/catalog/SupportAssistInstaller.exe", $filepath)
        .\manufacturer.exe
    }elseif($make -eq "LENOVO") ##If manufacturer is LENOVO, download Lenovo Commercial Vantage
    {
        winget install "Lenovo Commercial Vantage" --disable-interactivity --accept-package-agreements
    }

    ## Launch Ninite
    ## To work, you need to replace to name of your ninite by "ninite.exe" or rename the .exe file below
    ## The ninite file also need to be place in the same folder than the script
    ## If you prefer you can change the path of the file below
    .\extension\ninite.exe
}

function SetDefaultApps {
    # Wait till Chrome is installed to set him as default browser
    # SetUserFTA.exe is a tool to change default file type association
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
            "Google Chrome Is Not Installed Yet..."
        }
        
    }
    while (!(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe' -erroraction 'silentlycontinue'))

    # Check if Adobe Acrobat Reader is installed
    if(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\AcroRd32.exe' -erroraction 'silentlycontinue')
    {
        .\extension\SetUserFTA\SetUserFTA.exe .pdf AcroExch.Document.DC
        "Adobe Acrobate Reader Is Installed And Set As Default !"
    } else
    {
        "Adobe Acrobate Reader Could Not Be Install..."
        "Please Install It Manually."
    }
    
}

function CleanDesktop {
    # Since TeamViewer is the last software installed by ninite,
    # this section wait till ninite is done to move the shortcut on the desktop
    Write-Host "Cleaning Desktop..."
    do{
        Start-Sleep -s 10
        if(Get-ItemProperty "C:\Program Files\TeamViewer\TeamViewer.exe" -erroraction 'silentlycontinue')
        {
            #Clean Desktop
            ## This section create a folder name "Programme" on the desktop
            ## Every shortcut install by the script will automatically be move in this new folder
            $DesktopPath = [Environment]::GetFolderPath("Desktop")
            mkdir $DesktopPath\Programmes

            Move-Item -Path "C:\Users\Public\Desktop\Google Chrome.lnk" -Destination $DesktopPath"\Programmes\Google Chrome.lnk"
            Move-Item -Path "C:\Users\Public\Desktop\Microsoft Edge.lnk" -Destination $DesktopPath"\Programmes\Microsoft Edge.lnk" 
            Move-Item -Path "C:\Users\Public\Desktop\Acrobat Reader.lnk" -Destination $DesktopPath"\Programmes\Acrobat Reader.lnk"
            Move-Item -Path "C:\Users\Public\Desktop\TeamViewer.lnk" -Destination $DesktopPath"\Programmes\TeamViewer.lnk"
            Move-Item -Path "C:\Users\Public\Desktop\VLC media player.lnk" -Destination $DesktopPath"\Programmes\VLC media player.lnk"
            Write-Host "Desktop Is Now Clean !"
        } else
        {
            Write-Host "Waiting For Ninite To Be Done... ('CTRL + C' To Stop)"
        }
        
    }
    while (!(Get-ItemProperty "C:\Program Files\TeamViewer\TeamViewer.exe" -erroraction 'silentlycontinue'))

}

Clear-Host
" __      __.__            .___                      _____             "
"/  \    /  \__| ____    __| _/______  _  ________ _/ ____\___________ "
"\   \/\/   /  |/    \  / __ |/  _ \ \/ \/ /  ___/ \   __\/  _ \_  __ \"
" \        /|  |   |  \/ /_/ (  <_> )     /\___ \   |  | (  <_> )  | \/"
"  \__/\__/ |__|___|  /\____ |\____/ \/\_//______>  |__|  \____/|__|   "
"___________.__                 __                                       ___________           .__     "
"\_   _____/|  |   ____   _____/  |________  ____   ____  ____   _____   \__    ___/___   ____ |  |__  "
" |    __)_ |  | _/ __ \_/ ___\   __\_  __ \/  _ \_/ ___\/  _ \ /     \    |    |_/ __ \_/ ___\|  |  \ "
" |        \|  |_\  ___/\  \___|  |  |  | \(  <_> )  \__(  <_> )  Y Y  \   |    |\  ___/\  \___|   Y  \"
"/_________/|____/\_____>\_____>__|  |__|   \____/ \_____>____/|__|_|__/   |____| \_____>\_____>___|__/"

Install-WinGet

SetDesktopIcons

SetTaskbarSettings

SetAlimentationSettings

InstallPrograms

SetDefaultApps

CleanDesktop

# Relauch windows explorer to apply changes
Stop-Process -Name explorer