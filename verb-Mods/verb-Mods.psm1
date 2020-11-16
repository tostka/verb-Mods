﻿# verb-mods.psm1


  <#
  .SYNOPSIS
  verb-Mods - Generic module-related functions
  .NOTES
  Version     : 1.0.17.0
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
$Paths = @{
        AllUser_WPS = $pshome ;
        CurrentUser_WPS = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath "WindowsPowerShell" ;
        AllUser_PS = "$env:programfiles\PowerShell\*" ;
        CurrentUser_PS = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath "PowerShell" ;
    } ;
    $OutObj = @() ; 
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
    $outObj | write-output

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
        if(!(test-path function:$tModCmdlet)){
            write-warning -verbose:$true  "UNABLE TO VALIDATE PRESENCE OF $tModCmdlet`nfailing through to `$backInclDir .ps1 version" ;
            $sLoad = (join-path -path $backInclDir -childpath "$($tModName).ps1") ;
            if (Test-Path $sLoad) {
                Write-Verbose -verbose:$true ((Get-Date).ToString("HH:mm:ss") + "LOADING:" + $sLoad) ;
                . $sLoad ;
                if ($showdebug) { Write-Verbose -verbose "Post $sLoad" };
                if(!(test-path function:$tModCmdlet)){
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
        if(!($localRepo = Get-PSRepository -Name $localPSRepo)){
                $pltRepo = @{Name = $localRepo ;SourceLocation = $localPSRepoPath; PublishLocation = $localPSRepoPath ;InstallationPolicy = 'Trusted' ;} ;
                if (Test-Path $pltRepo.SourceLocation){
                    Register-PSRepository @pltRepo  ;
                    write-host -foregroundcolor yellow "FIX MISSING:Register-PSRepository w`n$(($pltRepo|out-string).trim())" ; 
                    $localRepo = Get-PSRepository $pltRepo.name ;
                } else {throw "Repository $pltRepo.SourceLocation is offline" }  ;
        } ; 
        if($localRepo){
            $pltIMod =@{ Name = $Name ; scope = $null}
            switch -regex ($env:COMPUTERNAME){
                $MyBoxW { $pltIMod.scope = 'CurrentUser' }
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
            throw "Unable to find/register local repostitory source:$($localPSRepo)" 
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
