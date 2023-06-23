# verb-mods.psm1


  <#
  .SYNOPSIS
  verb-Mods - Generic module-related functions
  .NOTES
  Version     : 1.4.1.0
  Author      : Todd Kadrie
  Website     :	https://www.toddomation.com
  Twitter     :	@tostka
  CreatedDate : 4/7/2020
  FileName    : verb-Mods.psm1
  License     : MIT
  Copyright   : (c) 4/7/2020 Todd Kadrie
  Github      : https://github.com/tostka
  Tags        : Powershell,Module,Utility
  REVISIONS
  * 4/7/2020 - 1.0.0.0 modularized
  # 1:07 PM 4/7/2020 initial version: consolidating generic cross-module funcs into this common mod: Disconnect-PssBroken.ps1 ; check-ReqMods.ps1
  .DESCRIPTION
  verb-Mods - Generic module-related functions
  .LINK
  https://github.com/tostka/verb-Mods
  #>


    $script:ModuleRoot = $PSScriptRoot ;
    $script:ModuleVersion = (Import-PowerShellDataFile -Path (get-childitem $script:moduleroot\*.psd1).fullname).moduleversion ;
    $runningInVsCode = $env:TERM_PROGRAM -eq 'vscode' ;

#*======v FUNCTIONS v======




#*------v check-ReqMods.ps1 v------
function check-ReqMods {
    <#
    .SYNOPSIS
    check-ReqMods() - Verifies that specified commands exist in function: (are loaded) or get-command (registered via installed .psd modules)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-07
    FileName    : check-ReqMods.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Module,Utility
    REVISIONS
    * 8:01 AM 12/1/2020 added missing function banners
    * 1:11 PM 4/7/2020 orig vers undoc'd - sometime in last 2-3yrs, init with CBH
    .DESCRIPTION
    check-ReqMods() - Verifies that specified commands exist in function: (are loaded) or get-command (registered via installed .psd modules)
    .PARAMETER reqMods ;
    Specifies the String(s) on which the diacritics need to be removed ;
    .INPUTS
    String array
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    $reqMods+="get-GCFast;Get-ExchangeServerInSite;connect-Ex2010;Reconnect-Ex2010;Disconnect-Ex2010;Disconnect-PssBroken".split(";") ;
    if( !(check-ReqMods $reqMods) ) {write-error "$((get-date).ToString("yyyyMMdd HH:mm:ss")):Missing function. EXITING." ; exit ;}  ;
    reconnect-ex2010 ;
    Confirm presence of command dependancies, prior to attempting an Exchange connection
    .LINK
    https://github.com/tostka
    #>
    [CMdletBinding()]
    PARAM (
    [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="PS Commands to be checked for availability[-reqMods 'get-noun','set-noun']")]
    [ValidateNotNullOrEmpty()]$reqMods) ;
    $bValidMods=$true ;
    $reqMods | foreach-object {
        if( !(test-path function:$_ ) ) {
            if(!(get-command -Name $_)){
                write-error "$((get-date).ToString("yyyyMMdd HH:mm:ss")):Missing $($_) function." ;
                $bValidMods=$false ;
            } ; 
        } ; 
    } ;
    write-output $bValidMods ;
}

#*------^ check-ReqMods.ps1 ^------


#*------v Disconnect-PssBroken.ps1 v------
Function Disconnect-PssBroken {
    <#
    .SYNOPSIS
    Disconnect-PssBroken - Remove all local broken PSSessions
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-03-03
    FileName    : Disconnect-PssBroken.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,ExchangeOnline,Exchange,RemotePowershell,Connection,MFA
    REVISIONS   :
    * 1:22 PM 4/7/2020 consolidated into verb-Mods (were 5 dupes across remote-powershell mods)
    * 12:56 PM 11/7/2018 fix typo $s.state.value, switched tests to the strings, over values (not sure worked at all)
    * 1:50 PM 12/8/2016 initial version
    .DESCRIPTION
    Disconnect-PssBroken - Remove all local broken PSSessions
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    Disconnect-PssBroken ;
    .LINK
    #>
    Get-PsSession |Where-Object{$_.State -ne 'Opened' -or $_.Availability -ne 'Available'} | Remove-PSSession -Verbose ;
}

#*------^ Disconnect-PssBroken.ps1 ^------


#*------v find-profileScripts.ps1 v------
function find-profileScripts {
    <#
    .SYNOPSIS
    find-profileScripts - Reports on configured local Powershell profiles:Scope, WPS|PSCore,host,path)
    .NOTES
    Version     : 1.0.0
    Author      : (un-attributed Idera post)
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20201001-0900PM
    FileName    : find-profileScripts.ps1 
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-Mods
    Tags        : Powershell,Profile
    AddedCredit : (un-attributed Idera post)
    AddedWebsite: https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/checking-profile-scripts-part-2
    AddedTwitter: URL
    REVISIONS
    * 10:16 AM 12/1/2020 cleanedup missing func decl line
    .DESCRIPTION
    find-profileScripts.ps1 - Reports on local Powershell profiles
    .OUTPUTS
    System.Object[]
    .EXAMPLE
    $profs = find-profileScripts
    .LINK
    https://github.com/tostka/verb-XXX
    .LINK
    https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/checking-profile-scripts-part-2
    #>
    # calculate the parent paths that can contain profile scripts
    $Paths = @{
        AllUser_WPS = $pshome ;
        CurrentUser_WPS = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath "WindowsPowerShell" ;
        AllUser_PS = "$env:programfiles\PowerShell\*" ;
        CurrentUser_PS = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath "PowerShell" ;
    } ;
    $OutObj = @() ; 
    # process and summarize each path
    $Paths.Keys | ForEach-Object {
        $key = $_ ;
        $path = Join-Path -Path $paths[$key] -ChildPath '*profile.ps1' ;
        Get-ChildItem -Path $Path | ForEach-Object {
            if ($_.Name -like '*_*'){$hostname = $_.Name.Substring(0, $_.Name.Length-12) } 
            else {$hostname = 'any'} ;
            $OutObj += [PSCustomObject]@{
                Scope = $key.Split('_')[0] ;
                PowerShell = $key.Split('_')[1] ;
                Host = $hostname ;
                Path = $_.FullName ;
            } ;
        } ;
    } ; 
    $outObj | write-output ; 
}

#*------^ find-profileScripts.ps1 ^------


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


#*------v get-ModuleRecentPublishedRevisions.ps1 v------
function get-ModuleRecentPublishedRevisions {
    <#
    .SYNOPSIS
    get-ModuleRecentPublishedRevisions.ps1 - Get the most recent -Limit (5) PSRepostory-published .Nupkg revisions of the specified module.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2022-12-08
    FileName    : get-ModuleRecentPublishedRevisions.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-mod
    Tags        : Powershell,Module,Maintenance
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 10:33 AM 12/8/2022 init, flipped to verb-dev func
    .DESCRIPTION
    get-ModuleRecentPublishedRevisions.ps1 - get-ModuleRecentPublishedRevisions.ps1 - Get the most recent -Limit (5) PSRepostory-published .Nupkg revisions of the specified module.
    This relies on a populated profile/global $localPsRepo value, which should contain the name of the local repository.
    
    N.B. Should be able to rely on find-module to produce this info, but I find that gci'ing the PSRepository.Source path more consistently & quickly returns results (with a simple file share Repository). 
    
    .PARAMETER Name
    [string] Module Name[-Name modulename]
    .PARAMETER Repository
    [string]Repository to be installed from (defaults to value stored as `$global:localPsRepo)[-Repository SomeRepo]
    .PARAMETER Limit
    Number of recent revisions to return (defaults to 5)[-Limit 10]
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    PSObject of fullname & lastwritetime for the matched Repository nupkg objects
    .EXAMPLE
    PS> $whatif = $true ; 
    PS> $modname = 'verb-io' ; 
    PS> write-verbose "Get most recent published .nupkg file information for named module on local Repository & capture the output to a variable" ; 
    PS> $revs = get-ModuleRecentPublishedRevisions -name $modname ;
    PS> write-verbose "Output the most recent two revisionss information to console" ; 
    PS> $revs[-2..-1] | ft -a ; 
    PS> write-verbose "Regex the version # of the second-most-recent release" ; 
    PS> $ReqVers = [regex]::match($revs[-2].fullname,'(\d+\.\d+\.\d+)').captures[0].groups[1].value ;
    PS> write-verbose "Uninstall *allVersions* of the module locally" ; 
    PS> uninstall-module -name $modname -AllVersions -force -whatif:$($whatif) ; 
    PS> write-verbose "Install the 2nd-most-recent release to CurrentUser scope, with force/AllowClobber." ; 
    PS> install-module -name $modname -RequiredVersion $reqvers -Repository $localpsrepo -force -allowclobber -scope CurrentUser -whatif:$($whatif) ;
    PS> write-verbose "Delete the most recent published revision .nupkg file from the PSRepository.Source directory" ; 
    PS> gci -path $revs[-1].fullname | remove-item -whatif:$($whatif) ;
    
        (retrieving most recent 5 revisions in Repo for verb-io...)
        11:13:10:5 most recent lyncRepo-published revisions of verb-io:
        FullName                         LastWriteTime
        --------                         -------------
        \\REPO\SHARE\verb-IO.2.0.3.nupkg 5/23/2022 2:14:08 PM
        \\REPO\SHARE\verb-IO.3.0.0.nupkg 6/2/2022 11:02:33 AM
        \\REPO\SHARE\verb-IO.3.0.1.nupkg 7/21/2022 1:39:50 PM
        \\REPO\SHARE\verb-IO.3.1.0.nupkg 8/30/2022 5:00:05 PM
        \\REPO\SHARE\verb-IO.4.0.0.nupkg 9/8/2022 4:08:31 PM

        (returning object to pipeline)

        FullName                                          LastWriteTime
        --------                                          -------------
        \\REPO\SHARE\verb-IO.3.1.0.nupkg 8/30/2022 5:00:05 PM
        \\REPO\SHARE\verb-IO.4.0.0.nupkg 9/8/2022 4:08:31 PM

        What if: Performing the operation "Uninstall-Module" on target "Version '4.0.0' of module 'verb-IO'".
        What if: Performing the operation "Install-Module" on target "Version '3.1.0' of module 'verb-IO'".
        What if: Performing the operation "Remove File" on target "\\REPO\SHARE\verb-IO.4.0.0.nupkg".     
    
    Above demos remediating around a recent damaged revision, clearing all local versions, installing the prior revision from the PSRepo, and clearing the last revision .nupkg file from the PSRepo.
    .LINK
    https://github.com/tostka/verb-mods
    .LINK
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    ## [OutputType('bool')] # optional specified output type
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Module Name[-Name modulename]")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(HelpMessage="[string]Repository to be installed from (defaults to `$global:localPsRepo/profile value) Name[-Repository SomeRepo]")]
        [string]$Repository=$localPsRepo,
        [Parameter(HelpMessage="Number of recent revisions to return (defaults to 5)[-Limit 10]")]
        [int]$Limit = 5
    ) ;
    $verbose = ($VerbosePreference -eq "Continue") ;
    TRY {
        $error.clear() ;
        $pltGrpo=[ordered]@{name = $localpsrepo ; ErrorAction='STOP'} ;
        $pltGCI=[ordered]@{path="$((get-psrepository @pltGrpo).SourceLocation)\$($Name)*.nupkg" ; ErrorAction='STOP'} ;
        write-host "(retrieving most recent $($Limit) revisions in Repo for $($Name)...)" ;
        write-verbose "get-psrepository w`n$(($pltGrpo|out-string).trim())" ;
        write-verbose "gci w`n$(($pltGCI|out-string).trim())" ;
        $Allvers = gci @pltGCI | sort lastwriteTime ;
        $smsg = "$($Limit) most recent $($Repository)-published revisions of $($Name):`n$(($Allvers | select -last $Limit | ft -a fullname,lastwritetime|out-string).trim())" ; 
        $smsg += "`n`n(returning object to pipeline)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
        $Allvers | select -last $Limit | select fullname,lastwritetime | write-output ; 
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
        write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        Break ;
    } ;
}

