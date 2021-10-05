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
    #Requires -Version 3
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
                $smsg= "INSTALLING MATCH:`n$(($rmod|fl name,type,version,description|out-string).trim())" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                $pltInstMod.name = $rmod.name ; 
                $smsg= "install-module w`n$(($pltInstMod|out-string).trim())" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                TRY { 
                    install-module @pltInstMod ; 
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
                $error.clear() ;

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
} ; 
#*------^ Install-ModulesTin.ps1 ^------