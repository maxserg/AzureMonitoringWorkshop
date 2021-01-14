$uri = ""
$vm  = @(
            @{ vmname="test-vm01"}
        )
$body = ConvertTo-Json -InputObject $vm
$header = @{ message="StartedbyContoso"}
$response = Invoke-WebRequest -Method Post -Uri $uri -Body $body -Headers $header