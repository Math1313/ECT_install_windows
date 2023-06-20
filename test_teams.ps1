$TeamsAutoRun = (Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -ea SilentlyContinue)."com.squirrel.Teams.Teams"
if ($TeamsAutoRun)
{
    Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name "com.squirrel.Teams.Teams"
}

# Teams Config Data
$TeamsConfig = "$env:APPDATA\Microsoft\Teams\desktop-config.json"
$global:TeamsConfigData = Get-Content $TeamsConfig -Raw -ea SilentlyContinue | ConvertFrom-Json

# If Teams already doesn't have the autostart config, exit
If ($TeamsConfigData)
{
    If ($TeamsConfigData.appPreferenceSettings.openAtLogin -eq $false)
    {
        # It's already configured to not startup
        exit
    }
    else
    {
        # If Teams hasn't run, then it's not going to have the openAtLogin:true value
        # Otherwise, replace openAtLogin:true with openAtLogin:false
        If ($TeamsConfigData.appPreferenceSettings.openAtLogin -eq $true)
        {
            $TeamsConfigData.appPreferenceSettings.openAtLogin = $false
        }
        else
        # If Teams has been intalled but hasn't been run yet, it won't have an autorun setting
        {
            $Values = ($TeamsConfigData.appPreferenceSettings | Get-Member -MemberType NoteProperty).Name
            If ($Values -match "openAtLogin")
            {
                $TeamsConfigData.appPreferenceSettings.openAtLogin = $false
            }
            else
            {
                $TeamsConfigData.appPreferenceSettings | Add-Member -Name "openAtLogin" -Value $false -MemberType NoteProperty
            }
        }
        # Save
        $TeamsConfigData | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $TeamsConfig -Force
    }
}