$uri = "https://9ac0f748-d067-48aa-a9e1-10fbcc2d9977.webhook.eus2.azure-automation.net/webhooks?token=FRGBmp62ydq%2bCPIuUL%2fna3lsfkC3dxphOjtn9v4kKwA%3d"
$vm  = "test-vm01"
$body = ConvertTo-Json -InputObject $vm
$header = @{ message="StartedbyContoso"}
$response = Invoke-WebRequest -Method Post -Uri $uri -Body $body -Headers $header