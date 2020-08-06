# verb-mods.psm1


  <#
  .SYNOPSIS
  verb-Mods - Generic module-related functions
  .NOTES
  Version     : 1.0.5.0
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
}

#*------^ uninstall-ModulesObsolete.ps1 ^------

#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function check-ReqMods,Disconnect-PssBroken,load-Module,load-ModuleFT,uninstall-ModulesObsolete -Alias *


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBJWw/3l5pRPLpCnWRHt4/b3K
# DPygggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTvB+eN
# 1I2FqJYDoD7ysv84BS+ltzANBgkqhkiG9w0BAQEFAASBgBzoMJBw7c5yPFpryWE6
# XDwHax2kGoUFeFtlpwy7TzNIGRMJ4bTvjtMeXIv0Pl84/YE1qgsqdzStkdTc1GUE
# f3QGAmgBnqrTjN9gVgUi338jpUnlA+b4WyMEJrAV6wLtad51YUcdrRUGr00JRmC/
# SWvo3bTCAmv8DnCzYJPekuFc
# SIG # End signature block
