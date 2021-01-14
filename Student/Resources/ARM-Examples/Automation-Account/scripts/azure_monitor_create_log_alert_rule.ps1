param
(
    [Parameter (Mandatory = $false)]
    [object] $WebhookData
)

# provide creds for auth
$ConnectionAssetName = "AzureRunAsConnection"
$Conn = Get-AutomationConnection -Name $ConnectionAssetName
            if ($Conn -eq $null)
            {
                throw "Could not retrieve connection asset: $ConnectionAssetName. Check that this asset exists in the Automation account."
            }
            Write-Output "Authenticating to Azure with service principal."
            Add-AzAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

# Retrieve VM name from Webhook request body
$vmname = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)

# define required parameters
$workspacename = "SystemCenterCurrentBranchOMS"
$workspaceresourcegroupname = "systemcentercurrentbranch"

# main wokrflow
$workspace = Get-AzOperationalInsightsWorkspace -Name $workspacename -ResourceGroupName $workspaceresourcegroupname
$source = New-AzScheduledQueryRuleSource -Query "Heartbeat | summarize AggregatedValue = count() by bin(TimeGenerated, 5m) | where Computer == $vmname, _ResourceId" -DataSourceId $workspace.ResourceId
$schedule = New-AzScheduledQueryRuleSchedule -FrequencyInMinutes 5 -TimeWindowInMinutes 5
$metricTrigger = New-AzScheduledQueryRuleLogMetricTrigger -ThresholdOperator "GreaterThan" -Threshold 2 -MetricTriggerType "Consecutive" -MetricColumn "_ResourceId"
$triggerCondition = New-AzScheduledQueryRuleTriggerCondition -ThresholdOperator "LessThan" -Threshold 5 -MetricTrigger $metricTrigger
$alertingAction = New-AzScheduledQueryRuleAlertingAction  -Severity "3" -Trigger $triggerCondition

New-AzScheduledQueryRule -ResourceGroupName $workspaceresourcegroupname -Location "East US" -Action $alertingAction -Enabled $true -Description "Alert description" -Schedule $schedule -Source $source -Name "Demo Alert Name - $vmname"