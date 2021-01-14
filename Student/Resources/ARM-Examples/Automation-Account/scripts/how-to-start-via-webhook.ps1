$uri = ""
$vm  = ""
$body = ConvertTo-Json -InputObject $vm
$header = "StartedbyContoso"
$response = Invoke-WebRequest -Method Post -Uri $uri -Body $body -Headers $header
