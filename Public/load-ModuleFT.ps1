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