#*------^ get-ModuleRecentPublishedRevisions.ps1 ^------


#*------v get-RepoModulesHighestVersion.ps1 v------
function get-RepoModulesHighestVersion {
    <#
    .SYNOPSIS
    get-RepoModulesHighestVersion.ps1 - Check specified Repository (defaults to $global:localPsRepo) for highest .nupkg verison for each of module directories specified by -Paths.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-11-03
    FileName    : get-RepoModulesHighestVersion.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-mods
    Tags        : Powershell,Module,Maintenance,Repository
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 9:40 AM 4/22/2022 fix: typo in echo
    * 4:21 PM 4/21/2022 add: test-isUNCPath () ; PSv2-compatible PSGet:install-module supporting approach:  as PsV2 lacks PowershellGet support, this specifies the PSRepository.SourceLocation property as the -Repository input.  The script then skips the normal get-PSRepository resolution, and uses the specified UNC path, and the -Names (array of module names), to target variant revisions on the Repository.
    * 2:02 PM 11/3/2021 init, flipped to verb-mods func
    .DESCRIPTION
    get-RepoModulesHighestVersion.ps1 - Check specified Repository (defaults to $global:localPsRepo) for highest .nupkg verison for each of module directories specified by -Paths.
    Calculates and sorts on _actual_ semantic version (rather than strict n.n.n text), to determine highest/latest revision.
    .PARAMETER Paths
    Module source paths to be processed[-paths 'c:\path-to\','c:\path2-to']
    .PARAMETER OutObject
    Switch to return a summarizing object to the pipeline (defaults true)[-OutObject `$false]
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)
    .EXAMPLE
    PS> $Paths += (resolve-path c:\sc\verb*) ;
    PS> get-RepoModulesHighestVersion -Paths $Paths -verbose ;
    Run a pass against all paths below the c:\sc\ directory, with directory names starting with verb*, with verbose output.
    .EXAMPLE
    PS> $latestRevs = (resolve-path c:\sc\verb*) | get-RepoModulesHighestVersion ;
    PS> $latestRevs |ft -a name,lastwritetime,version ;
    Pipeline example, process list of dirs matching pattern c:\sc\verb*, for highest .nupkg revision in the default local repository, and assign summary object to $latestRevs, then output a summary of the returned object.
    .EXAMPLE
    PS> $latestRevs = get-RepoModulesHighestVersion -Names verb-IO -Repository "\\lynmsv10\lync_fs\scripts\sc" -verbose ;
    PS> $latestRevs |ft -a name,lastwritetime,version ;
    PS> install-Module -ModulePath $latestRevs.fullname -Global
    PSv2-compatible PSGet:install-module supporting approach:
    - as PsV2 lacks PowershellGet support, this specifies the PSRepository.SourceLocation property as the -Repository input.
    - The script then skips the normal get-PSRepository resolution, and uses the specified UNC path, and the -Names (array of module names), to target variant revisions on the Repository.
    - The resulting highest semantic-version is returned and assigned to the $latestRevs variable, which is summarized in an echo back to console.
    - Finally the $latestRev version fullname is used with the PsGet install-module command, under the -ModulePath, to install the latest version locally on a Psv2 machine.
    .EXAMPLE
    PS> $latestRevs = get-RepoModulesHighestVersion -Names verb-IO,verb-logging,verb-text,verb-Network -Repository ((get-psrepository -Name $global:localPSRepo).sourcelocation) -verbose ;
    PS> $latestRevs |ft -a name,lastwritetime,version ;
    PS> $latestRevs.fullname ;
    PS> $latestRevs.fullname | %{write-host "==$($_):" ; install-Module -ModulePath $_ -Global -verbose ; } ;
    PSv2-compatible PSGet:install-module supporting approach:
    Psv2-compatible, PsGet:install-module() another simple variant that uses get-PsRepository to populate the inbound UNC path (as this verb-modules module would traditionally be run from a Psv3+ machine, with full PowershellGet support, no reason to have to hand-specify the local PsRepo SourceLocation).
    Note: PsGet:import-module() isn't written with -ModulePath array support ([string[]]) , so we externally loop it through.
    .LINK
    https://github.com/tostka/verb-Mods
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    [CmdletBinding(DefaultParameterSetName='Paths')]
    PARAM(
        [Parameter(ParameterSetName='Paths',Position=0,Mandatory=$false,ValueFromPipeline=$true,HelpMessage="Module source paths to be processed[-paths 'c:\path-to\','c:\path2-to']")]
        [ValidateScript({Test-Path $_})]
        [string[]]$Paths,
        [Parameter(ParameterSetName='Names',Position=0,Mandatory=$false,ValueFromPipeline=$true,HelpMessage="Array of Module names to be searched on the specified Repository[-paths 'c:\path-to\','c:\path2-to']")]
        [string[]]$Names,
        [Parameter(HelpMessage="Repository (defaults to `$global:localPsRepo). Can also be set to the UNC path to a Repository.SourceLocation path (for use with PsGet, which lacks PSRepository support)[-Repository 'somerepo']")]
        [string]$Repository=$localPsRepo,
        [Parameter(HelpMessage="Switch to return a summarizing object to the pipeline (defaults true)[-OutObject `$false]")]
        [switch] $OutObject=$true
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ;
        $rgxNuPkgFileNames = '.*\.(\d+\.\d+\.\d+)\.nupkg$' ;
        $repoDirs=$allPkgs=@() ;
        if($Paths -AND $Names){
            throw "-Paths and -Names both specified. Please use one or the other!" ;
            break ;
        } ;
        #*======v FUNCTIONS v======
        if(-not (gcm test-isUNCPath -ea 0)){
            #*------v Function test-IsUncPath v------
            function test-IsUncPath {
                [OutputType('bool')]
                [CmdletBinding()]
                PARAM(
                    [Parameter(Mandatory,Position=0,ValueFromPipeline=$true)]
                    [ValidateNotNullOrEmpty()]
                    [string]$Path
                ) ;
                PROCESS {
                    $Error.Clear() ;
                    foreach($item in $path) {
                        $PathInfo=[System.Uri]$item ;
                        if($PathInfo.IsUnc){
                            $true | write-output ;
                        } else {
                            $false | write-output ;
                        } ;
                    } ;
                } ;
            } ;
            #*------^ END Function test-IsUncPath ^------
        } ;
        #*======^ END FUNCTIONS ^======

        # make it flip a UNC path in the $Repository value, into assumption it's the $SourceLocation of the repository (doesn't use get-psrepository to resolve path, just uses it as passed in).
        if( (test-IsUncPath -path $Repository) -AND (test-path $Repository) ){
            $smsg = '-Repository detected to contain a UNC path spec:' ;
            $smsg += "`nflipping specified Repository into the `$RepoSrc specification" ;
            write-verbose $smsg ;
            $RepoSrc = $Repository ;
        } else {
            if( -not (get-module -name PowershellGet)){
                $smsg = "Missing Required module PowershellGet!" ;
                if($host.version.major -lt 3){
                    $smsg += "`nPSv2 lacks PowershellGet support" ;
                    $smsg += "`nspecify the PSRepository.SourceLocation value, for the -Repository parameter"
                    $smsg += "`nto work around the gap."
                    $smsg += "`nThen use PSGet's install-module -ModulePath [uncpathto.nupkg] -Global"
                    $smsg += "`nto install the found highest rev, to the 'Global'/System profile - as Psv2 lacks an AllUsers profile"
                } ;
            } else {
                $RepoSrc = (Get-PSRepository -name $Repository).SourceLocation ;
            } ;
        } ;
        $allPkgs=@() ;
    } ;
    PROCESS{
        $procd=0 ;
        $srchtargets = @() ;
        if($Names){
            $ttl = ($Names | measure).count ;
            foreach ($name in $Names){
                $procd++ ;
                #$srchtargets += "$($reposrc)\$($Name)*.nupkg"
                $srchtargets += join-path -path $reposrc -childpath "$($Name)*.nupkg"
            } ;
        } elseif ($Paths){
            $ttl = ($Paths|measure).count ;
            $procd++ ;
            foreach ($path in $Paths){
                #$srchtargets += "$($reposrc)\$(split-path $path -leaf)*.nupkg"
                $srchtargets += join-path -path $reposrc -childpath "$(split-path $path -leaf)*.nupkg"
            } ;
        } ;
        foreach ($path in $srchtargets){
            $procd++ ;
            TRY {
                $error.clear() ;
                write-host "(processing:$($path)...)" ;
                #$pltGci=[ordered]@{path ="$($reposrc)\$(split-path $path -leaf)*.nupkg" ; ea = 'STOP'} ;
                $pltGci=[ordered]@{path = $path ; ea = 'STOP'} ;
                write-verbose "`nget-childitem w`n$(($pltGci|out-string).trim())" ;
                $pkgs = gci @pltGci ;
                $pkgs = $pkgs | select *,@{name="version";expression={[version]([regex]::match($_.name,'.*\.(\d+\.\d+\.\d+)\.nupkg$').captures[0].groups[1].value)}} | sort version ;
                if($pkgs){
                    if($pkgs -is [system.array]){$allPkgs += $pkgs[-1]}
                    else {$allPkgs += $pkgs} ;
                    write-verbose "`n$(($allPkgs[-1]|ft -a name,lastwritetime,version|out-string).trim())" ;

                } ;
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Break  #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
            } ;
        } ;
    }  # PROC-E
    END {
        if(-not($outObject)){
            $smsg = "`n$(($allpkgs|ft -a name,lastwritetime,version|out-string).trim())" ;
            write-host $smsg ;
        } else {
          $allpkgs | write-output ;
        } ;
    } ;
}

