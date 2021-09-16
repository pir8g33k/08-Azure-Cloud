<#
.SYNOPSIS
    Quick PowerShell function to purge your CloudFlare Cache for a specific zone
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
function Invoke-CFPurgeCache {
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
        $requestResult = Invoke-RestMethod -Method Post -ContentType application/json -Headers $Headers -Uri $APIURI/zones/$Zone/purge_cache -Body $PayloadJSON -ErrorAction Stop
        if ($requestResult.success -eq $true) {
            Write-Verbose -Message "$(Get-Date) :: Successfully cleared cache for zone $($requestResult.result.id)" -Verbose
        }
        else {
            Write-Verbose -Message "$(Get-Date) :: Failed to purge cache for $($requestResult.result.id)" -Verbose
            Write-Verbose -Message "$(Get-Date) :: Errors encountered $($requestResult.errors)"
        }
    }
    catch {
        Write-Error $_
    }
}

$APIToken = "your-api-key"
$AccountEmail = "your@e-mail.address"
$MyZone = "your-cloudflare-zoneid"

Invoke-CFPurgeCache -Token $APIToken -EMail $AccountEmail -Zone $MyZone 