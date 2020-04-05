function DeleteAzUser($tenant,$userID){

    $ReqTokenBody = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        client_Id     = $tenant.clientID
        Client_Secret = $tenant.clientSecret
    } 

    $TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($tenant.tenantName)/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
    $apiUrl = 'https://graph.microsoft.com/beta/users/{'+$userID+'}'
    $deletedUser = Invoke-RestMethod -Headers @{
        Authorization = "Bearer $($Tokenresponse.access_token)"  
        'Content-Type'  = "application/json"
    } -Uri $apiUrl -Method DELETE 

  
    return $deletedUser
}

#$tenant = @{tenantName="contoso.onmicrosoft.com";clientId="";clientSecret="";domains=@("contoso.onmicrosoft.com","contoso.com") }
#$deletedUser = DeleteAzUser $tenant "userId-guid"