#*------^ get-RepoModulesHighestVersion.ps1 ^------


#*------v Install-ModulesTin.ps1 v------
function Install-ModulesTin {
    <#
    .SYNOPSIS
    Install-ModulesTin - Loops a list of PowershellGallery modules, checks for gmo -list, and get-installedmodule, and if neither, finds & installs current rev from PsG.
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2018-03-24
    FileName    : Install-ModulesTin.ps1
    License     : MIT
    Copyright   : (c) 4/7/2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Module,Lifecycle
    AddedCredit : 
    AddedWebsite: 
    AddedTwitter: 
    REVISIONS
    * 1:24 PM 10/6/2021 code local-repo pref for find-module returning multi matches (generally PSGallery & a local repo, with a fork etc on local - assumes the local is tuned/updated for our specific needs)
    * 2:22 PM 10/5/2021 ported from install-WorkstationModules.ps1 to verb-mods (6/2/21 vers)
    .DESCRIPTION
    Install-ModulesTin - Loops a list of PowershellGallery modules, checks for gmo -list, and get-installedmodule, and if neither, finds & installs current rev from PsG.
    .PARAMETER Modules
    Array of PSGallery Modules to Install[-modules 'mod1','mod2']
    .PARAMETER Scope
    Scope to be targeted (AllUsers|CurrentUser, default: no filtering)[-Scope AllUsers]
    .PARAMETER whatIf
    Whatif Flag  [-whatIf]
    .EXAMPLE
    $psdeskmods ="Pester","PSScriptAnalyzer" ; 
    $bRet = Install-ModulesTin -Modules $psdeskmods -scope CurrentUser -showdebug:$($showdebug) -whatif:$($whatif) ; 
    .LINK
    https://github.com/tostka
    #>
    #Requires -Modules verb-Auth
    [CmdletBinding()] 
    Param(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Array of PSGallery Modules to Install")]
        [ValidateNotNullOrEmpty()][array]$Modules,
        [Parameter(Position=1,HelpMessage="Module installation scope (CurrentUser|AllUsers - defaults CU)[-Scope AllUsers]")]
        [ValidateSet("AllUsers","CurrentUser")]
        $Scope,
        [Parameter(HelpMessage="Custom local Repository (non-PSGallery)[-Repository myLocalRepo]")]
        $Repository, 
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    $verbose = ($VerbosePreference -eq "Continue") ; 
    if(!$Scope){$Scope = "CurrentUser"} ; 

    $propsFindMod = 'Version','Name','Repository','Description' ;
    $propsFindModV = 'name','type','version','description','repository' ; 
    
    $ttl=($Modules|measure).count ; 
    $Procd=0 ; 
    $smsg= "Installing $(($Modules|measure).count) PS Modules:" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

    foreach ($Mod in $Modules){
        $Procd++ ; 
        $sBnrS="`n#*------v ($($Procd)/$($ttl)):`$Mod:$($Mod) v------" ; 
        $smsg= "$($sBnrS)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

        # refresh splat every pass - don't want prior pass resolved repo to recycle
        $pltInstMod=[ordered]@{
            Name=$null ; 
            Scope=$scope ;
            ErrorAction="Stop" ; 
            whatif=$($whatif) ;  
        } ; 
        if($Repository -AND $Repository -ne 'PSGallery'){
            $smsg = "(adding custom `pltInstMod:'Repository',$($Repository))" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            $pltInstMod.add('Repository',$Repository) ; 
        } ; 
        $smsg = "($($Mod):gmo -list & get-installedmodule...)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        if(!($emod=get-module -name $Mod -listavailable -ea 0) -and !($emod=get-installedmodule -name $Mod  -ea 0)){
            $smsg = "==FIND-MODULE:$($Mod):" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            $error.clear() ;
            $smsg = "(find-module -name $($Mod))" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            if($rmod=find-module -name $Mod -ea 0  ){
                # stats is at psg & localrepo, prioritze multi-hits
                # course, my version is improved: I converted broken .md help to CBH, added example to use get-histogram etc, so defer to mine.
                if(($rmod|measure).count -gt 1){
                    $smsg= "Multiple matches returned!:`n$(($rmod|fl $propsFindModV |out-string).trim())" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    if($lmod = $rmod|?{$_.repository -eq $localpsRepo}){
                        $smsg = "LocalRepo mod found, deferring to local:$($localPsRepo) copy" ; 
                        $smsg += "`n$(($lmod| ft -a $propsFindMod |out-string).trim())" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        $pltInstMod.add('Repository',$localpsRepo) ; 
                        $rmod = $lmod ; 
                    } else { 
                        $smsg = "Multiple available published modules, unable to determine which to install." ;
                        $smsg += "`nPlease rerun with -Repository set to the proper registered repo name." ; 
                        #$smsg += "`nFound modules:`n$(($rmod| ft -a $propsFindMod |out-string).trim())" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        Break ; 
                    } ; 
                } ; 
                $smsg= "INSTALLING MATCH:`n$(($rmod| fl $propsFindModV |out-string).trim())" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                $pltInstMod.name = $rmod.name ; 
                $smsg= "install-module w`n$(($pltInstMod|out-string).trim())" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                TRY { 
                    install-module @pltInstMod ; 
                $error.clear() ;
                } CATCH {
                    $ErrTrapd=$Error[0] ;
                    $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #-=-record a STATUSWARN=-=-=-=-=-=-=
                    $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
                    if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
                    if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
                    #-=-=-=-=-=-=-=-=
                    $smsg = "FULL ERROR TRAPPED (EXPLICIT CATCH BLOCK WOULD LOOK LIKE): } catch[$($ErrTrapd.Exception.GetType().FullName)]{" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level ERROR } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
                } ; 
            } else {
                $smsg= "$($Mod):;NOT-FOUND W FIND-MODULE!" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ; 

        } else { 
            $smsg= "$($Mod):LOCALLY INSTALLED`n$(($emod| FORMAT-TABLE -AUTO moduletype,version,path | out-string).trim())" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ; 
        $smsg= "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } 
}

#*------^ Install-ModulesTin.ps1 ^------


#*------v load-Module.ps1 v------
function load-Module {
    <#
    .SYNOPSIS
    load-Module - Import-Module, with Find- & Install-, when not available to load.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2019-8-28
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 10:17 AM 10/1/2020 added import-module verbose tmp supporess
    * 7:29 AM 1/29/2020 added pshelp, version etc (copying into verb-dev)
    * 8/28/2019 init
    .DESCRIPTION
    load-Module - Import-Module, with Find- & Install-, when not available to load.
    .PARAMETER  Module
    Module name to be loaded or installed [ -Module Azure]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    .\load-Module Azure
    .LINK
    https://github.com/tostka
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Module name to be loaded or installed [ -Module Azure]")]
        [ValidateNotNullOrEmpty()][string]$Module,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    $Verbose = ($VerbosePreference -eq "Continue") ; 
    if!(Get-Module -Name $Module){
        if (Get-Module -Name $Module -ListAvailable) {
            if($VerbosePreference = "Continue"){ $VerbosePrefPrior = $VerbosePreference ; $VerbosePreference = "SilentlyContinue" ; $verbose = ($VerbosePreference -eq "Continue") ; } ; 
            Import-Module $Module ;
            # reenable VerbosePreference:Continue, if set, during mod loads 
            if($VerbosePrefPrior -eq "Continue"){ $VerbosePreference = $VerbosePrefPrior ; $verbose = ($VerbosePreference -eq "Continue") ; } ; 
        } else {
            write-host -foregroundcolor RED "$((get-date).ToString('HH:mm:ss')):ERROR!:The $($Module) module is *NOT* INSTALLED!.`n Checking for available copy..." ;
            if(find-module $Module){
                write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):Would you *LIKE* to install the $Module module *NOW*?" ;
                $bRet = Read-Host "Enter YYY to continue. Anything else will exit"
                if ($bRet.ToUpper() -eq "YYY") {
                    Write-host "Installing Module:$($Module)`nInstall-Module -Name $($Module) -AllowClobber -Scope CurrentUser..."
                    Install-Module -Name $Module -AllowClobber -Scope CurrentUser
                } else {
                    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):Install declined. Aborting script pass.`nThe required $($Module) module can be installed via the`nInstall-Module -Name $($Module) -AllowClobber -Scope CurrentUser`ncommand.`nEXITING"
                    # exit <asserted exit error #>
                    exit 1
                } # if-block end
            } else {
                write-host -foregroundcolor RED "$((get-date).ToString('HH:mm:ss')):ERROR!:The $($Module) module was not found at the routine Repositories. `nPlease locate a copy and install it before attempting to use this script" ;
            } ;
        } ;
    } ;
}

#*------^ load-Module.ps1 ^------


