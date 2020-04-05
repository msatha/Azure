function GetAzUsers($tenant){

    $ReqTokenBody = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        client_Id     = $tenant.clientID
        Client_Secret = $tenant.clientSecret
    } 

    $TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($tenant.tenantName)/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
    #$apiUrl = 'https://graph.microsoft.com/beta/Users?$top=999'
    $apiUrl = 'https://graph.microsoft.com/beta/Users/'
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
    $users = ($Data | select-object Value).Value
    #$users | Format-Table displayName,id, userType, mail, userPrincipalName,accountEnabled,givenName,surname,immutableId -AutoSize

    $users = Invoke-RestMethod -Method Get -Headers @{
        Authorization   = "Bearer $($Tokenresponse.access_token)"
        'Content-Type'  = "application/json"
        # unremark if you just want the DeltaLink from now
        # 'ocp-aad-dq-include-only-delta-token' = "true"
    } -Uri $apiUrl

    #$users | Export-Csv "c:\temp\users.csv"
    #"Retrieved Users " + $users.value.Count

    # An Array for the retuned objects to go into 
    $tenantObjects = @()
    # Add in our first objects
    $tenantObjects += $users.value
    $moreObjects = $users 

    # Get all the remaining objects in batches
    if ($users.'@odata.nextLink'){
        #$moreObjects.'aad.nextLink' = $users.'@odata.nextLink'
        do
            {
                $users = Invoke-RestMethod -Method Get -Headers @{
                Authorization   =  "Bearer $($Tokenresponse.access_token)"
                'Content-Type'  = "application/json"
                } -Uri ($users.'@odata.nextLink')
            #"Retrieved Users " + $moreObjects.value.count
                #write-host $users.'@odata.nextLink'
                write-host "tenantObjects count: $($tenantObjects.count)"
                $tenantObjects += $users.value
            } while ($users.'@odata.nextLink')
    }

    write-host "Total Users $($tenantObjects.count)"

    return $tenantObjects

}

