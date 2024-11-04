#*------v Install-ModulesTDO v------
function Install-ModulesTDO {
    <#
    .SYNOPSIS
    Install-ModulesTDO - Loops a list of modules (PSGallery, local repo; any locally registered Repo), checks install state (against get-module -list, and get-installedmodule), and if neither found, find-Module's & install-Module's current rev from specified repo. Supports optionally specifying -Module string array as series of "ModuleName;RequiredVersion" (e.g. 'ExchangeOnlineManagement;3.6.0'), to drive tests for unupgraded existing Module installs (upgrades when -lt the specified RequiredVersion)
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2018-03-24
    FileName    : Install-ModulesTDO.ps1
    License     : MIT
    Copyright   : (c) 4/7/2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-mods
    Tags        : Powershell,Module,Lifecycle,Install
    AddedCredit : 
    AddedWebsite: 
    AddedTwitter: 
    REVISIONS
    * 10:58 AM 11/4/2024 got through debugging/non-whatif pass on Curly: Worked for funcs used, into new _install-ThisModule; so far so good
    * 3:27 PM 11/1/2024 roughed in, undebugged _install-ThisModule(), and call code, need to step debug through it
    * 2:30 PM 10/31/2024 added params: UpdateToLatest, UpdateMinDaysOld, RequiredVersion to drive update choices, and ensure that only mature new releases are installed (gt 30 days released). 
    * 4:26 PM 10/30/2024 retooled to support inbound ModuleName;RequiredVersion -Module spec (verify, upgrade to specified version); 
        Now tests for specified RequiredVersion, and upgrades if less than. 
        added more extensive testing, split out the get-installedmodule & gmo -list tests into separate steps, then checked which had latest rev, 
        and used that as the standard for curr latest rev (frequently installedmodule is behind gmo -list).
        Ren'd install-ModulesTin -> Install-ModulesTDO, and aliased old name (and added alias: Confirm-ModuleDependancy, for use to test/autoupgrade dep status modules in other scripts)
    * 1:24 PM 10/6/2021 code local-repo pref for find-module returning multi matches (generally PSGallery & a local repo, with a fork etc on local - assumes the local is tuned/updated for our specific needs)
    * 2:22 PM 10/5/2021 ported from install-WorkstationModules.ps1 to verb-mods (6/2/21 vers)
    .DESCRIPTION
    Install-ModulesTDO - Loops a list of PowershellGallery modules, checks for gmo -list, and get-installedmodule, and if neither, finds & installs current rev from PsG. Supports optionally specifying Module string as "ModuleName;RequiredVersion", to drive tests for unupgraded existing Module installs (upgrades when -lt the specified RequiredVersion)
    .PARAMETER Modules
    Array of PSGallery Modules to Install[-modules 'mod1','mod2']
    .PARAMETER Scope
    Scope to be targeted (AllUsers|CurrentUser, default: no filtering)[-Scope AllUsers]
    .PARAMETER Repository
    Source Repository[-Repository myLocalRepo
    .PARAMETER UpdateToLatest
    Switch to force update to the latest revision found, at any pass(e.g. uses latest Find-Module discovered version as RequiredVersion)[-UpdateToLatest]
    .PARAMETER Repository
    Source Repository[-Repository myLocalRepo
    .PARAMETER RequiredVersion
    Minimum Required Version to install/'pass' as a dependancy[-RequiredVersion '1.2.3']
    .PARAMETER UpdateToLatest
    Switch to force update to the latest revision found, at any pass(e.g. uses latest Find-Module discovered version as RequiredVersion)[-UpdateToLatest]
    .PARAMETER UpdateMinDaysOld
    Minimum Days posted, a new revision release needs to be, before auto-installing under this script (defaults to 30 days)[-UpdateMinDaysOld 60]
    .PARAMETER showDebug
    Debugging Flag (deprecated, use -verbose) [-showDebug]
    .PARAMETER whatIf
    Whatif Flag  [-whatIf]
    .EXAMPLE
    PS> $psdeskmods ="Pester","PSScriptAnalyzer" ; 
    PS> $bRet = Install-ModulesTDO -Modules $psdeskmods -scope CurrentUser -verbose -whatif:$($whatif) ; 
    Install Pester & PSScriptAnalyzer mods to the CurrrentUser context, with verbose output, and whatif read from a preset
    .EXAMPLE
    PS> $bRet = Install-ModulesTDO -Modules 'Statistics' -RequiredVersion '1.2.0.149' -scope CurrentUser -verbose -whatif:$($whatif) ; 
    Demo installing the Statistics module with a specified RequiredVersion, to CurrentUser scope, verbose output, and whatif
    .EXAMPLE
    PS> install-ModulesTDO -Modules 'AzureAD;2.0.2.182','ExchangeOnlineManagement;3.6.0' -Scope AllUsers -Repository PSGallery -verbose -whatif ;
    Demo installing array of AzureAD & EOM modules, each with a RequiredVersion specified (after semicolon delimiter), to AllUsers scope, from PSGallery repo, with verbose outputs, and whatif specified
    .LINK
    https://github.com/tostka/verb-mods
    #>
    [CmdletBinding()] 
    [Alias('Confirm-ModuleDependancy','Install-ModulesTin')]
    Param(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Array of PSGallery Modules to Install")]
            [ValidateNotNullOrEmpty()][string[]]$Modules,
        [Parameter(Position=1,HelpMessage="Module installation scope (CurrentUser|AllUsers - defaults CU)[-Scope AllUsers]")]
            [ValidateSet("AllUsers","CurrentUser")]
            [string]$Scope,
        [Parameter(HelpMessage="Source Repository[-Repository myLocalRepo]")]
            [string]$Repository, 
        [Parameter(HelpMessage="Minimum Required Version to install/'pass' as a dependancy[-RequiredVersion '1.2.3']")]
            [version]$RequiredVersion,
        [Parameter(HelpMessage="Switch to force update to the latest revision found, at any pass(e.g. uses latest Find-Module discovered version as RequiredVersion)[-UpdateToLatest]")]
            [switch]$UpdateToLatest,
        [Parameter(HelpMessage="Minimum Days posted, a new revision release needs to be, before auto-installing under this script (defaults to 30 days)[-UpdateMinDaysOld 60]")]
            [int] $UpdateMinDaysOld = 30,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
            [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
            [switch] $whatIf
    ) ;
    BEGIN {
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        $verbose = $($VerbosePreference -eq "Continue")
        if($showDebug){$verbose = $true} ; 
        $sBnr="#*======v $($CmdletName): v======" ;
        write-verbose  "$((get-date).ToString('HH:mm:ss')):$($sBnr)" ;
        if(-not $Scope){
            write-warning "No -Scope specified: Defaulting to CurrentUser" ; 
            $Scope = "CurrentUser"
        } ; 

        $propsFindMod = 'Version','Name','Repository','Description' ;
        $propsFindModV = 'name','type','version','description','repository' ; 
        $prpGMom = 'Name','Version','Path'; 
        $prpGIMo = 'Name','Version','InstalledLocation','InstalledDate','UpdatedDate','Repository' ; 

        #*======v FUNCTIONS v======

        #*------v Function _install-ThisModule v------
        function _install-ThisModule {
            [CmdletBinding()] 
            [Alias('Confirm-ModuleDependancy','Install-ModulesTin')]
            Param(
                [Parameter(HelpMessage="Overrides warning messages about installation conflicts about existing commands on a computer. Overwrites existing commands that have the same name as commands being installed by a module. AllowClobber and Force can be used together in an `Install-Module` command.")]
                    [switch]$AllowClobber,
                [Parameter(HelpMessage="Allows you to install a module marked as a pre-release.")]
                    [switch]$AllowPrerelease,
                [Parameter(HelpMessage="Prompts you for confirmation before running the `Install-Module` cmdlet.")]
                    [switch]$Confirm,
                [Parameter(HelpMessage="Specifies a user account that has rights to install a module for a specified package provider or source.")]
                    [pscredential]$Credential,
                [Parameter(HelpMessage="Installs a module and overrides warning messages about module installation conflicts. If a module with the same name already exists on the computer, Force allows for multiple versions to be installed. If there is an existing module with the same name and version, Force overwrites that version. Force and AllowClobber can be used together in an `Install-Module` command.")]
                    [switch]$Force,
                [Parameter(HelpMessage="Specifies the maximum version of a single module to install. The version installed must be less than or equal to MaximumVersion . If you want to install multiple modules, you cannot use MaximumVersion . MaximumVersion and RequiredVersion cannot be used in the same `Install-Module` command.")]
                    [version]$MaximumVersion,                
                [Parameter(HelpMessage="Specifies the minimum version of a single module to install. The version installed must be greater than or equal to MinimumVersion . If there is a newer version of the module available, the newer version is installed. If you want to install multiple modules, you cannot use MinimumVersion . MinimumVersion and RequiredVersion cannot be used in the same `Install-Module` command.")]
                    [version]$MinimumVersion,
                [Parameter(HelpMessage="Specifies the exact names of modules to install from the online gallery. A comma-separated list of module names is accepted. The module name must match the module name in the repository. Use `Find-Module` to get a list of module names. ")]
                    [ValidateNotNullOrEmpty()]
                    [string[]]$Name,
                [Parameter(HelpMessage="Specifies a proxy server for the request, rather than connecting directly to the Internet resource.")]
                    [uri]$Proxy,
                [Parameter(HelpMessage="Specifies a user account that has permission to use the proxy server that is specified by the Proxy parameter.")]
                    [pscredential]$ProxyCredential,
                [Parameter(HelpMessage="Use the Repository parameter to specify which repository is used to download and install a module. Used when multiple repositories are registered. Specifies the name of a registered repository in the `Install-Module` command. To register a repository, use `Register-PSRepository`. To display registered repositories, use `Get-PSRepository`.")]
                    [string[]]$Repository,    
                [Parameter(HelpMessage="Specifies the exact version of a single module to install. If there is no match in the repository for the specified version, an error is displayed. If you want to install multiple modules, you cannot use RequiredVersion . RequiredVersion cannot be used in the same `Install-Module` command as MinimumVersion or MaximumVersion.")]
                    [version]$RequiredVersion,
                [Parameter(Position=1,HelpMessage="Module installation scope (CurrentUser|AllUsers - defaults CU)[-Scope AllUsers]")]
                    [ValidateSet("AllUsers","CurrentUser")]
                    [string]$Scope='CurrentUser',
                [Parameter(HelpMessage="Allows you to install a newer version of a module that already exists on your computer. For example, when an existing module is digitally signed by a trusted publisher but the new version is notdigitally signed by a trusted publisher.")]
                    [switch]$SkipPublisherCheck,                
                [Parameter(HelpMessage="Shows what would happen if an `Install-Module` command was run. The cmdlet is not run.")] 
                    [switch] $whatIf
            ) ;
            # B-transplant
            TRY{
                $pltIsModule=[ordered]@{
                    Name=$Name;
                    Scope=$scope ;
                    AllowClobber = $true;
                    Force =  $true;
                    ErrorAction="Stop" ;
                    Verbose = $true ;
                    whatif=$($whatif) ;
                } ;
                if($RequiredVersion){
                    $smsg = "(adding `$pltIsModule.'RequiredVersion',$($RequiredVersion))" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $pltIsModule.add('RequiredVersion',$RequiredVersion) ;
                } ;
                if($Repository){
                    $smsg = "(adding `$pltIsModule.'Repository',$($Repository))" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $pltIsModule.add('Repository',$Repository) ;
                } ; 
                if($AllowPrerelease){
                    $smsg = "(adding `$pltIsModule.'AllowPrerelease',$($AllowPrerelease))" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $pltIsModule.add('AllowPrerelease',$AllowPrerelease) ;
                } ; 
                if($MaximumVersion){
                    $smsg = "(adding `$pltIsModule.'MaximumVersion',$($MaximumVersion))" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $pltIsModule.add('MaximumVersion',$MaximumVersion) ;
                } ; 
                if($MinimumVersion){
                    $smsg = "(adding `$pltIsModule.'MinimumVersion',$($MinimumVersion))" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $pltIsModule.add('MinimumVersion',$MinimumVersion) ;
                } ; 
                if($Proxy){
                    $smsg = "(adding `$pltIsModule.'Proxy',$($Proxy))" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $pltIsModule.add('Proxy',$Proxy) ;
                } ; 
                if($ProxyCredential){
                    $smsg = "(adding `$pltIsModule.'ProxyCredential',$($ProxyCredential))" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $pltIsModule.add('ProxyCredential',$ProxyCredential) ;
                } ; 
                if($SkipPublisherCheck){
                    $smsg = "(adding `$pltIsModule.'SkipPublisherCheck',$($SkipPublisherCheck))" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $pltIsModule.add('SkipPublisherCheck',$SkipPublisherCheck) ;
                } ; 

                $smsg = "get-module -Name $($Name) -ea 0 | remove-module -Force" ; 
                if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                get-module -Name $Name -ea 0 | remove-module -Force ; 

                $smsg = "Install-Module w`n$(($pltIsModule|out-string).trim())" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

                Install-Module @pltIsModule ;

                if(-not $whatif -ANd (get-module -Name $pltIsModule.name -ListAvailable | ?{$_.version -eq $RequiredVersion})){
                                
                    $smsg = "get-module -Name $($latestLocalRev.Name) -listavailable " ; 
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 

                    if($AllObsoVersions = get-module -Name $pltIsModule.name -ListAvailable | ?{$_.version -ne $RequiredVersion}){
                        foreach($ObsoVers in $AllObsoVersions){
                            # then run forced uninstall of old rev, using RequiredVersion:
                            $pltUSMod=[ordered]@{
                                name = $ObsoVers.Name ;
                                RequiredVersion = $ObsoVers.version  ;
                                force  = $true ; 
                                Verbose = ($PSBoundParameters['Verbose'] -eq $true) ;
                                ErrorAction = 'STOP' ;
                                whatif = $($whatif) ;
                            } ;
                            $smsg = "Obsolete Version Removal: Uninstall-Module w`n$(($pltUSMod|out-string).trim())" ; 
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Uninstall-Module -force -name $pltIsModule.Name -RequiredVersion $ObsoVers.version -verbose -ea STOP ;  ;
                            Uninstall-Module @pltUSMod ; 

                        } ; 
                    } ; 
                    # finally ipmof the installed rev
                    $smsg = "import-module -Name $($latestLocalRev.Name) -force -verbose " ; 
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 

                    $pltIPMod=[ordered]@{
                        Name = $pltIsModule.name ;
                        RequiredVersion = $pltIsModule.RequiredVersion ;
                        Force = $true ;
                        verbose = $true ;
                        erroraction = 'STOP';
                    } ;
                    $smsg = "import-module w`n$(($pltIPMod|out-string).trim())" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #import-module -Name $pltIsModule.name -RequiredVersion $pltIsModule.RequiredVersion -Force -verbose -ea STOP;
                    import-module @pltIPMod ; 

                    $smsg = "get-module -Name $($pltIPMod.Name)" ; 
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 

                    get-module -Name $pltIPMod.Name -ErrorAction STOP 

                }elseif($whatif){
                    write-host "-whatif: skipping balance" ; 
                } else { 
                    $smsg = "Missing upgraded version: $($ModRequiredVersion)! (skipping prior $($latestLocalRev.name): $($latestLocalRev.version) uninstall" ; 
                    write-warning $smsg ; 
                    throw $smsg ; 
                } ; 
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                $smsg += "`n$($ErrTrapd.Exception.Message)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                BREAK ;
            } ; 
            # E-transplant 
        } ;
        #*------^ END Function _install-ThisModule ^------

        #*======^ END FUNCTIONS ^======

        #*======v SUB MAIN v======

        $ttl=($Modules|measure).count ; 
        $Procd=0 ; 
        $smsg= "Confirming $(($Modules|measure).count) PS Modules:" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

        if($RequiredVersion -and (( $Modules |  measure).count -gt 1)){
            $smsg = "-RequiredVersion:$($RequiredVersion) specified, with *multiple* -Modules`n$(($Modules -join ','|out-string).trim())" ; 
            $smsg += "`n-RequiredVersion should only be used with a *single* -Module specification" ; 
            $smsg += "`nPlease specify *individual* per-Module RequiredVersions, by specifying each -Module as an array member with it's *own* specific RequiredVersion"
            $smsg += "`n by using the format:" ; 
            $smsg += "`n'Module1Name;1.2.3','Module2Name;4.5.6'" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            throw $smsg ; 
            break ; 
        } ; 

        #*======^ END SUB MAIN ^======
    }
    PROCESS {
        foreach ($Mod in $Modules){
            #[version]$RequiredVersion = $null ; 
            $Procd++ ; 
            $sBnrS="`n#*------v ($($Procd)/$($ttl)):`$Mod:$($Mod) v------" ; 
            $smsg= "$($sBnrS)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            TRY{
                [version]$ModRequiredVersion = $null ; 
                if($Mod.contains(';')){
                    $smsg = "`$Mod:$($Mod) contains semi-colon (;) delimter: splitting into 'Name';'ModRequiredVersion' specifications" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    #[string]$mname,[version]$ModRequiredVersion = $mod.split(';') ;
                    [string]$mname,[version]$ModRequiredVersion = $mod.split(';') ;
                     $smsg =  "`$Mod:$($mname) : `$ModRequiredVersion:$($ModRequiredVersion)" ; 
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    $Mod = $mname ; 
                } ; 
                if(-not $ModRequiredVersion -AND $RequiredVersion){
                    $ModRequiredVersion = $RequiredVersion
                } ; 
                #$UpdateToLatest
                #$UpdateMinDaysOld
                # refresh splat every pass - don't want prior pass resolved repo to recycle
                $pltIsModule=[ordered]@{
                    Name=$Mod; 
                    Scope=$scope ;
                    AllowClobber = $true;
                    Force =  $true;
                    ErrorAction="Stop" ; 
                    Verbose = $true ; 
                    whatif=$($whatif) ;  
                } ; 
                if($ModRequiredVersion){
                    $smsg = "(adding `$pltIsModule.'RequiredVersion',$($ModRequiredVersion))" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    $pltIsModule.add('RequiredVersion',$ModRequiredVersion) ; 
                } ; 
                #if($Repository -AND $Repository -ne 'PSGallery'){
                if($Repository){
                    $smsg = "(adding `$pltIsModule.'Repository',$($Repository))" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    $pltIsModule.add('Repository',$Repository) ; 
                } ; 
                $smsg = "($($Mod):gmo -list...)" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 

                $GMOm=get-module -name $Mod -listavailable -ea 0 | sort version ; 

                $smsg = "($($Mod):get-installedmodule...)" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } 

                $GIMO=get-installedmodule -name $Mod  -ea 0 | sort version ;

                if($UpdateToLatest -OR (-not $GMOm -AND -not $GIMO)){
                    # prestock Find-Module
                    # example: case to defer to my local over PSG copy: Stats module is at psg & localrepo, prioritze multi-hits
                    # course, my version is improved: I converted broken .md help to CBH, added example to use get-histogram etc, so defer to mine.
                    $smsg = "(find-module -name $($Mod))" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    if($FMOm=find-module -name $Mod -ea STOP){
                        #PublishedDate
                        #if( $FMOm |?{ (new-timespan -Start (get-date $_.PublishedDate) -END (get-date ) ).days -lt $UpdateMinDaysOld} ){
                        if( $FMOm  | ?{$_.publisheddate -ge (get-date ).adddays(-1 * $UpdateMinDaysOld)} ){
                            $smsg = "find-module -name $($Mod) _most recent_ released version is LESS THAN `$UpdateMinDaysOld $($UpdateMinDaysOld) DAYS OLD!" ; 
                            $SMSG += "`nRe-querying with -ALLVERSIONS to find the _next oldest rev_, as ellegible for update..." ; 
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                            if($FMOm=find-module -name $Mod -AllVersions -ea STOP | sort version){
                                $FMOm = $FMOm |?{$_.publisheddate -lt (get-date ).adddays(-1 * $UpdateMinDaysOld)} | 
                                    select -last 1 ; 
                            } ; 
                        } 
                        if(($FMOm|measure).count -gt 1){
                            $smsg= "Multiple matches returned!:`n$(($FMOm|fl $propsFindModV |out-string).trim())" ; 
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            if($lmod = $FMOm|?{$_.repository -eq $localpsRepo}){
                                $smsg = "LocalRepo mod found, deferring to local:$($localPsRepo) copy" ; 
                                $smsg += "`n$(($lmod| ft -a $propsFindMod |out-string).trim())" ; 
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                if($pltIsModule.keys -contains 'Repository'){
                                    $pltIsModule.Repository = $localpsRepo ; 
                                }else{
                                    $pltIsModule.add('Repository',$localpsRepo) ; 
                                } ; 
                                $FMOm = $lmod ; 
                            } else { 
                                $smsg = "Multiple available published modules, unable to determine which to install." ;
                                $smsg += "`nPlease rerun with -Repository set to the proper registered repo name." ; 
                                #$smsg += "`nFound modules:`n$(($FMOm| ft -a $propsFindMod |out-string).trim())" ; 
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                Break ; 
                            } ; 
                        } ;                         
                    }
                } ; 

                if(-not $ModRequiredVersion -AND $UpdateToLatest){
                    $ModRequiredVersion = $FMOm.version ; 
                } ; 
                if(-not $GMOm -AND -not $GIMO){
                    if($FMOm){
                        if(-not $ModRequiredVersion){
                            $ModRequiredVersion = $FMOm.version ; 
                        } ; 
                        if($pltIsModule.keys -contains 'RequiredVersion'){
                            $pltIsModule.RequiredVersion = $ModRequiredVersion ; 
                        }else{
                            $pltIsModule.add('RequiredVersion',$ModRequiredVersion) ; 
                        } ; 

                        $smsg= "INSTALLING MATCH:`n$(($FMOm| fl $propsFindModV |out-string).trim())" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        $pltIsModule.name = $FMOm.name ; 
                        $smsg= "install-module w`n$(($pltIsModule|out-string).trim())" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        
                        _install-ThisModule @pltIsModule ; 

                    } else {
                        $smsg= "$($Mod):;NOT-FOUND W FIND-MODULE!" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ; 

                } else { 
                    # local install present
                    $latestLocalRev = $null ; 
                    if([version]($GMOm.version | select -last 1)  -ge [version]($GIMO.version | select -last 1)){
                        $smsg= "$($Mod):LOCALLY INSTALLED (get-module)`n$(($GMOm| ft -a  $prpGMom | out-string).trim())" ; 
                        $latestLocalRev = $GMOm | sort version | select -last 1 ; 
                    }else {
                        #($GIMO.version -gt $GMOm){
                        $smsg= "$($Mod):LOCALLY INSTALLED (get-installedModule)`n$(($GIMO| ft -a  $prpGIMo | out-string).trim())" ; 
                        $latestLocalRev = $GIMO | select -last 1 ; 
                    } ;
                    $smsg= "$($Mod):`$latestLocalRev`n$(($latestLocalRev| ft -a  $prpGMom | out-string).trim())" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

                    if($GMOm.count -gt 1){
                        $smsg = "get-module -name $($Mod) -listavailable" ; 
                        $smsg += "`nRETURNED MULTIPLE INSTALLED VERSIONS!" ; 
                        $SMSG += "`n$(($GMOm| ft -a  $prpGMom | out-string).trim())" ; 
                        $smsg += "`nObsolete Version Removal syntax (unexecuted):" ; 
                        
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 

                        # build example removal syntax for all but highest installed rev
                        if($AllObsoVersions = get-module -Name $pltIsModule.name -ListAvailable | sort Version -Descending | select -skip 1){
                            foreach($ObsoVers in $AllObsoVersions){
                                $smsg = "`nSyntax for lesser Version Removal:" ; 
                                $smsg += "`n`nUninstall-Module -name $($ObsoVers.Name) -force -RequiredVersion $($ObsoVers.version)`n" ; 
                                $smsg += "`n(may be obstructed by concurrent locks in other sessions - could require a reboot, and fresh attempt post)" ; 
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ; 
                        } ; 
                    } ; 

                    if([version]$latestLocalRev.version -lt [version]$ModRequiredVersion){
                        
                        $smsg = "$($latestLocalRev.Name) installed version: $($latestLocalRev.version) -lt $($ModRequiredVersion)" ;
                        $smsg = "`nDO YOU WANT TO UPGRADE $($latestLocalRev.version) TO $($ModRequiredVersion)?" ;
                        write-host -foregroundcolor YELLOW "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
                        $bRet=Read-Host "Enter YYY to continue. Anything else will SKIP"  ;
                        if ($bRet.ToUpper() -eq "YYY") {
                            $smsg = "(UPGRADING:$($latestLocalRev.Name))" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success

                            # B-transplant
                            $smsg = "get-module -Name $($latestLocalRev.Name) -ea 0 | remove-module -Force" ; 
                            if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                            get-module -Name $latestLocalRev.Name -ea 0 | remove-module -Force ; 

                            $smsg = "Install-Module w`n$(($pltIsModule|out-string).trim())" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

                            _install-ThisModule @pltIsModule ; 

                        } else {
                             $smsg = "Invalid response. SKIPPING" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN }
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #exit 1
                            break ;
                        }  ;
                    }elseif([version]$latestLocalRev.version -eq [version]$ModRequiredVersion){
                        $smsg = "$($Mod) CONFIRMED installed locally, and *matches* ModRequiredVersion:$($ModRequiredVersion)" ; 
                        $smsg += "`n(CONFIRMED: no upgrade necessary)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } elseif( -not $ModRequiredVersion){
                        $smsg = "$($latestLocalRev.Name) v$($latestLocalRev.version) is -ge v$($ModRequiredVersion)" ; 
                        $smsg += "`n(CONFIRMED: no upgrade necessary)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } else {
                        $smsg = "$($Mod) CONFIRMED installed locally. (No (Mod)RequiredVersion specified; Version is already compliant, or no version checks performed)" ; 
                        $smsg += "`n(CONFIRMED: no upgrade necessary)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ; 

                } ; 
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            } ;
            $smsg= "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        }  # loop-E
    } # PROC-E
    END{
        write-verbose  "$((get-date).ToString('HH:mm:ss')):$($sBnr.replace('=v','=^').replace('v=','^='))" ;
    } ; 
} ; 
#*------^ Install-ModulesTDO ^------
