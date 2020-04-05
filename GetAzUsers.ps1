function GetAzUsers($tenant){

    $ReqTokenBody = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        client_Id     = $tenant.clientID
        Client_Secret = $tenant.clientSecret
    } 

    $TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($tenant.tenantName)/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
    $apiUrl = 'https://graph.microsoft.com/beta/users/'
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
    $users = ($Data | select-object Value).Value

    $users = Invoke-RestMethod -Method Get -Headers @{
        Authorization   = "Bearer $($Tokenresponse.access_token)"
        'Content-Type'  = "application/json"
    } -Uri $apiUrl

    # An Array for the retuned objects to go into 
    $allUsers = @()
    # Add in our first objects
    $allUsers += $users.value

    # Get all the remaining objects in batches
    if ($users.'@odata.nextLink'){
        do
            {
                $users = Invoke-RestMethod -Method Get -Headers @{
                Authorization   =  "Bearer $($Tokenresponse.access_token)"
                'Content-Type'  = "application/json"
                } -Uri ($users.'@odata.nextLink')
                write-host "allUsers count: $($allUsers.count)"
                $allUsers += $users.value
            } while ($users.'@odata.nextLink')
    }

    write-host "Total Users $($allUsers.count)"

    return $allUsers

}

#$tenant = @{tenantName="contoso.onmicrosoft.com";clientId="";clientSecret="";domains=@("contoso.onmicrosoft.com","contoso.com") }
#$allUsers = GetAzUsers $tenant