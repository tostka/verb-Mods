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
    License     : (none asserted)
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Module,Lifecycle
    AddedCredit : Jack Fruh
    AddedWebsite: http://sharepointjack.com/2017/powershell-script-to-remove-duplicate-old-modules/
    AddedTwitter: @sharepointjack / http://twitter.com/sharepointjack	
    REVISIONS
    * 1:03 PM 8/5/2020, rewrote & expanded concept as func, added to verb-Mods
    * 11:25 AM 3/24/2018 posted/updated vers
    .DESCRIPTION
    uninstall-ModulesObsolete - Remove old versions of Powershell modules, leaving most current - does note that later revs are published & available)
    Extension of version posted at Jack Fruh's blog.
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
    [CmdletBinding()] 
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Specific Module(s) to be processed[-Modules array-of-module-descrptors]")]
        [Alias('Name')]$Modules,
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Source Repository, for which *all* associated local installed modules should be processed[-Repository 'repo1','repo2']")]
        [array]$Repository,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch]$whatIf
    ) ;
    BEGIN {$verbose = ($VerbosePreference -eq "Continue") } ;
    PROCESS {
        if(!$Modules){
            $smsg = "Gathering all installed modules..." ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $tModules = get-installedmodule ;
            if($Repository){
                $tModules = $tModules|?{$_.Repository -ne $Repository} ; 
            } ; 
        } else { 
            $smsg = "$(($Modules|measure).count) specific Modules specified`n$(($Modules|out-string).trim())" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $tModules = ($modules | %{get-installedmodule $_ | write-output } ) ;
            if($Repository){
                $tModules = $tModules|?{$_.Repository -eq $Repository} ; 
            } ; 
        } ; 
        $ttl=($tModules|Measure-Object).count ;
        $Procd=0 ; 
        $smsg = "($(($tModules|measure).count) modules returned)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

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
                $smsg="(Only a single versions found $($Module.name), skipping)" ;
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
} ; 
#*------^ uninstall-ModulesObsolete.ps1 ^------