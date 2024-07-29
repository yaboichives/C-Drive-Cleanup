# Make sure you configure the parameter below before running the code.
# This script will go into each user profile, grant full permissions to the admin user you specify, and then delete the specified cache.
param (
    # Set the cache or file that needs to be recursively deleted
    [string]$ChromeCachePath = "C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\Cache"
)
# Get the current user running the script
$currentUsername = $env:USERNAME
$currentDomain = $env:USERDOMAIN

# Initialize a variable to store the total size of deleted files
$totalFreedSpace = 0

$userProfiles = Get-ChildItem -Path C:\Users -Directory

foreach ($profile in $userProfiles) {
    $chromeCachePathForUser = Join-Path $profile.FullName "AppData\Local\Google\Chrome\User Data\Default\Cache"
    Write-Host "Processing user profile: $($profile.FullName)"

    if (Test-Path $chromeCachePathForUser) {
        try {
            # Grant full control permissions to the specified user
            $acl = Get-Acl -path $profile.FullName
            $identity = "$currentDomain\$currentUsername"
            $fileSystemRights = "FullControl"
            $type = "Allow"
            $fileSystemAccessRuleArguementList = $identity, $fileSystemRights, $type
            $accessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArguementList
            $acl.SetAccessRule($accessRule)
            Set-Acl -Path $profile.FullName -AclObject $acl
            Set-Acl -Path $chromeCachePathForUser -AclObject $acl


            # Get the size of the Chrome cache folder before deletion
            $beforeSize = (Get-ChildItem -Path $chromeCachePathForUser -Recurse | Measure-Object -Property Length -Sum).Sum

            # Remove Chrome cache folder
            Remove-Item -Path $chromeCachePathForUser -Recurse -Force -ErrorAction Stop
            Write-Host "Cleared Chrome Cache for $($profile.FullName)"

            # Get the size of the Chrome cache folder after deletion
            $afterSize = (Get-ChildItem -Path $chromeCachePathForUser -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum

            # Calculate the freed space and add it to the total
            $freedSpace = $beforeSize - $afterSize
            $totalFreedSpace += $freedSpace
            Write-Host "Freed Space for $($profile.FullName): $($freedSpace / 1MB) MB"
        } catch {
            if ($_.Exception.Message -match "Access to the path") {
                Write-Host "Access denied: $($profile.FullName)"
            } else {
                Write-Host "Error: $($_.Exception.Message)"
            }
        }
    } else {
        Write-Host "Chrome cache folder not found for $($profile.FullName)"
    }
}

Write-Host "-------------------------------"
Write-Host "Total Freed Space: $($totalFreedSpace / 1MB) MB"
Write-Host "Chrome cache cleanup completed"
