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
} ; 
#*------^ uninstall-ModulesObsolete.ps1 ^------