#*------v load-ModuleFT.ps1 v------
function load-ModuleFT {
    <#
    .SYNOPSIS
    load-ModuleFT - Import-Module, with fault-tolerant coverage, when not available to load as normal module.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-29
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    REVISIONS
    * 9:26 AM 12/14/2022 rplc test-path [obj]:[name] with gcm:  where we've renamed functions, and aliased priors, this needs to gcm broadly, not confirm on function names, or it false-positive breaks
    * 10:18 AM 10/1/2020 added import-module tmp verbose suppress
    * 12:34 PM 8/4/2020 fixed typo #68, missing $ on vari name
    * 2:57 PM 4/29/2020 port from code in use in .ps1's & modules
    .DESCRIPTION
    load-ModuleFT - Import-Module, with fault-tolerant coverage, when not available to load as normal module.
    .PARAMETER  tModName
    Module name to be loaded or installed [ -tModName Azure]
    .PARAMETER ParentPath
    Calling script path (used for log construction)[-ParentPath c:\pathto\script.ps1]
    .PARAMETER LoggingOn
    Initiate logging Flag [-LoggingOn]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .OUTPUT
    Returns an object with properties:
    [boolean]ModStatus ($tModmdlet validated avail) ; 
    [boolean]Logging ; 
    [string]$logfile ; 
    [string]$transcript
    .EXAMPLE
    load-ModuleFT -tModName verb-Azure -tModFile C:\sc\verb-Azure\verb-Azure\verb-Azure.psm1 -tModCmdlet get-AADBearToken ; 
    .EXAMPLE
    $tMod="verb-Azure;C:\sc\verb-Azure\verb-Azure\verb-Azure.psm1;get-AADBearToken" ;
    load-ModuleFT -tModName $tMod.split(';')[0] -tModFile $tMod.split(';')[1] -tModCmdlet $tMod.split(';')[2] ; 
    .LINK
    https://github.com/tostka
    #>
    #  $tModName = $tMod.split(';')[0] ; $tModFile = $tMod.split(';')[1] ; $tModCmdlet = $tMod.split(';')[2] ; 
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True,HelpMessage = "Name of Module name to be loaded [ -tModName Azure]")]
        [ValidateNotNullOrEmpty()][string]$tModName,
        [Parameter(Mandatory = $True,HelpMessage = "Path to xxx.psm1 source file for module to be loaded [ -tModName C:\sc\verb-Azure\verb-Azure\verb-Azure.psm1]")]
        [ValidateNotNullOrEmpty()][string]$tModFile,
        [Parameter(Mandatory = $True,HelpMessage = "Cmdlet to be validated present for module to be loaded [-tModCmdlet get-AADBearToken]")]
        [ValidateNotNullOrEmpty()][string]$tModCmdlet,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    BEGIN{
        # Get the name of this function
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        # Get parameters this function was invoked with
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        $Verbose = ($VerbosePreference -eq "Continue") ; 
    } ; 
    PROCESS{
        $smsg = "( processing `$tModName:$($tModName)`t`$tModFile:$($tModFile)`t`$tModCmdlet:$($tModCmdlet) )" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        if($tModName -eq 'verb-logging' -OR $tModName -eq 'verb-Azure'){
            write-host "GOTCHA!" ;
        } ;
        $lVers = get-module -name $tModName -ListAvailable -ea 0 ;
        if($lVers){
            $lVers=($lVers | sort version)[-1];
            try {
                # suppress VerbosePreference:Continue, if set, during mod loads (VERY NOISEY)
                if($VerbosePreference = "Continue"){ $VerbosePrefPrior = $VerbosePreference ; $VerbosePreference = "SilentlyContinue" ; $verbose = ($VerbosePreference -eq "Continue") ; } ; 
                import-module -name $tModName -RequiredVersion $lVers.Version.tostring() -force -DisableNameChecking 
                # reenable VerbosePreference:Continue, if set, during mod loads 
                if($VerbosePrefPrior -eq "Continue"){ $VerbosePreference = $VerbosePrefPrior ; $verbose = ($VerbosePreference -eq "Continue") ; } ; 
            } catch {
                write-warning "*BROKEN INSTALLED MODULE*:$($tModName)`nBACK-LOADING DCOPY@ $($tModDFile)" ;
                # suppress VerbosePreference:Continue, if set, during mod loads (VERY NOISEY)
                if($VerbosePreference = "Continue"){ $VerbosePrefPrior = $VerbosePreference ; $VerbosePreference = "SilentlyContinue" ; $verbose = ($VerbosePreference -eq "Continue") ; } ; 
                import-module -name $tModDFile -force -DisableNameChecking   
                # reenable VerbosePreference:Continue, if set, during mod loads 
                if($VerbosePrefPrior -eq "Continue"){ $VerbosePreference = $VerbosePrefPrior ; $verbose = ($VerbosePreference -eq "Continue") ; } ; 
            } ;
        } elseif (test-path $tModFile) {
            write-warning "*NO* INSTALLED MODULE*:$($tModName)`nBACK-LOADING DCOPY@ $($tModDFile)" ;
            try {
                # suppress VerbosePreference:Continue, if set, during mod loads (VERY NOISEY)
                if($VerbosePreference = "Continue"){ $VerbosePrefPrior = $VerbosePreference ; $VerbosePreference = "SilentlyContinue" ; $verbose = ($VerbosePreference -eq "Continue") ; } ; 
                import-module -name $tModDFile -force -DisableNameChecking
                # reenable VerbosePreference:Continue, if set, during mod loads 
                if($VerbosePrefPrior -eq "Continue"){ $VerbosePreference = $VerbosePrefPrior ; $verbose = ($VerbosePreference -eq "Continue") ; } ; 
            } catch {
                write-error "*FAILED* TO LOAD MODULE*:$($tModName) VIA $($tModFile) !" ;
                $tModFile = "$($tModName).ps1" ;
                $sLoad = (join-path -path $LocalInclDir -childpath $tModFile) ;
                if (Test-Path $sLoad) {       Write-Verbose -verbose ((Get-Date).ToString("HH:mm:ss") + "LOADING:" + $sLoad) ;
                   . $sLoad ;
                   if ($showdebug) { Write-Verbose -verbose "Post $sLoad" };
                } else {
                    $sLoad = (join-path -path $backInclDir -childpath $tModFile) ;
                    if (Test-Path $sLoad) {
                    
                        Write-Verbose -verbose ((Get-Date).ToString("HH:mm:ss") + "LOADING:" + $sLoad) ;
                        . $sLoad ;
                        if ($showdebug) { Write-Verbose -verbose "Post $sLoad" } }
                        else {
                            Write-Warning ((Get-Date).ToString("HH:mm:ss") + ":MISSING:" + $sLoad + " EXITING...") ;           exit;       
                        } ;
                } ; 
            } ; 
        } ;
        #if(!(test-path function:$tModCmdlet)){
        # where we've renamed functions, and aliased priors, this needs to gcm broadly, not confirm on function names, or it false-positive breaks
        if(!(get-command -name $tModCmdlet -ea 0 )){
            write-warning -verbose:$true  "UNABLE TO VALIDATE PRESENCE OF $tModCmdlet`nfailing through to `$backInclDir .ps1 version" ;
            $sLoad = (join-path -path $backInclDir -childpath "$($tModName).ps1") ;
            if (Test-Path $sLoad) {
                Write-Verbose -verbose:$true ((Get-Date).ToString("HH:mm:ss") + "LOADING:" + $sLoad) ;
                . $sLoad ;
                if ($showdebug) { Write-Verbose -verbose "Post $sLoad" };
                #if(!(test-path function:$tModCmdlet)){
                # where we've renamed functions, and aliased priors, this needs to gcm broadly, not confirm on function names, or it false-positive breaks
                if(!(get-command -name $tModCmdlet -ea 0 )){
                    write-warning "$((get-date).ToString('HH:mm:ss')):FAILED TO CONFIRM `$tModCmdlet:$($tModCmdlet) FOR $($tModName)" ;
                } else {write-verbose -verbose:$true  "(confirmed $tModName loaded: $tModCmdlet present)"} ;   
            } else {
                Write-Warning ((Get-Date).ToString("HH:mm:ss") + ":MISSING:" + $sLoad + " EXITING...") ;
                $ModStatus = $false ; 
                exit;
            } ; 
        } else {     
            write-verbose -verbose:$true  "(confirmed $tModName loaded: $tModCmdlet present)" ; 
            $ModStatus = $true ; 
        } ; 
    } ;  # PROC-E
    END {
        $ModStatus | write-output ;
    } ; 
}

#*------^ load-ModuleFT.ps1 ^------


