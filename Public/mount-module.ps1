#*------v Function mount-Module v------
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
            import-module -name $Name -RequiredVersion $lVers.Version.tostring() -force -DisableNameChecking   
        } catch {
            write-warning "*BROKEN INSTALLED MODULE*:$($Name)!" ;
            #import-module -name $tModDFile -force -DisableNameChecking   ;
            if(!$NoBackup -AND (gcm load-ModuleFT)){
                load-ModuleFT -tModName $tModName -tModFile $tModFile -tModCmdlet $tModCmdlet ; 
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
                import-module -name $Name -force -ErrorAction Stop;
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
#*------^ END Function mount-Module ^------