
function InviteAzGuestUser($tenant,$inviteEmailAddress){

    $invitationRedirectURL = "https://pimsdb.sharepoint.com"
    $inviteBody = @{"invitedUserEmailAddress" = $inviteEmailAddress; "inviteRedirectUrl"= $invitationRedirectURL; "sendInvitationMessage"= $false}
    $inviteBody = $inviteBody | ConvertTo-Json

    $ReqTokenBody = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        client_Id     = $tenant.clientID
        Client_Secret = $tenant.clientSecret
    } 

    $TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($tenant.tenantName)/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
    $apiUrl = 'https://graph.microsoft.com/beta/invitations/'
    $invite = Invoke-RestMethod -Headers @{
        Authorization = "Bearer $($Tokenresponse.access_token)"  
        'Content-Type'  = "application/json"
    } -Uri $apiUrl -Method POST  -Body $inviteBody

  
    return $invite
}