#*------v mount-module.ps1 v------
function mount-Module {
    <#
    .SYNOPSIS
    mount-Module.ps1 - Attempts to import a module, if not found, checks for supporting Repo globals, and registers local repo, locates the module, installs and imports. Installing from repo is only backup - no dev-box style Backloading of source .psm1 or .ps1
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-09-24
    FileName    : mount-Module.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    REVISIONS
    * 10:18 AM 10/1/2020 added import-module tmp verbose suppress
    * 3:42 PM 9/28/2020 fixed that trailing-$ typo again
    * 7:42 AM 9/25/2020 duped from admin-prof.ps1 -> verb-mods
    * 4:31 PM 9/24/2020 init
    .DESCRIPTION
    mount-Module.ps1 - Attempts to import a module, if not found, checks for supporting Repo globals, and registers local repo, locates the module, installs and imports. Installing from repo is only backup - no dev-box style Backloading of source .psm1 or .ps1
    .PARAMETER  Name
    Module Name[-Name verb-module]
    .PARAMETER  BackupPath
    Backup Module Path (load attempt on fail)[-BackupPath c:\pathto\verb-module.psm1]
    .PARAMETER  CommandVerify
    Module command that should be loaded if module is ready for use[-PARAM verb-cmdlet]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output
    System.Boolean
    [| get-member the output to see what .NET obj TypeName is returned, to use here]
    .EXAMPLE
    mount-Module -tModName verb-Auth -tModFile C:\sc\verb-Auth\verb-Auth\verb-Auth.psm1 -tModCmdlet get-password -verbose
    Import verb-Auth module. If not found installed: 1) register localPSRepo, 2)find module in repo, 3)install missing module, and then 4)import the module, as needed.
    .LINK
    https://github.com/tostka/verb-XXX

    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Module Name[-Name verb-module]")]
        [string] $Name,
        [Parameter(Position=1,Mandatory=$false,HelpMessage="Backup Module Path (load attempt on fail)[-BackupPath c:\pathto\verb-module.psm1]")]
        [string] $BackupPath,
        [Parameter(Position=2,Mandatory=$True,HelpMessage="Module command that should be loaded if module is ready for use[-PARAM verb-cmdlet]")]
        [string] $CommandVerify,
        [Parameter(HelpMessage="Switch to suppress attempt to load a defined BackupPath[-showDebug]")]
        [switch] $NoBackup=$true,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    $Verbose = ($VerbosePreference -eq "Continue") ; 
    $smsg = "( processing `$Name:$($Name)`t`$BackupPath:$($BackupPath)`t`$CommandVerify:$($CommandVerify) )" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
    if($Name -eq 'verb-Network' -OR $Name -eq 'verb-Azure'){
        #write-host "GOTCHA!" ;
    } ;
    $lVers = get-module -name $Name -ListAvailable -ea 0 ;
    if($lVers){
        $lVers=($lVers | sort version)[-1] ;
        try {
            # suppress VerbosePreference:Continue, if set, during mod loads (VERY NOISEY)
            if($VerbosePreference = "Continue"){ $VerbosePrefPrior = $VerbosePreference ; $VerbosePreference = "SilentlyContinue" ; $verbose = ($VerbosePreference -eq "Continue") ; } ; 
            import-module -name $Name -RequiredVersion $lVers.Version.tostring() -force -DisableNameChecking   
            # reenable VerbosePreference:Continue, if set, during mod loads 
            if($VerbosePrefPrior -eq "Continue"){ $VerbosePreference = $VerbosePrefPrior ; $verbose = ($VerbosePreference -eq "Continue") ; } ;
        } catch {
            write-warning "*BROKEN INSTALLED MODULE*:$($Name)!" ;
            #import-module -name $tModDFile -force -DisableNameChecking   ;
            if(!$NoBackup -AND (gcm load-ModuleFT)){
                load-ModuleFT -tModName $tModName -tModFile $tModFile -tModCmdlet $tModCmdlet -Verbose:$($verbose) ; 
            } ;
        } ;
    } elseif ($localPSRepo){
        # if fails, no local module installed:check/register repo, find/install missing module, then load
        if($RegisteredRepo = register-localPSRepository ){
            $pltIMod =@{ Name = $Name ; scope = $null ; Repository = $RegisteredRepo.name}
            switch -regex ($env:COMPUTERNAME){
                $rgxMyBoxW { $pltIMod.scope = 'CurrentUser' }
                default { $pltIMod.scope = 'AllUsers' }
            }
            write-host -foregroundcolor yellow "Install-Module w`n$(($pltIMod|out-string).trim())" ; 
            try {
                Install-Module @pltIMod -ErrorAction Stop ; 
                # suppress VerbosePreference:Continue, if set, during mod loads (VERY NOISEY)
                if($VerbosePreference = "Continue"){ $VerbosePrefPrior = $VerbosePreference ; $VerbosePreference = "SilentlyContinue" ; $verbose = ($VerbosePreference -eq "Continue") ; } ; 
                import-module -name $Name -force -ErrorAction Stop;
                # reenable VerbosePreference:Continue, if set, during mod loads 
                if($VerbosePrefPrior -eq "Continue"){ $VerbosePreference = $VerbosePrefPrior ; $verbose = ($VerbosePreference -eq "Continue") ; } ;
            } catch {
                Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
                Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
            }  ; 

        } else { 
            throw "Unable to find/register local repostitory source:failed register:$($localPSRepo)" 
        } ;
    } ;
    if(!(get-command $CommandVerify)){
        write-warning -verbose:$true  "UNABLE TO VALIDATE PRESENCE OF $CommandVerify!" ;
    } else {     write-verbose -verbose:$true  "(confirmed $Name loaded: $CommandVerify present)" } ; 
    if($Name -eq 'verb-logging'){
        # 
    } ; 
}

#*------^ mount-module.ps1 ^------


#*------v register-localPSRepository.ps1 v------
function register-localPSRepository {
    <#
    .SYNOPSIS
    register-localPSRepository.ps1 - Confirms, or manually-registers, local PSRepository, as specified by profile $localPSRepo variable. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-12-01
    FileName    : register-localPSRepository.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-Mods
    Tags        : Powershell
    REVISIONS
    * 8:36 AM 12/1/2020 init
    .DESCRIPTION
    register-localPSRepository.ps1 - Confirms, or manually-registers, local PSRepository, as specified by profile $localPSRepo variable. 
    .PARAMETER  Repository
    Local Repository name (defaults to profile $localRepo value)[-Repository someRepo]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output
    System.Boolean
    [| get-member the output to see what .NET obj TypeName is returned, to use here]
    .EXAMPLE
    register-localPSRepository ;
    Default pass - confirms or manaually registers default local Repository (as specified in profile $localPSRepo value)
    .LINK
    https://github.com/tostka/verb-XXX
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,HelpMessage="local Repository name (defaults to profile `$localRepo value)[-Repository someRepo]")]
        [string] $Repository=$localPSRepo,
        [Parameter(Position=0,Mandatory=$false,HelpMessage="local Repository path (defaults to profile `$localPSRepoPath value)[-RepositoryPath \\server\path_to\ModulesAndScripts]")]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string] $RepositoryPath=$localPSRepoPath,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    BEGIN {
        $Verbose = ($VerbosePreference -eq "Continue") ; 
        $smsg = "Confirming registration of $($Repository) PSRepository" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
    } 
    PROCESS {
        if ($Repository -AND $RepositoryPath){
            if(!($registeredRepo = Get-PSRepository -Name $Repository)){
                $pltRepo = @{Name = $Repository ;SourceLocation = $RepositoryPath; PublishLocation = $RepositoryPath ;InstallationPolicy = 'Trusted' ;} ;
                if (Test-Path $pltRepo.SourceLocation){
                    $error.clear() ;
                    TRY {
                        write-host -foregroundcolor yellow "FIXING MISSING:Register-PSRepository w`n$(($pltRepo|out-string).trim())" ; 
                        Register-PSRepository @pltRepo ; 
                        $registeredRepo = Get-PSRepository -Name $pltRepo.name  ; 
                    } CATCH {
                        Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
                        BREAK ; 
                    } ; 
                } else {throw "Repository $pltRepo.SourceLocation is offline" }  ;
            } else {
                #write-verbose "$((get-date).ToString('HH:mm:ss')):repo registered w`n$(($registeredRepo| ft -a name,installationpolicy,sourcelocation|out-string).trim())" ; 
                #$registeredRepo | write-output ;
            } ;  

        } else { 
            throw "Missing -Repository and/or -RepositoryPath for registration!`n(or source `$localPSRepo & `$localPSRepoPath are not configured in profile)"  ; 
        } ; 
    } ; 
    END {
        if($registeredRepo){
            $registeredRepo | write-output ;
        } else { $false | write-output } ; 
    } ; 
}

#*------^ register-localPSRepository.ps1 ^------


