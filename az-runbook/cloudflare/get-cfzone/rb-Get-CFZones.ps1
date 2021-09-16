<#
.SYNOPSIS
    Quick PowerShell function to obtain your CloudFlare Zones using the v4 API
    This PowerShell script was automatically converted to PowerShell Workflow so it can be run as a runbook.
	Specific changes that have been made are marked with a comment starting with “Converter:”
.DESCRIPTION
    This function is to obtain a list of zones on your CloudFlare account
    You can then use the returned id for other CloudFlare API calls. 
    https://api.cloudflare.com/
.PARAMETER Token
    Obtain your API token here: https://support.cloudflare.com/hc/en-us/articles/200167836-Where-do-I-find-my-Cloudflare-API-key-
.PARAMETER EMail
    This is typically the e-mail you login to the CloudFlare Dashboard with.
.EXAMPLE
   C:\Temp> Get-CFZones -Token your-api-key -E-Mail your@email.address
.NOTES
    Author: Sterling Hammer @CDLHamma - www.hammertime.tech
#>

workflow rb-Get-CFZones {
	
	# Converter: Wrapping initial script in an InlineScript activity, and passing any parameters for use within the InlineScript
	# Converter: If you want this InlineScript to execute on another host rather than the Automation worker, simply add some combination of -PSComputerName, -PSCredential, -PSConnectionURI, or other workflow common parameters (http://technet.microsoft.com/en-us/library/jj129719.aspx) as parameters of the InlineScript
	inlineScript {
		function Get-CFZones {
    		param (
        		[Parameter(Mandatory = $true)]
        		[string]$Token,
		
        		[Parameter(Mandatory = $true)]
        		[string]$EMail
    		)
    		$APIURI = 'https://api.cloudflare.com/client/v4'
    		#Build required header for authentication
    		$Headers = @{
        		'X-Auth-Key'   = $Token
        		'X-Auth-Email' = $EMail
    		}
    		$Zones = Invoke-RestMethod -Headers $Headers -Uri $APIURI/zones
    		$ZoneOutput = @()
    		foreach ($zone in $Zones.result) {
        		$ZoneOutput += [PSCustomObject]@{
            		"Id"           = $Zone.id
            		"Name"         = $Zone.name
            		"Status"       = $Zone.status
            		"Paused"       = $Zone.paused
            		"Name Servers" = $Zone.name_servers
        		}
    		}
    		Write-Output $ZoneOutput
		}
		
		$APIToken = Get-AutomationVariable -Name 'APIToken'             #variable set on share az resources (Variables)
		$AccountEmail = Get-AutomationVariable -Name 'AccountEmail'     #variable set on share az resources (Variables)
		
		#Grab a list of CloudFlare Zones on your account
		Get-CFZones -Token $APIToken -EMail $AccountEmail
		
		#Grab a specific Zone ID - this will be used in other CloudFlare API Calls
		(Get-CFZones -Token $APIToken -EMail $AccountEmail |where Name -eq yourdomain.com).Id
	}
}