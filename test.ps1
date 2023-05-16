
$wallpaperPath = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Themes"
Remove-Item -Path "$wallpaperPath\TranscodedWallpaper"
Copy-Item -Path .\extension\wallpaper.jpg -Destination "$wallpaperPath\TranscodedWallpaper"
Remove-Item -Path "$wallpaperPath\CachedFiles" -Recurse