#*------v revert-ModuleInstalledRevision.ps1 v------
function revert-moduleInstalledRevision {
    <#
    .SYNOPSIS
    revert-moduleInstalledRevision.ps1 - Rollback broken Module version to either explictly specified -RequiredVersion, or most recent prior date version (eg, prior to midnight today). 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-25
    FileName    : revert-moduleInstalledRevision.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-mod
    Tags        : Powershell,Module,Maintenance
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 12:57 PM 11/3/2021 correction: I'd shifted it below to verb-mods.
    * 1:42 PM 10/25/2021 init, flipped to verb-dev func
    .DESCRIPTION
    revert-moduleInstalledRevision.ps1 - Rollback broken Module version to either explictly specified -RequiredVersion, or most recent prior date version (eg, prior to midnight today). 
    This relies on a populated profile/global $localPsRepo value, which should contain the name of the local repository.
    Note: This runs...
    uninstall-module -name xxx -AllVersions -force
    ... to COMPLETELY CLEAR any prior revisions. 
    And then runs an install of the required version. With #requires or other depenedancies, this could require manual installs of interrum missing modules (or twinning code into the installed version, from future revisions). 

    If -RequiredVersion is unspecified, the target rev is calculated as follows:
    1. It determines most-recent prior-date rev by pulling all [modulename]*.nupkg files from the repo's SourceLocation, sorted on LastWriteTime 
        (less accurate, but a lot simpler than select-object expressioning out real sorted semvers from the nupkg name string)
    2. It then filters out all pkgs from the current day (post-midnight), and regex matches out most recent prior version's N.N.N version string, to populate the `$RequiredVersion value. 
    .PARAMETER Name
    [string] Module Name[-Name modulename]
    .PARAMETER RequiredVersion
    [version] Required revision to revert-to (semantic version n.n.n string)[-RequiredVersion 1.2.3]
    .PARAMETER Repository
    [string]Repository to be installed from (defaults to value stored as `$global:localPsRepo)[-Repository SomeRepo]
    .PARAMETER Whatif
    [switch]Parameter to run a Test no-change pass [-Whatif]
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)
    .EXAMPLE
    PS> revert-moduleInstalledRevision -name some-module -requiredversion 1.0.2 -whatif -verbose ;
    Roll back specified module to specified requiredversion, whatif no-exec pass, and verbose.
    .EXAMPLE
    PS> revert-moduleInstalledRevision -name Some-Module ;
    Roll back specified module to calulated most recent date revision on local Repository
    .LINK
    https://github.com/tostka/verb-XXX
    .LINK
    [ name related topic(one keyword per topic), or http://|https:// to help, or add the name of 'paired' funcs in the same niche (enable/disable-xxx)]
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    ## [OutputType('bool')] # optional specified output type
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Module Name[-Name modulename]")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Position=1,HelpMessage="[version]Required revision to revert-to (Semantic Version string)[-RequiredVersion]")]
        [version] $RequiredVersion,
        [Parameter(HelpMessage="[string]Repository to be installed from (defaults to `$global:localPsRepo/profile value) Name[-Repository SomeRepo]")]
        [string]$Repository=$localPsRepo,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    $verbose = ($VerbosePreference -eq "Continue") ;
    TRY {
        $error.clear() ;
        if(!$RequiredVersion){
            $pltGrpo=[ordered]@{name = $localpsrepo ; ErrorAction='STOP'} ;
            $pltGCI=[ordered]@{path="$((get-psrepository @pltGrpo).SourceLocation)\$($Name)*.nupkg" ; ErrorAction='STOP'} ;
            write-host "(retrieving most recent prior-day's revision in Repo for $($Name)...)" ; 
            write-verbose "get-psrepository w`n$(($pltGrpo|out-string).trim())" ; 
            write-verbose "gci w`n$(($pltGCI|out-string).trim())" ;             
            $Allvers = gci @pltGCI | sort lastwriteTime ; 
            $RequiredVersion = [regex]::match(($allvers | ?{$_.LastWriteTime -lt (([datetime]::Today))}| sort lastwritetime | select -last 1 ).name,'(\d+\.\d+\.\d+)\.nupkg$').captures[0].groups[1].value ; 
            $sRequiredVersion = $RequiredVersion.major,$RequiredVersion.minor,$RequiredVersion.build -join '.'
        } ; 
        if($RequiredVersion){
            $pltRMod=[ordered]@{name = $Name  ; force=$true ; ErrorAction='Continue'; } ;
            write-host "(removing current in-memory module copy)" ; 
            write-verbose "remove-module w`n$(($pltRMod|out-string).trim())" ; 
            remove-module @pltRMod ; 

            write-host "(uninstalling all versions of $Name...)" ; 
            $pltGrpo=[ordered]@{name = $Name  ; force=$true ; AllVersions= $true ;ErrorAction='Continue'; whatif=$($whatif)} ;
            write-verbose "uninstall-module w`n$(($pltGrpo|out-string).trim())" ; 
            uninstall-module @pltGrpo ; 

            $pltIMod=[ordered]@{name = $Name  ; RequiredVersion = $sRequiredVersion ; Repository = $Repository ; force=$true ; AllowClobber= $true ;ErrorAction='STOP';whatif=$($whatif);} ;
            write-host "Install-Module w`n$(($pltIMod|out-string).trim())" ; 
            Install-Module @pltIMod ; 

            write-host "(importing updated $Name...)" ; 
            $pltIpMo=[ordered]@{name = $Name  ; force=$true ; ErrorAction='Stop'; } ;
            write-verbose "import-module w`n$(($pltIpMo|out-string).trim())" ; 
            import-module @pltIpMo ; 
        } else {
            write-warning "Unable to locate a prior date Rev`nother pkgs avail (rerun with -`$RequiredVersion populated):`n$(($Allvers|out-string).trim())" ; 
            throw "`$RequiredVersion is unspecified and unable to locate most-recent prior date's version!" ;
        }; 
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
        write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        Break ;
    } ; 
}

#*------^ revert-ModuleInstalledRevision.ps1 ^------


#*------v test-ModuleUnReleasedContent.ps1 v------
function test-ModuleUnReleasedContent {
    <#
    .SYNOPSIS
    test-ModuleUnReleasedContent.ps1 - Check module source directory for component files dated after the most recent version .nupkg.LastWriteTime (e.g. output list of modules that need a fresh Build/Release)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-11-03
    FileName    : test-ModuleUnReleasedContent.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-mod
    Tags        : Powershell,Module,Maintenance
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 10:40 AM 2/3/2023 ren: test-UnReleasedModuleContent -> test-ModuleUnReleasedContent ; add: alias: test-ModuleBuild (hard to find/recall orig name, moudle should be in 2nd pos)
    * 8:59 AM 1/11/2022 added example 3, for quick CBH example dumps of targeted cmdlets in a known module.
    * 10:22 AM 12/2/2021 implment default use of $global:GIT_REPOSROOT, if present; flipped $paths, non-mandetory, and post test pre-run in the proceses block (make it run wo manual param's needed)
    * 1:12 PM 11/3/2021init, flipped to verb-mods func
    .DESCRIPTION
    test-ModuleUnReleasedContent.ps1 - Check module source directory for component files dated after the most recent version .nupkg.LastWriteTime (e.g. output list of modules that need a fresh Build/Release)
    ..PARAMETER Paths
    Module source paths to be processed (defaults to expanding my `$GIT_ReposRoot profile variable into array of module repos w names prefixed 'verbs*')[-paths 'c:\path-to\','c:\path2-to']
    .PARAMETER Repository
    [string]Repository to be checked against (defaults to value stored as `$global:localPsRepo)[-Repository SomeRepo]
    .PARAMETER rgxExcludeExts
    [regex]Files Extensions to be excluded from the comparison[-rgxExcludeExts '(.txt|.xml)']
    .PARAMETER rgxexclFiles
    [regex]File Names to be excluded from the comparison[-rgxexclFiles '(.*.logs)']
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)
    .EXAMPLE
    PS> $Paths += (resolve-path c:\sc\verb*) ;
    PS> test-ModuleUnReleasedContent -Paths $Paths -verbose ; 
    Run a pass against all paths below the c:\sc\ directory, with directory names starting with verb*, with verbose output.
    .EXAMPLE
    PS> (resolve-path c:\sc\verb*) |  test-ModuleUnReleasedContent;
    Pipeline example, echo solely modules that need a fresh Build/Release
    .EXAMPLE
    PS> gcm -module verb-mods | where verb -eq 'test' | %{get-help $_.name -example}
    Example locating an installed module, postfiltering the module cmdlets on verb 'test', and returning CBH examples for each cmdlet.
    .LINK
    https://github.com/tostka/verb-Mods
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    [CmdletBinding()]
    [Alias('test-UnReleasedModuleContent','test-ModuleBuild')]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,HelpMessage="Module source paths to be processed[-paths 'c:\path-to\','c:\path2-to']")]
        #[ValidateScript({Test-Path $_})]
        [string[]]$Paths=(resolve-path (join-path -path $GIT_REPOSROOT -childpath "verb*")),
        [Parameter(HelpMessage="[regex]Files Extensions to be excluded from the comparison[-rgxExcludeExts '(.txt|.xml)']")]
        [regex]$rgxExcludeExts = '(\.nupkg|\.gitignore|\.*_.*)',
        [Parameter(HelpMessage="[regex]File Names to be excluded from the comparison[-rgxexclFiles '(.*.logs)']")]
        [regex]$rgxexclFiles = '(.*-log.txt|ScriptAnalyzer-Results-.*\.xml|fingerprint)$',
        [Parameter(HelpMessage="[string]Repository to be checked against (defaults to value stored as `$global:localPsRepo)[-Repository SomeRepo]")]        
        [string]$Repository=$localPsRepo
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ;
        $rgxNuPkgFileName = '.*\.(\d+\.\d+\.\d+)\.nupkg$' ; 
        $repoDirs=$allPkgs=@() ; 
        $RepoSrc = (Get-PSRepository -name $Repository).SourceLocation ; 
    } ; 
    PROCESS{
        $procd=0 ; $ttl = ($Paths|measure).count ; 
        foreach ($path in $Paths){
            $procd++ ; 
            $sBnrS="`n#*------v PROCESSING ($($Procd)/$($ttl)):$($path) v------" ; 
            write-verbose "$($sBnrS)" ;
            $highpkg = $latermodfiles = $null ; 
            TRY {
                $error.clear() ;
                if(-not (test-path $Path -ea STOP)){throw "missing path!"} ; 
                $pltGci=[ordered]@{path ="$($path)\*.nupkg" ; recurse=$true ; ea = 'STOP'} ;
                write-verbose "get-childitem w`n$(($pltGci|out-string).trim())" ; 
                $pkgs = get-childitem @pltGci ; 
                $pkgs = $pkgs | 
                    select *,@{name="version";expression={[version]([regex]::match($_.name,$rgxNuPkgFileName).captures[0].groups[1].value)}} | 
                    sort version ;
                if($pkgs){
                    if($pkgs -is [system.array]){$highpkg = $pkgs[-1]}
                    else {$highpkg = $pkgs} ; 
                    write-verbose "$($path):High pkg:`n$(($highpkg |ft -a name,lastwritetime,version|out-string).trim())" ; 
                    $pltGci=[ordered]@{path =$path ;recurse=$true ;file = $true ; ea = 'STOP'} ;
                    write-verbose "get-childitem w`n$(($pltGci|out-string).trim())" ; 
                    $latermodfiles = get-childitem $path -recurse -file |
                        ?{$_.extension -notmatch $rgxExcludeExts -AND $_.name -notmatch $rgxexclFiles} | 
                        ?{$_.LastWriteTime -gt $highpkg.LastWriteTime} | sort LastWriteTime; 
                    if($latermodfiles){
                        $smsg = "`n`n===Module $($path) has files dated *after* last .pkg!:`n" ; 
                        $smsg += "`n$(($highpkg|ft -a name,lastwritetime,version|out-string).trim())`n" ; 
                        $smsg += "`n$(($latermodfiles |ft -a name,lastwritetime |out-string).trim())`n`n" ; 
                        $smsg += "`n===" ; 
                        write-warning $smsg ; 
                    } else {
                        write-verbose "`n(Module $($path) has no post-build updated files)`n`n"
                    } ; 
                } ; 
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Continue  #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
            } ; 
            write-verbose $sBnrS.replace('-v','-^').replace('v-','^-') ;
        } ; 
    }  # PROC-E
    END {} ;
}

#*------^ test-ModuleUnReleasedContent.ps1 ^------


