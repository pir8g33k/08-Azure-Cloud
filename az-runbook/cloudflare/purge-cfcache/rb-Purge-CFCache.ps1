<#
.SYNOPSIS
    Quick PowerShell function to purge your CloudFlare Cache for a specific zone
    This PowerShell script was automatically converted to PowerShell Workflow so it can be run as a runbook.
	Specific changes that have been made are marked with a comment starting with “Converter:”
.DESCRIPTION
    This is a simple function to purge CloudFlare cache for a specific zone, can be integrated with an 
    Azure DevOps (or equivalent) pipeline.
.PARAMETER Token
    Obtain your API token here: 
    https://support.cloudflare.com/hc/en-us/articles/200167836-Where-do-I-find-my-Cloudflare-API-key-
.PARAMETER EMail
    This is typically the e-mail you login to the CloudFlare Dashboard with.
.PARAMETER Zone
    You'll need your ZoneID which you can obtain from the Cloudflare dashboard or Get-CFZones
.EXAMPLE
   C:\Temp> Invoke-CFPurgeCache -Token your-api-key -E-Mail your@email.address -Zone your-cf-zoneid
.NOTES
    Credits: Sterling Hammer 
#>
workflow rb-purge-cf-cache
{
    		param (
        		[Parameter(Mandatory = $true)]
        		[string]$Token,
		
        		[Parameter(Mandatory = $true)]
        		[string]$EMail,
		
        		[Parameter(Mandatory = $true)]
        		[string]$Zone
    		)
    		$APIURI = 'https://api.cloudflare.com/client/v4'
    		#Build required header for authentication
    		$Headers = @{
        		'X-Auth-Key'   = $Token
        		'X-Auth-Email' = $EMail
    		}
    		#Build required payload - can be later expanded to purge specific files.
    		$Payload = @{
        		purge_everything = $true
    		}
    		#Make the payload JSON friendly
    		$PayloadJSON = $Payload |ConvertTo-Json
		
    		try {
        		Write-Verbose -Message "$(Get-Date) :: Attempting to flush CloudFlare Cache for $($Zone)" -Verbose
                Write-Output "$(Get-Date) :: Attempting to flush CloudFlare Cache for $($Zone)"
        		$requestResult = Invoke-RestMethod -Method Post -ContentType application/json -Headers $Headers -Uri $APIURI/zones/$Zone/purge_cache -Body $PayloadJSON -ErrorAction Stop
        		if ($requestResult.success -eq $true) {
            		Write-Verbose -Message "$(Get-Date) :: Successfully cleared cache for zone $($requestResult.result.id)" -Verbose
                    Write-Output "$(Get-Date) :: Successfully cleared cache for zone $($requestResult.result.id)"
        		}
        		else {
            		Write-Verbose -Message "$(Get-Date) :: Failed to purge cache for $($requestResult.result.id)" -Verbose
                    Write-Output "$(Get-Date) :: Failed to purge cache for $($requestResult.result.id)"
            		Write-Verbose -Message "$(Get-Date) :: Errors encountered $($requestResult.errors)"
                    Write-Output "$(Get-Date) :: Errors encountered $($requestResult.errors)"

        		}
    		}
    		catch {
        		Write-Error $_
    		}

}
