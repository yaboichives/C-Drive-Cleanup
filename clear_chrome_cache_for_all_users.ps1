#Define the path to the chrome cache folder

$ChromeCachePath = "C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\Cache"

#Get all user profiles by looking at folders in C:users
$userProfiles = Get-ChildItem -path C:\Users -Directory

foreach ($profile in $userProfiles) 
	{$chromeCachePathForUser = Join-Path $profile.FullName "AppData\Local\Google\Chrome\User Data\Default\Cache"
	Write-Host "Processing user profile: $($profile.FullName)"
    
    #remove chrome cache folder
    Remove-Item -Path $chromeCachePathForUser -Recurse -Force
    Write-Host " Cleared Chrome Cache for $($profile.FullName)"
	}
else
    {Write-Host " Chrome cache folder not found for $($profile.FullName)"
    }

Write-Host "-------------------------------"

Write-Host "Chrome cache cleanup completed"


	
