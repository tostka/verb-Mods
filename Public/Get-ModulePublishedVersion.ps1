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
    * 4:51 PM 8/7/2020 added -noWeb (forces to use find-module), expanded to support local repos (queries get-PSRepository for local, differentiates on UNC (use find-module) v uri (use web) SourceLocation;  add & return the Path (fr get-installedmodule.InstalledLocation) for factoring updates against AllUsers & CurrentUser scopes (important distinction where users don't have local\Administrators) ; removed strong regex type on Repository, permits more flexible matching options.
    * 10:55 AM 8/6/2020 tsk: substantially rewrote from base url-retrieval snippet 
    * Posted vers has no datestamp, comments "more than 4 yrs ago"
    .DESCRIPTION
    Get-ModulePublishedVersion - Query the most current version of a published module
    Supports PSGallery (via default web access), or other modules via slower Find-Module query (trigger with -NoWeb)
    Where no -Modules are specified, get-InstalledModule retrieves all modules, and prompts for selections using Out-Gridview. 
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
    Regex matching Source Repository for which Modules should to be processed (single-word specs 'reponame' will work without regex syntax) [-Repository PSGallery]
    .PARAMETER noWeb
    Switch to force use of Find-Module (over Web access which is substantially faster)[-noWeb]
    .OUTPUT
    System.Management.Automation.PSCustomObject
    .EXAMPLE
    Get-ModulePublishedVersion -Modules AzureAD
    Retrieve latest vers of AzureAD (PSGallery) module
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
    Store update info about specific modules into a variable then run updates (via update-Module or Install-Package) against available upgrades (could postfilter on returned 'Path' value, to target AllUsers v CurrUser Module locations, as well)
    .EXAMPLE
    $modsstatus = Get-ModulePublishedVersion -Repository '(localrepo1|localrepo2)'
    $whatif = $true ;
    foreach ($mod in ($ModsStatus|?{$_.status -like 'UPGRADE*'})){
        "===$($mod.ModuleName):" ;
        get-installedmodule -name $mod.modulename | Update-Module -whatif:$($whatif)  ;
    } ;
    Query all modules on two different registered repos (as speciffied by the -Repository regex OR filter), and perform updates on matching mods
    .LINK
    https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/getting-latest-powershell-gallery-module-version
    #>
    [CmdletBinding()] 
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Specific Module(s) to be processed[-Modules array-of-module-descrptors]")]
        [Alias('Name')]$Modules,
        [Parameter(HelpMessage="Regex matching Source Repository for which Modules should to be processed[-Repository PSGallery]")]
        $Repository,
        [Parameter(HelpMessage="Switch to force use of Find-Module (over Web access which is substantially faster)[-noWeb]")]
        [switch] $noWeb
    ) ; 
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") 
        $rgxURL="https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)"

        if(!$ThrottleMs){$ThrottleMs=500 }
        # PSG root url used to build rev queries
        $PSGBaseQryUrl = "https://www.powershellgallery.com/packages/" ; 
        # PSG MS Repository value (where they've used a full uri) - used to build a match regex for filtering MS PSG-hosted modules
        $PSGregexURI = 'https://www.powershellgallery.com/api/v2/'
        [regex]$rgxPSGMsRepoTag =  ('(' + ((($PSGregexURI,'PSGallery') |%{[regex]::escape($_)}) -join '|') + ')') ; 
        if(!$Repository){$Repository = $rgxPSGMsRepoTag } ; 
        $error.clear() ;
        TRY {
            $regRepos = get-psrepository ; 
        } CATCH {
            Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
            break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ; 
    } ;
    PROCESS {
        if(!$Modules){
            $smsg = "Gathering all installed modules..." ; 
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" 
            $tModules = get-installedmodule ;
            if($Repository){
                $tModules = $tModules|?{$_.Repository -match $Repository}  ; 
            } ; 
            # display gridview to select specific targets 
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
            $smsg = "===($($Procd)/$($ttl)):Processing:$($Module.name)" ; 
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)"  ;

            $qryMethod=$null ; 
            if($tRepo = $Module.Repository = $regRepos | ?{$_.Name -eq $Module.Repository} ){

                #if($tRepo.PublishLocation -match $rgxurl -AND -not($noWeb) -AND ($tRepo.SourceLocation -eq $PSGregexURI) ){
                # above was an attempt to leverage the PSRepository registered uri values for web queries, but they don't appear functional, at least not for PSGallery
                if(-not($noWeb) -AND ($tRepo.SourceLocation -eq $PSGregexURI) ){
                    $qryMethod='PSGWeb' ; # 6x faster than find-module
                } elseIf( ([System.Uri]$tRepo.PublishLocation).IsUnc -OR ($noWeb) ) {
                    # use find-mod for local UNC-based repos
                    $qryMethod = 'findMod' ; 
                } else {
                    # fall back to slower find-module queries (6x slower for web)
                    $qryMethod = 'findMod' ; 
                } ; 

            } else {
                write-error "$((get-date).ToString('HH:mm:ss')):$($Module.name) repo of record ($($Module.Repository.name)) did not resolve to a current PSRepository entry`nSKIPPING";
                break ; 
            }; 

            write-verbose "$((get-date).ToString('HH:mm:ss')):(using qryMethod:$($qryMethod))" ;
            switch ($qryMethod) {
                'PSGWeb' {
                    # access the main module page, and add a random number to trick proxies

                    <# try using the PSRepository $tRepo.PublishLocation: https://www.powershellgallery.com/api/v2/package/ 
                    #$url = "$($tRepo.PublishLocation)$($Module.name)/?dummy=$(Get-Random)" ; # - doesn't work it may be published, but you need to use the unpublished uri to query version.
                    if($tRepo.SourceLocation -eq $PSGregexURI ){
                        $url = "$($PSGBaseQryUrl)$($Module.name)/?dummy=$(Get-Random)" ; 
                    } else { 
                        throw "Non-PSGallery SourceLocation: specified repo isn't compatible with this scripot" ;
                        break ; 
                    } ; 
                    #>
                    $url = "$($PSGBaseQryUrl)$($Module.name)/?dummy=$(Get-Random)" ; 
                    write-verbose "using url:$($url)" ; 
                    $request = [System.Net.WebRequest]::Create($url) ; 
                    # do not allow to redirect. The result is a "MovedPermanently"
                    $request.AllowAutoRedirect=$false ; 
                    try {
                        # send the request
                        $response = $request.GetResponse() ; 
                        # get back the URL of the true destination page, and split off the version
                        [version]$PublVers = $response.GetResponseHeader("Location").Split("/")[-1] -as [Version] ; 
                        # make sure to clean up
                        $response.Close() ; 
                        $response.Dispose() ; 
                    } CATCH {
                        $ErrTrapd=$Error[0] ;
                        $smsg= "Failed to exec cmd because: $($ErrTrapd)" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
                        Continue ;#Continue/Exit/Stop
                    } ;  
                } 
                'findMod' {
                    # local UNC psrepo or undocumented registered repo, use Find-Module to query
                    # find-module -Repository -Name -AllVersions -MaximumVersion
                    try {
                        $pltFMod=[ordered]@{
                            Repository = $tRepo.Name ; 
                            Name = $Module.name ; 
                        } ; 
                        write-verbose "$((get-date).ToString('HH:mm:ss')):find-module w`n$(($pltFMod|out-string).trim())" ; 
                        [version]$PublVers = (find-module @pltFMod | sort version -desc)[0].version ; 
                    } CATCH {
                        $ErrTrapd=$Error[0] ;
                        $smsg= "Failed to exec cmd because: $($ErrTrapd)" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
                        Continue ;#Continue/Exit/Stop
                    } ;  
                } 
            } ; 
            
            $stat =  [ordered]@{
                ModuleName = $Module.name ; 
                CurrentVers = [version]$module.Version.tostring() ; 
                PublishedVers = $PublVers.tostring() ; 
                Status = if([version]$module.Version -lt [version]$PublVers){"UPGRADE AVAIL"}else{""} ; 
                Repository = $module.Repository.name ; 
                Path = $module.installedlocation ; 
            } ; 
            $Report += new-object psobject -Property $stat ; 
            start-sleep -Milliseconds $ThrottleMs ; 
        } ; # loop-E
    } ; 
    END{
        $Report| sort status,modulename | write-output ; 
    } ;
}

#*------^ Get-ModulePublishedVersion.ps1 ^------
