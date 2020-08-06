#*------v Get-ModulePublishedVersion.ps1 v------
function Get-ModulePublishedVersion {
    <#
    .SYNOPSIS
    Get-ModulePublishedVersion - Query the most current version of a published module
    .NOTES
    Version     : 1.0.0.0
Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-08-06
    FileName    : Get-ModulePublishedVersion.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka
    Tags        : Powershell,Module,Lifecycle
    AddedCredit : idera
    AddedWebsite: https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/getting-latest-powershell-gallery-module-version
    AddedTwitter: 
    REVISIONS
    * 10:55 AM 8/6/2020 tsk: substantially rewrote from base url-retrieval snippet 
    * Posted vers has no datestamp, comments "more than 4 yrs ago"
    .DESCRIPTION
    Get-ModulePublishedVersion - Query the most current version of a published module
    Where no -Modules are specified, get-InstalledModule retrieves all PSGallery modules, and prompts for selections using Out-Gridview. 
    Repository is defaulted to a regex, because MS can't settle on a *single* Repository value for their range of PSG modules: Some use a full https...powershellgallery url, and some the abbreviating tag 'PSRepository'. 
    And *bonus* the old url value doesn't even work properly with the Update-Module cmdlet (throws not found). Have to use Find-Module -Name xxx, to properly locate & update those items.
    Product of the official PSGallery Repository string dropping the trailing '/' from the https specification, in a later revision. 
    Code to force update modules with the older trailing-/ Repository property:
    #-=-fix/force-reinstall archaic broken repo modules=-=-=-=-=-=-=
    # PSG repo ref changed from ending in '/', to not ending in '/', which broke update-module use on all of the older ref mods
    Get-InstalledModule |? { $_.Repository -eq 'https://www.powershellgallery.com/api/v2/' } |
      % { Install-Package -Name $_.Name -Source PSGallery -Force -whatif } ; 
#-=-=-=-=-=-=-=-=
    .PARAMETER Modules
    Specific Module(s) to be processed[-Modules array-of-module-descrptors]
    .PARAMETER Repository
    Regex matching Source Repository for which Modules should to be processed[-Repository PSGallery]
    .EXAMPLE
    Get-ModulePublishedVersion -Modules ISESteroids
    Retrieve latest vers of ISESteriods psg module
    .EXAMPLE
    Get-ModulePublishedVersion -Modules 'Azure','ExchangeOnlineManagement','Microsoft.Graph','MicrosoftTeams','MSOnline','AzureRM' -verbose
    Get update info about specific modules
    .EXAMPLE
    Get-ModulePublishedVersion -Modules 'Azure' -Repository '(https://www\.powershellgallery\.com/api/v2/|PSGallery)' -verbose
    Get update info about specific modules from a targeted Repository tag (the MS variant strings targeted in this example)
    .EXAMPLE
    $ModsStatus = Get-ModulePublishedVersion -Modules 'Azure','ExchangeOnlineManagement','Microsoft.Graph','MicrosoftTeams','MSOnline','AzureRM';
    $whatif = $true ; 
    foreach ($mod in ($ModsStatus|?{$_.status -like 'UPGRADE*'})){
      "===$($mod.ModuleName):" ;
      switch -regex ($mod.Repository){
          "PSGallery" {get-installedmodule -name $mod.modulename | Update-Module -whatif:$($whatif) }
          "https://www\.powershellgallery\.com/api/v2/" {
              write-host -foregroundcolor yellow "$($mod.modulename) has archaic 'uri' Repository value, running Install-Package -force to update from current repo..." ; 
              Install-Package -Name $mod.modulename -Source PSGallery -Force -whatif:$($whatif) ;
          }  
      } ;
    } ;
    Store update info about specific modules into a variable then run updates (via update-Module or Install-Package) against available upgrades
    .LINK
    https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/getting-latest-powershell-gallery-module-version
    #>
    [CmdletBinding()] 
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Specific Module(s) to be processed[-Modules array-of-module-descrptors]")]
        [Alias('Name')]$Modules,
        [Parameter(HelpMessage="Regex matching Source Repository for which Modules should to be processed[-Repository PSGallery]")]
        [regex]$Repository
    ) ; 
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") 
        if(!$ThrottleMs){$ThrottleMs=500 }
        # PSG root url used to build rev queries
        $PSGBaseQryUrl = "https://www.powershellgallery.com/packages/" ; 
        # PSG MS Repository value (where they've used a full uri) - used to build a match regex for filtering MS PSG-hosted modules
        $PSGregexURI = 'https://www.powershellgallery.com/api/v2/'
        [regex]$rgxPSGMsRepoTag =  ('(' + ((($PSGregexURI,'PSGallery') |%{[regex]::escape($_)}) -join '|') + ')') ; 
        if(!$Repository){$Repository = $rgxPSGMsRepoTag } ; 
    } ;
    PROCESS {
        if(!$Modules){
            $smsg = "Gathering all installed modules..." ; 
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" 
            $tModules = get-installedmodule ;
            if($Repository){
                $tModules = $tModules|?{$_.Repository -match $Repository}  ; 
            } ; 
            $tModules = $tModules| Out-GridView -Title 'Select the module(s) you want the version information from.' -PassThru ; 
        } else { 
            $smsg = "$(($Modules|measure).count) specific Modules specified`n$(($Modules|out-string).trim())" ; 
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            $tModules = ($modules | %{get-installedmodule $_ | write-output } ) ;
            if($Repository){
                $tModules = $tModules|?{$_.Repository -match $Repository} ; 
            } ; 
        } ; 
        $ttl=($tModules|Measure-Object).count ;
        $Procd=0 ; 
        $smsg = "($(($tModules|measure).count) modules returned)" ; 
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)"  ;

        $Report = @() ;
        foreach ($Module in $tModules) {
            $Procd++ ;
            #$sBnr="#*======v ($($Procd)/$($ttl)):PROCESSING:$($Module.name) v======" ; 
            #$sBnr="===($($Procd)/$($ttl)):Processing:$($Module.name)" ; 
            $smsg = "===($($Procd)/$($ttl)):Processing:$($Module.name)" ; 
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)"  ;
            
            # access the main module page, and add a random number to trick proxies
            $url = "$($PSGBaseQryUrl)$($Module.name)/?dummy=$(Get-Random)" ; 
            write-verbose "using url:$($url)" ; 
            $request = [System.Net.WebRequest]::Create($url) ; 
            # do not allow to redirect. The result is a "MovedPermanently"
            $request.AllowAutoRedirect=$false ; 
            try {
                # send the request
                $response = $request.GetResponse() ; 
                # get back the URL of the true destination page, and split off the version
                $PublVers = $response.GetResponseHeader("Location").Split("/")[-1] -as [Version] ; 
                # make sure to clean up
                $response.Close() ; 
                $response.Dispose() ; 
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg= "Failed to exec cmd because: $($ErrTrapd)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
                Continue ;#Continue/Exit/Stop
            } ;  
            $stat =  [ordered]@{
                ModuleName = $Module.name ; 
                CurrentVers = $module.Version.tostring() ; 
                PublishedVers = $PublVers.tostring() ; 
                Status = if($module.Version -lt $PublVers){"UPGRADE AVAIL"}else{""} ; 
                Repository = $module.Repository ; 
            } ; 
            $Report += new-object psobject -Property $stat ; 
            start-sleep -Milliseconds $ThrottleMs ; 
        } ; # loop-E
    } ; 
    END{
        $Report| sort status,modulename | write-output ; 
    } ;
} ; 
#*------^ Get-ModulePublishedVersion.ps1 ^------