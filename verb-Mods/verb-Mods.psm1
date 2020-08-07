﻿# verb-mods.psm1


  <#
  .SYNOPSIS
  verb-Mods - Generic module-related functions
  .NOTES
  Version     : 1.0.10.0
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
            Import-Module $Module ;
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
                import-module -name $tModName -RequiredVersion $lVers.Version.tostring() -force -DisableNameChecking   
            } catch {
                write-warning "*BROKEN INSTALLED MODULE*:$($tModName)`nBACK-LOADING DCOPY@ $($tModDFile)" ;
                import-module -name $tModDFile -force -DisableNameChecking   
            } ;
        } elseif (test-path $tModFile) {
            write-warning "*NO* INSTALLED MODULE*:$($tModName)`nBACK-LOADING DCOPY@ $($tModDFile)" ;
            try {
                import-module -name $tModDFile -force -DisableNameChecking
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
    #Requires -Version 3
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
                else{ write-warning -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
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

#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function check-ReqMods,Disconnect-PssBroken,Get-ModulePublishedVersion,load-Module,load-ModuleFT,uninstall-ModulesObsolete -Alias *


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUN7jMqnpdxMaTkJbE1W/JoBer
# cSKgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ1mL3q
# ZPsxoETgRS+T5DqmyuoccDANBgkqhkiG9w0BAQEFAASBgCNQgjrU/r5z3y1BcJel
# 1GHoraTe9xTT/xhlARv9+gsJ27HERUQ5YR+kcko15HcSs91U6W2G4xffAWZxuyN7
# C60pC7rVHHgUoyU9zJff7DeBT3M1tx4xMGXwvveqTtEjH3EyqT49rUuDgvRGhEFb
# EBL3QVLK66nXcljrtTFwOD7S
# SIG # End signature block