#*------v Uninstall-AllModules.ps1 v------
function Uninstall-AllModules {
    <#
.SYNOPSIS
Uninstall-AllModules.ps1 - Queries Powershell Gallery to uninstall a module and all dependent submodules.
.NOTES
Author: Stephen Tramer (MSFT)
Website:	https://docs.microsoft.com/en-us/powershell/azure/uninstall-az-ps?view=azps-1.0.0
Updated by: Todd Kadrie
Website:	http://www.toddomation.com
Twitter:	@tostka, http://twitter.com/tostka
REVISIONS   :
* 12/12/2018 posted version
.DESCRIPTION
Queries the PowerShell Gallery to get a list of dependent submodules. Then, the script uninstalls the correct version of each submodule. You will need to have administrator access to run this script in a scope other than Process or CurrentUser.
.PARAMETER  TargetModule
.PARAMETER  Version
.PARAMETER  Force
.PARAMETER  WhatIf
.EXAMPLE
Get-InstalledModule -Name Az -AllVersions ;
Uninstall-AllModules -TargetModule Az -Version 0.7.0 -Force -whatif ;
Query Az module and specific version installed and then remove the module & dependancies
.LINK
https://docs.microsoft.com/en-us/powershell/azure/uninstall-az-ps?view=azps-1.0.0
#>
    param(
        [Parameter(Mandatory = $true)][string]$TargetModule,
        [Parameter(Mandatory = $true)][string]$Version,
        [switch]$Force,
        [switch]$WhatIf
    ) ;
    $AllModules = @() ;
    'Creating list of dependencies...' ;
    $target = Find-Module $TargetModule -RequiredVersion $version ;
    $target.Dependencies | ForEach-Object {
        if ($_.requiredVersion) {
            $AllModules += New-Object -TypeName psobject -Property @{name = $_.name; version = $_.requiredVersion } ;
        }
        else {
            # Assume minimum version ;
            # Minimum version actually reports the installed dependency
            # which is used, not the actual "minimum dependency." Check to
            # see if the requested version was installed as a dependency earlier.
            $candidate = Get-InstalledModule $_.name -RequiredVersion $version ;
            if ($candidate) {
                $AllModules += New-Object -TypeName psobject -Property @{name = $_.name; version = $version } ;
            }
            else {
                Write-Warning ("Could not find uninstall candidate for {0}:{1} - module may require manual uninstall" -f $_.name, $version) ;
            } ;
        } ;
    } ;
    $AllModules += New-Object -TypeName psobject -Property @{name = $TargetModule; version = $Version } ;
    foreach ($module in $AllModules) {
        Write-Host ('Uninstalling {0} version {1}...' -f $module.name, $module.version) ;
        try {
            Uninstall-Module -Name $module.name -RequiredVersion $module.version -Force:$Force -ErrorAction Stop -WhatIf:$WhatIf ;
        }
        catch {
            Write-Host ("`t" + $_.Exception.Message) ;
        } ;
    } ; # loop-E
}

#*------^ Uninstall-AllModules.ps1 ^------


