<#
.SYNOPSIS
    Quick PowerShell function to obtain your CloudFlare Zones using the v4 API
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
    Credits to: Sterling Hammer
#>

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

$APIToken = "your-api-key"
$AccountEmail = "your@e-mail.address"

#Grab a list of CloudFlare Zones on your account
Get-CFZones -Token $APIToken -EMail $AccountEmail

#Grab a specific Zone ID - this will be used in other CloudFlare API Calls
(Get-CFZones -Token $APIToken -EMail $AccountEmail |where Name -eq yourdomain.com).Id