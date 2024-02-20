Install-Module Microsoft.Graph -Scope CurrentUser

Connect-MgGraph -Scopes "User.readWrite.all"
#Select-MgProfile Beta
$graphApp = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"

$PermissionName = "User.ReadWrite.All"
$AppRole = $graphApp.AppRoles | `
Where-Object {$_.Value -eq $PermissionName -and $_.AllowedMemberTypes -contains "Application"}
#Below Line needs to be modifed in order to give access to the ManagedIdentity of the Logic App
$managedID = Get-MgServicePrincipal -Filter "DisplayName eq '<<AppNAme>>'"
New-MgServicePrincipalAppRoleAssignment -PrincipalId $managedID.Id -ServicePrincipalId $managedID.Id -ResourceId $graphApp.Id -AppRoleId $AppRole.Id

