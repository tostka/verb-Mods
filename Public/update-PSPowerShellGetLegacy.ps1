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
} ; 
#*------^ update-PSPowerShellGetLegacy.ps1 ^------
