#*------v Function revert-moduleInstalledRevision v------
function revert-moduleInstalledRevision {
    <#
    .SYNOPSIS
    revert-moduleInstalledRevision.ps1 - Rollback broken Module version to either explictly specified -RequiredVersion, or most recent prior date version (eg, prior to midnight today). 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-25
    FileName    : revert-moduleInstalledRevision.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-mod
    Tags        : Powershell,Module,Maintenance
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 12:57 PM 11/3/2021 correction: I'd shifted it below to verb-mods.
    * 1:42 PM 10/25/2021 init, flipped to verb-dev func
    .DESCRIPTION
    revert-moduleInstalledRevision.ps1 - Rollback broken Module version to either explictly specified -RequiredVersion, or most recent prior date version (eg, prior to midnight today). 
    This relies on a populated profile/global $localPsRepo value, which should contain the name of the local repository.
    Note: This runs...
    uninstall-module -name xxx -AllVersions -force
    ... to COMPLETELY CLEAR any prior revisions. 
    And then runs an install of the required version. With #requires or other depenedancies, this could require manual installs of interrum missing modules (or twinning code into the installed version, from future revisions). 

    If -RequiredVersion is unspecified, the target rev is calculated as follows:
    1. It determines most-recent prior-date rev by pulling all [modulename]*.nupkg files from the repo's SourceLocation, sorted on LastWriteTime 
        (less accurate, but a lot simpler than select-object expressioning out real sorted semvers from the nupkg name string)
    2. It then filters out all pkgs from the current day (post-midnight), and regex matches out most recent prior version's N.N.N version string, to populate the `$RequiredVersion value. 
    .PARAMETER Name
    [string] Module Name[-Name modulename]
    .PARAMETER RequiredVersion
    [version] Required revision to revert-to (semantic version n.n.n string)[-RequiredVersion 1.2.3]
    .PARAMETER Repository
    [string]Repository to be installed from (defaults to value stored as `$global:localPsRepo)[-Repository SomeRepo]
    .PARAMETER Whatif
    [switch]Parameter to run a Test no-change pass [-Whatif]
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)
    .EXAMPLE
    PS> revert-moduleInstalledRevision -name some-module -requiredversion 1.0.2 -whatif -verbose ;
    Roll back specified module to specified requiredversion, whatif no-exec pass, and verbose.
    .EXAMPLE
    PS> revert-moduleInstalledRevision -name Some-Module ;
    Roll back specified module to calulated most recent date revision on local Repository
    .LINK
    https://github.com/tostka/verb-XXX
    .LINK
    [ name related topic(one keyword per topic), or http://|https:// to help, or add the name of 'paired' funcs in the same niche (enable/disable-xxx)]
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("(lyn|bcc|spb|adl)ms6(4|5)(0|1).(china|global)\.ad\.toro\.com")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    ## [OutputType('bool')] # optional specified output type
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Module Name[-Name modulename]")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Position=1,HelpMessage="[version]Required revision to revert-to (Semantic Version string)[-RequiredVersion]")]
        [version] $RequiredVersion,
        [Parameter(HelpMessage="[string]Repository to be installed from (defaults to `$global:localPsRepo/profile value) Name[-Repository SomeRepo]")]
        [string]$Repository=$localPsRepo,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    $verbose = ($VerbosePreference -eq "Continue") ;
    TRY {
        $error.clear() ;
        if(!$RequiredVersion){
            $pltGrpo=[ordered]@{name = $localpsrepo ; ErrorAction='STOP'} ;
            $pltGCI=[ordered]@{path="$((get-psrepository @pltGrpo).SourceLocation)\$($Name)*.nupkg" ; ErrorAction='STOP'} ;
            write-host "(retrieving most recent prior-day's revision in Repo for $($Name)...)" ; 
            write-verbose "get-psrepository w`n$(($pltGrpo|out-string).trim())" ; 
            write-verbose "gci w`n$(($pltGCI|out-string).trim())" ;             
            $Allvers = gci @pltGCI | sort lastwriteTime ; 
            $RequiredVersion = [regex]::match(($allvers | ?{$_.LastWriteTime -lt (([datetime]::Today))}| sort lastwritetime | select -last 1 ).name,'(\d+\.\d+\.\d+)\.nupkg$').captures[0].groups[1].value ; 
            $sRequiredVersion = $RequiredVersion.major,$RequiredVersion.minor,$RequiredVersion.build -join '.'
        } ; 
        if($RequiredVersion){
            $pltRMod=[ordered]@{name = $Name  ; force=$true ; ErrorAction='Continue'; } ;
            write-host "(removing current in-memory module copy)" ; 
            write-verbose "remove-module w`n$(($pltRMod|out-string).trim())" ; 
            remove-module @pltRMod ; 

            write-host "(uninstalling all versions of $Name...)" ; 
            $pltGrpo=[ordered]@{name = $Name  ; force=$true ; AllVersions= $true ;ErrorAction='Continue'; whatif=$($whatif)} ;
            write-verbose "uninstall-module w`n$(($pltGrpo|out-string).trim())" ; 
            uninstall-module @pltGrpo ; 

            $pltIMod=[ordered]@{name = $Name  ; RequiredVersion = $sRequiredVersion ; Repository = $Repository ; force=$true ; AllowClobber= $true ;ErrorAction='STOP';whatif=$($whatif);} ;
            write-host "Install-Module w`n$(($pltIMod|out-string).trim())" ; 
            Install-Module @pltIMod ; 

            write-host "(importing updated $Name...)" ; 
            $pltIpMo=[ordered]@{name = $Name  ; force=$true ; ErrorAction='Stop'; } ;
            write-verbose "import-module w`n$(($pltIpMo|out-string).trim())" ; 
            import-module @pltIpMo ; 
        } else {
            write-warning "Unable to locate a prior date Rev`nother pkgs avail (rerun with -`$RequiredVersion populated):`n$(($Allvers|out-string).trim())" ; 
            throw "`$RequiredVersion is unspecified and unable to locate most-recent prior date's version!" ;
        }; 
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
        write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        Break ;
    } ; 
} ; 
#*------^ END Function revert-moduleInstalledRevision ^------