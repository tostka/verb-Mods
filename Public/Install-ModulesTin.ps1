#*------v Install-ModulesTDO v------
function Install-ModulesTDO {
    <#
    .SYNOPSIS
    Install-ModulesTDO - Loops a list of PowershellGallery modules, checks for gmo -list, and get-installedmodule, and if neither, finds & installs current rev from PsG.
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2018-03-24
    FileName    : Install-ModulesTDO.ps1
    License     : MIT
    Copyright   : (c) 4/7/2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Module,Lifecycle
    AddedCredit : 
    AddedWebsite: 
    AddedTwitter: 
    REVISIONS
    * 1:46 PM 12/27/2024 appears an obsolete dupe of install-modulesTDO.ps1, git it, and delete
    * 4:26 PM 10/30/2024 retooled for to support inbound ModuleName;REquiredVersion -Module spec; 
        added more extensive testing, split out the get-installedmodule & gmo -list tests into separate steps, then checked which had latest rev, 
        and used that as the standard for curr latest rev (frequently installedmodule is behind gmo -list).
        Ren'd install-ModulesTin -> Install-ModulesTDO, and aliased old name (and added alias: Confirm-ModuleDependancy, for use to test/autoupgrade dep status modules in other scripts)
    * 1:24 PM 10/6/2021 code local-repo pref for find-module returning multi matches (generally PSGallery & a local repo, with a fork etc on local - assumes the local is tuned/updated for our specific needs)
    * 2:22 PM 10/5/2021 ported from install-WorkstationModules.ps1 to verb-mods (6/2/21 vers)
    .DESCRIPTION
    Install-ModulesTDO - Loops a list of PowershellGallery modules, checks for gmo -list, and get-installedmodule, and if neither, finds & installs current rev from PsG.
    .PARAMETER Modules
    Array of PSGallery Modules to Install[-modules 'mod1','mod2']
    .PARAMETER Scope
    Scope to be targeted (AllUsers|CurrentUser, default: no filtering)[-Scope AllUsers]
    .PARAMETER whatIf
    Whatif Flag  [-whatIf]
    .EXAMPLE
    $psdeskmods ="Pester","PSScriptAnalyzer" ; 
    $bRet = Install-ModulesTDO -Modules $psdeskmods -scope CurrentUser -showdebug:$($showdebug) -whatif:$($whatif) ; 
    .LINK
    https://github.com/tostka
    #>
    #Requires -Modules verb-Auth
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
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
            [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
            [switch] $whatIf
    ) ;
    BEGIN {
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        $verbose = $($VerbosePreference -eq "Continue")
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

        $ttl=($Modules|measure).count ; 
        $Procd=0 ; 
        $smsg= "Confirming $(($Modules|measure).count) PS Modules:" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    }
    PROCESS {
        foreach ($Mod in $Modules){
            [version]$RequiredVersion = $null ; 
            $Procd++ ; 
            $sBnrS="`n#*------v ($($Procd)/$($ttl)):`$Mod:$($Mod) v------" ; 
            $smsg= "$($sBnrS)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            TRY{
                if($Mod.contains(';')){
                    $smsg = "`$Mod:$($Mod) contains semi-colon (;) delimter: splitting into 'Name';'RequiredVersion' specifications" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    [string]$mname,[version]$RequiredVersion = $mod.split(';') ;
                     $smsg =  "`$Mod:$($mname) : `$RequiredVersion:$($RequiredVersion)" ; 
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    $Mod = $mname ; 
                } ; 
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
                if($RequiredVersion){
                    $smsg = "(adding `$pltIsModule.'RequiredVersion',$($RequiredVersion))" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    $pltIsModule.add('RequiredVersion',$RequiredVersion) ; 
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

                $GMOm=get-module -name $Mod -listavailable -ea 0 ; 

                $smsg = "($($Mod):get-installedmodule...)" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } 

                $GIMO=get-installedmodule -name $Mod  -ea 0 ;

                if(-not $GMOm -AND -not $GIMO){
                    $smsg = "==FIND-MODULE:$($Mod):" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    $error.clear() ;
                    $smsg = "(find-module -name $($Mod))" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    if($FMOm=find-module -name $Mod -ea 0  ){
                        # stats is at psg & localrepo, prioritze multi-hits
                        # course, my version is improved: I converted broken .md help to CBH, added example to use get-histogram etc, so defer to mine.
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
                        $smsg= "INSTALLING MATCH:`n$(($FMOm| fl $propsFindModV |out-string).trim())" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        $pltIsModule.name = $FMOm.name ; 
                        $smsg= "install-module w`n$(($pltIsModule|out-string).trim())" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        TRY { 
                            install-module @pltIsModule ; 
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
                    #[version] # flip to full object
                    $latestLocalRev = $null ; 
                    if([version]$GMOm.version -gt [version]$GIMO.version){
                        $smsg= "$($Mod):LOCALLY INSTALLED (get-module)`n$(($GMOm| FORMAT-TABLE -AUTO $prpGMom | out-string).trim())" ; 
                        $latestLocalRev = $GMOm ; 
                    }else {
                        #($GIMO.version -gt $GMOm){
                        $smsg= "$($Mod):LOCALLY INSTALLED (get-installedModule)`n$(($GIMO| FORMAT-TABLE -AUTO $prpGIMo | out-string).trim())" ; 
                        $latestLocalRev = $GIMO ; 
                    } 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

                    if([version]$latestLocalRev.version -lt [version]$RequiredVersion){
                        
                        $smsg = "$($latestLocalRev.Name) installed version: $($latestLocalRev.version) -lt $($RequiredVersion)" ;
                        $smsg = "`nDO YOU WANT TO UPGRADE $($latestLocalRev.version) TO $($RequiredVersion)?" ;
                        write-host -foregroundcolor YELLOW "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
                        $bRet=Read-Host "Enter YYY to continue. Anything else will SKIP"  ;
                        if ($bRet.ToUpper() -eq "YYY") {
                            $smsg = "(UPGRADING:$($latestLocalRev.Name))" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success

                            $smsg = "get-module -Name $($latestLocalRev.Name) -ea 0 | remove-module -Force" ; 
                            if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                            get-module -Name $latestLocalRev.Name -ea 0 | remove-module -Force ; 

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
                                $smsg = "Missing upgraded version: $($RequiredVersion)! (skipping prior $($latestLocalRev.name): $($latestLocalRev.version) uninstall" ; 
                                write-warning $smsg ; 
                                throw $smsg ; 
                            } ; 
                        } else {
                             $smsg = "Invalid response. SKIPPING" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN }
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #exit 1
                            break ;
                        }  ;
                    } else {
                        $smsg = "$($latestLocalRev.Name) v$($latestLocalRev.version) is -ge v$($RequiredVersion)" ; 
                        $smsg += "`n(CONFIRMED: no upgrade necessary)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ; 

                } ; 
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
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
