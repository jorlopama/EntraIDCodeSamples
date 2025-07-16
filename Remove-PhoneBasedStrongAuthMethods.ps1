#Script will remove only phone based MFA methods from users in Microsoft Entra ID
# Requires the Microsoft Graph PowerShell SDK (Install-Module Microsoft.Graph -Scope CurrentUser) 
# Ensure you have the necessary permissions: UserAuthenticationMethod.ReadWrite.All

# Define log file
$logFile = "Remove-PhoneMFA-Log.txt"
Start-Transcript -Path $logFile -Append

# Import required module
Import-Module Microsoft.Graph.Identity.SignIns

# Connect to Microsoft Graph with required scopes
Connect-MgGraph -Scopes "UserAuthenticationMethod.ReadWrite.All"

# Prompt for CSV file path
$csvPath = Read-Host -Prompt "Enter the path to the CSV file containing user UPNs (default: 'users.csv')"

# Use default if no input provided
if ([string]::IsNullOrWhiteSpace($csvPath)) {
    $csvPath = "users.csv"
}

# Validate file exists
if (-not (Test-Path -Path $csvPath)) {
    Write-Error "CSV file not found at path: $csvPath"
    Stop-Transcript
    exit
}

# Import users from CSV
# CSV should have a column named 'UserPrincipalName'
$users = Import-Csv -Path $csvPath

foreach ($user in $users) {
    Write-Verbose "Processing user: $($user.UserPrincipalName)" -Verbose
    try {
        # Get all authentication methods for the user
        $methods = Get-MgUserAuthenticationPhoneMethod -UserId $user.UserPrincipalName

        foreach ($method in $methods) {
            if ($method.PhoneType -eq "mobile" -or $method.PhoneType -eq "alternateMobile")  {
                Write-Verbose "Deleting phone method for $($user.UserPrincipalName): $($method.Id)" -Verbose
                Remove-MgUserAuthenticationMethod -UserId $user.UserPrincipalName -AuthenticationMethodId $method.Id
                Write-Output "Removed phone MFA method for $($user.UserPrincipalName)" | Out-File -FilePath $logFile -Append
            }
        }
    }
    catch {
        $errorMessage = "Error processing $($user.UserPrincipalName): $_"
        Write-Warning $errorMessage
        $errorMessage | Out-File -FilePath $logFile -Append
    }
}

Stop-Transcript