#*------v uninstall-ModulesObsolete.ps1 v------
function uninstall-ModulesObsolete {
    <#
    .SYNOPSIS
    uninstall-ModulesObsolete - Remove old versions of Powershell modules, leaving most current - does note that later revs are published & available)
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2018-03-24
    FileName    : uninstall-ModulesObsolete.ps1
    License     : MIT
    Copyright   : (c) 4/7/2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Module,Lifecycle
    AddedCredit : Jack Fruh
    AddedWebsite: http://sharepointjack.com/2017/powershell-script-to-remove-duplicate-old-modules/
    AddedTwitter: @sharepointjack / http://twitter.com/sharepointjack	
    REVISIONS
    * 2:38 PM 2/26/2021 replc spur write-warning -for
    * 12:38 PM 8/7/2020 added -scope vari, and test for local\Administrators (when running AllUsers scope uninstalls), fixed comparison typo #78
    * 1:03 PM 8/5/2020, rewrote & expanded orig concept as func, added to verb-Mods
    .DESCRIPTION
    uninstall-ModulesObsolete - Remove old versions of Powershell modules, leaving most current - does note that later revs are published & available)
    Inspired by original concept posted at Jack Fruh's blog.
    .PARAMETER Modules
    Specific Module(s) to be processed[-Modules array-of-module-descrptors]
    .PARAMETER Repository
    Source Repository, for which *all* associated local installed modules should be processed[-Repository 'repo1','repo2']
    .PARAMETER Scope
    Scope to be targeted (AllUsers|CurrentUser, default: no filtering)[-Scope AllUsers]
    .PARAMETER whatIf
    Whatif Flag  [-whatIf]
    .EXAMPLE
    uninstall-ModulesObsolete -scope AllUsers -verbose -whatif ;
    Run a whatif pass at uninstalling all obsolete module version in the AllUsers scope
    .EXAMPLE
    uninstall-ModulesObsolete -verbose -whatif ;
    Run a whatif pass at uninstalling all obsolete module version
    .EXAMPLE
    uninstall-ModulesObsolete -Modules "AzureAD","verb-exo" -verbose -whatif ;
    Run a whatif pass on explicit module descriptors, uninstalling all obsolete module versions
    .EXAMPLE
    uninstall-ModulesObsolete -Repository "repo1" -verbose -whatif ;
    Run a whatif pass on uninstalling all obsolete module versions sourced in a specific Repository
    .LINK
    https://github.com/tostka
    #>
    #Requires -Modules verb-Auth
    [CmdletBinding()] 
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Array of specific Module(s) to be processed[-Modules 'mod1','mod2']")]
        [Alias('Name')]$Modules,
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Source Repository, for which *all* associated local installed modules should be processed (should match Repository property of module, as returned by Get-InstalledModule cmdlet)[-Repository 'Repo1']")]
        [array]$Repository,
        [Parameter(HelpMessage="Scope to be targeted (AllUsers|CurrentUser, default: no filtering)[-Scope AllUsers]")]
        [ValidateSet("AllUsers","CurrentUser")]
        [array]$Scope,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch]$whatIf
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 
        # construct dynamic scope regex's (accomodates profile redirection and system variant progfiles locations)
        # AllUsers scope
        [regex]$rgxModsAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\Modules" ;
        # CurrUser scope
        [regex]$rgxModsCurrUserScope="^$([regex]::escape([environment]::getfolderpath('Mydocuments')))\\((Windows)*)PowerShell\\Modules" ;
    } ;
    PROCESS {
        if(!$Modules){
            $smsg = "Gathering all installed modules..." ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $tModules = get-installedmodule ;
        } else { 
            $smsg = "$(($Modules|measure).count) specific Modules specified`n$(($Modules|out-string).trim())" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $tModules = ($modules | %{get-installedmodule $_ | write-output } ) ;
        } ; 
        if($Repository){
            $tModules = $tModules|?{$_.Repository -eq $Repository} ; 
        } ; 
        if($Scope){
            switch ($Scope){
                "AllUsers" {
                    $smsg = "(-scope AllUsers specified, filtering...)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $tModules = $tModules |?{$_.installedlocation -match $rgxModsAllUsersScope} ;
                } 
                "CurrentUser" {
                    $smsg = "(-scope CurrentUser specified, filtering...)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $tModules = $tModules |?{$_.installedlocation -match $rgxModsCurrUserScope} 
                } 
                "default" {
                    $smsg = "(no scope specified, all modules from AllUsers and $($env:USERNAME)'s profile will be targeted)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } 
            } ; 
        } ; 
        $ttl=($tModules|Measure-Object).count ;
        $Procd=0 ; 
        $smsg = "($(($tModules|measure).count) modules returned)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

        if($AllUMods = $tModules |?{$_.installedlocation -match $rgxModsAllUsersScope}){
            if (-not(Test-IsLocalAdmin)){
                $smsg = "Some modules targeted are in the *AllUsers* context (within ProgramFiles)...`n$(($AllUMods|ft -a InstalledLocation|out-string).trim())`nInstallation/Uninstallation from that context *requires* local\Administrator permissions, which are not currently available under $($env:USERDOMAIN)\$($env:USERNAME). EXITING!" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } #Error|Warn|Debug 
                else{ write-warning  "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                throw "AllUsers Modules targeted, non-local\Administrator permisisons present." ; 
                break ; 
            } ; 
        } else { 
            $smsg = "(no modules from AllUsers scope are targeted)" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ; 

        foreach ($Module in $tModules) {
            $Procd++ ;
            $sBnr="#*======v ($($Procd)/$($ttl)):PROCESSING:$($Module.name) v======" ; 
            $smsg=$sBnr ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            get-module $Module.name | Remove-Module -WhatIf:$($whatif) ; 
            $ModRevLatest = get-installedmodule $Module.name ; 
            $ModVersions = get-installedmodule $Module.name -allversions ;
            if(($ModVersions|measure).count -gt 1){
                $smsg="$(($ModVersions|measure).count) versions of this module found [ $($Module.name) ]" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

                foreach ($ModVers in ($ModVersions|?{$_.version -ne $ModRevLatest.version})) {
                    $sBnrS="`n#*------v VERS: $($ModVers.version): v------" ; 
                    $smsg=$sBnrS ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    if ($ModVers.version -ne $ModRevLatest.version){
                        $smsg="--Uninstalling $($ModVers.name) v:$($ModVers.version) [leaving v:$($ModRevLatest.version)]" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        
                        $error.clear() ;
                        TRY {
                            $ModVers | uninstall-module -force -whatif:$($whatif) ;
                        } CATCH {
                            $ErrTrapd=$Error[0] ;
                            $smsg= "Failed to exec cmd because: $($ErrTrapd)" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
                            Continue ;#Continue/Exit/Stop
                        } ; 
                    } ;
                    $smsg = "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ; # loop-E
            } else {
                $smsg="(Only a single version found $($Module.name), skipping)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            }; 
            $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ; # loop-E
        $smsg = "PASS COMPLETED" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 
    END{ } ;
}

#*------^ uninstall-ModulesObsolete.ps1 ^------


#*------v update-PSPowerShellGetLegacy.ps1 v------
Function update-PSPowerShellGetLegacy {
    <#
    .SYNOPSIS
    update-PSPowerShellGetLegacy.ps1 - Manually update repository location of Legacy powershellGet mod support (no native PSG support for Psv3-4)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-11-05
    FileName    : update-PSPowerShellGetLegacy.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Module,PowershellGet,Legacy
    REVISIONS
    * 4:14 PM 12/1/2020 debugged to publish, also succ used the install .ps1 to install result into FE! ; ; shifted the #Requires -version 5 inline ('multiple requires vers' error when w/in module), also updated CBH to include demo code to copy the localPSRepoPath cached version locally (for either CurrUser or AllUsers)
    * 10:37 AM 11/5/2020 init
    .DESCRIPTION
    update-PSPowerShellGetLegacy.ps1 - Manually update repository location of Legacy powershellGet mod support (no native PSG support for Psv3-4)
    Script must be run from a Ps5+ machine, with it's native PowerShellGet support, 
    to prepare and publish PSG-supporting current modules for legacy Psv3/Psv4 systems 
    The Script requires a local global $localPSRepoPath pointed at the parent directory, 
    above the local PSRepository.SourceLocation ((Get-PSRepository REPONAME).ScriptPublishLocation)

    The script Save-Modules's the latest PowershellGet to a new Temp directory, 
    locates the PowerShellGet & PackageManagement submodule current version n.n.n 
    folders, and copies them to below a new "$localPSRepoPath\PSGetStatic" shared 
    directory (below the parent dir of the local PSRepo dir ScriptPublishLocation).

    The static PowershellGet content can then be manually copied from that location 
    to the normal $env:psmodulepath "Module"-storage locations on Psv3/Psv4 
    machines that require functional PowerShellGet, to leverage modern PSRepo use. 
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    install-PSPowerShellGetLegacy.ps1 -localPSRepoPath $($localPSRepoPath) -whatif
    copy-item -path "$localPSRepoPath\PSGetStatic" -destination ($env:psmodulepath.split(';') -match '[A-Z]:\\Users') -force -whatif ; 
    Update PowershellGet legacy support in the localPSRepoPath, then copy the updated files to the *CurrentUser* Modules directory.
    .EXAMPLE
    install-PSPowerShellGetLegacy.ps1 -localPSRepoPath $($localPSRepoPath) -whatif
    copy-item -path "$localPSRepoPath\PSGetStatic" -destination ($env:psmodulepath.split(';') -match '[A-Z]:\\Program\sFiles\\WindowsPowerShell') -force -whatif ; 
    Update PowershellGet legacy support in the localPSRepoPath, then copy the updated files to the *AllUsers* Modules directory.
    .LINK
    https://github.com/tostka/verb-Module
    #>
    # Requires -Version 5 # can't use version in child ps1's:the monolithic .psm1 can only have *one* instance of #requires -version, in the entire module! shift to testing $host.version.major inline
    [CmdletBinding()]
    PARAM(
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    BEGIN { 
        $Verbose = ($VerbosePreference -eq 'Continue') ; 
        if($host.version.major -ne 5){
            throw "This script must be run on Powershell v5 (for full PSGet support)!" ; 
        } ; 
    } ;  # BEGIN-E
    PROCESS {
        $error.clear() ;
        TRY {
            # 1 fr box w psg installed, use save-module to pull down a copy
            $tDir = join-path -path ([System.IO.Path]::GetTempPath()) -child 'PowerShellGet\' ; 
            if(!(test-path $tDir -ea 0)){
                write-verbose "Creating tmpdir: $($tDir)" ; 
                mkdir -path $tDir -force ; 
            } else {
                # purge existing vers
                $subs = $null ; 
                $subs = gci $tdir -Directory -ea 0;
                if($subs.count){
                    write-verbose "Purging existing subfolders" ; 
                    foreach($sub in $subs){
                        $pltRD=@{ path=$sub.fullname ; Recurse=$true ; force=$true ; whatif=$($whatif) ; } ; 
                        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):remove-item w`n$(($pltRD|out-string).trim())" ; 
                        #remove-item -path $sub.fullname -Recurse -force #-whatif
                        remove-item @pltRD ; 
                    } ; 
                } ; 
            } ;  
            # get latest version
            $pltSM=@{ Name='PowerShellGet' ;Path=$tDir ;Repository='PSGallery' ;whatif=$($whatif)} ; 
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):Save-Module w`n$(($pltSM|out-string).trim())" ; 
            Save-Module @pltSM ; 
            if(!$whatif){
                [array]$thisVers=$null ; 
                $sdirs = gci $tdir\ -recur -Directory |?{$_.name -match '\d*\.\d*\.\d*((\.\d*)*)'} | select -expand fullname ; 
                # parent it, and use \\REPOSERVER\REPOSHARE\PSGetStatic
                $repopathPSG = join-path -path (split-path $localPSRepoPath) -child PSGetStatic ; 
                if(!(test-path $repopathPSG)){
                    write-verbose "Creating `$repopathPSG: $($repopathPSG)" ; 
                    mkdir -path $repopathPSG -force ; 
                } else {
                    # purge all existing vers
                    $subs = $null ; 
                    $subs = gci $repopathPSG -Directory -ea 0;
                    if($subs.count){
                        write-verbose "Purging existing subfolders" ; 
                        foreach($sub in $subs){
                            $pltRD=@{ path=$sub.fullname ; Recurse=$true ; force=$true ; whatif=$($whatif) ; } ; 
                            write-verbose "remove-item w`n$(($pltRD|out-string).trim())" ; 
                            remove-item @pltRD ; 
                        } ; 
                    } ; 
                } ; 
                foreach($sdir in $sdirs){
                    $psgMName = (split-path $sdir).tostring().split('\')[-1] ; 
                    $destpath = "$($repopathPSG)\$($psgMName)\" ; 
                    if(!(test-path $destpath)){
                        write-verbose "Creating $($destpath)" ; 
                        mkdir -path $destpath -force ; 
                    } ; 
                    $pltCI = @{
                        #path = "$sdir\*";
                        path = $sdir;
                        destination = $destpath ; 
                        Recurse = $true ; 
                        whatif=$($whatif) ;
                    } ; 
                    #copy-item -Path "$sdir\*" -Destination $destpath -whatif
                    write-verbose "copy-item w`n$(($pltCI|out-string).trim())" ; 
                    copy-item @pltCI ; 
                    if($verbose){
                        gci -path $pltCI.destination -Recurse ; 
                    } ; 
                    $pltCI.path -match '\d*\.\d*\.\d*((\.\d*)*)'
                    if($matches){
                        $thisVers += $matches[0] ; 
                    } ; 
                } ; 
                # cleanup the temp
                $pltRD=@{ 
                path=$tdir.substring(0,$tdir.length-1) ; # trim the trailing \ off to purge the dir itself as well
                Recurse=$true ; force=$true ; whatif=$($whatif) ; } ; 
                write-verbose "CLEANUP:remove-item w`n$(($pltRD|out-string).trim())" ; 
                remove-item @pltRD ; 
            } else { 
                write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):(`-whatif:skipping balance of process)" ; 
            } ; 
        } CATCH {
            Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
            Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ; 
    } ;  # PROC-E
    END {
        $hMsg=@"
The $($mods -join ' & ') manual 'legacy' modules have been updated to version $($thisvers -join ' & ') respectively
and both were copied to the...

$($repopathPSG)

...shared Repo parent directory.

To Install this module, and add *legacy* PowershellGet support to Psv3 & Psv4 machines:

1) copy the install-PSPowerShellGetLegacy.ps1 script locally to the target server
2) run the following to perform an install from the shared repo location:

[cd to the directory where the .ps1 has been stored - commonly c:\scripts]
install-PSPowerShellGetLegacy.ps1 -localPSRepoPath $($localPSRepoPath) -whatif

The trailing -whatif parameter above runs a *test* pass, no changes. 
Remove the -whatif to run a full execution & install. 
"@ ; 
        write-host -foregroundcolor green $hMsg ; 

    } ;  # END-E
}

#*------^ update-PSPowerShellGetLegacy.ps1 ^------


#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function check-ReqMods,Disconnect-PssBroken,find-profileScripts,Get-ModulePublishedVersion,get-ModuleRecentPublishedRevisions,get-RepoModulesHighestVersion,test-IsUncPath,Install-ModulesTin,load-Module,load-ModuleFT,mount-Module,register-localPSRepository,revert-moduleInstalledRevision,test-ModuleUnReleasedContent,Uninstall-AllModules,uninstall-ModulesObsolete,update-PSPowerShellGetLegacy -Alias *




# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUauLNvLbsAMqLmnpfTPPfA4P3
# /WigggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDEyMjkxNzA3MzNaFw0zOTEyMzEyMzU5NTlaMBUxEzARBgNVBAMTClRvZGRT
# ZWxmSUkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALqRVt7uNweTkZZ+16QG
# a+NnFYNRPPa8Bnm071ohGe27jNWKPVUbDfd0OY2sqCBQCEFVb5pqcIECRRnlhN5H
# +EEJmm2x9AU0uS7IHxHeUo8fkW4vm49adkat5gAoOZOwbuNntBOAJy9LCyNs4F1I
# KKphP3TyDwe8XqsEVwB2m9FPAgMBAAGjdjB0MBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MF0GA1UdAQRWMFSAEL95r+Rh65kgqZl+tgchMuKhLjAsMSowKAYDVQQDEyFQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEGwiXbeZNci7Rxiz/r43gVsw
# CQYFKw4DAh0FAAOBgQB6ECSnXHUs7/bCr6Z556K6IDJNWsccjcV89fHA/zKMX0w0
# 6NefCtxas/QHUA9mS87HRHLzKjFqweA3BnQ5lr5mPDlho8U90Nvtpj58G9I5SPUg
# CspNr5jEHOL5EdJFBIv3zI2jQ8TPbFGC0Cz72+4oYzSxWpftNX41MmEsZkMaADGC
# AWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZp
# Y2F0ZSBSb290AhBaydK0VS5IhU1Hy6E1KUTpMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSvAOGo
# ijL+/CKcLHBeuQI+/q8yYzANBgkqhkiG9w0BAQEFAASBgBxzo/ZlNgpFJ0aPcdEK
# HIwa+tn36OSEjyN8pP5OzBzkcB1bUUmwVXYb+RmYa/KGJysB25fCh7n/4fKLZJJQ
# X/SoXT2yVxpAIhieRfc2BdW+jYsxGvx5x4E4TcnwSXva2pD8A87PIGyilqVLc37h
# l0bGcrFrAsP3q+luT3m3L9o7
# SIG # End signature block
