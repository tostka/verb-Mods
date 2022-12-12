#*------v get-ModuleRecentPublishedRevisions.ps1 v------
function get-ModuleRecentPublishedRevisions {
    <#
    .SYNOPSIS
    get-ModuleRecentPublishedRevisions.ps1 - Get the most recent -Limit (5) PSRepostory-published .Nupkg revisions of the specified module.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2022-12-08
    FileName    : get-ModuleRecentPublishedRevisions.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-mod
    Tags        : Powershell,Module,Maintenance
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 10:33 AM 12/8/2022 init, flipped to verb-dev func
    .DESCRIPTION
    get-ModuleRecentPublishedRevisions.ps1 - get-ModuleRecentPublishedRevisions.ps1 - Get the most recent -Limit (5) PSRepostory-published .Nupkg revisions of the specified module.
    This relies on a populated profile/global $localPsRepo value, which should contain the name of the local repository.
    
    N.B. Should be able to rely on find-module to produce this info, but I find that gci'ing the PSRepository.Source path more consistently & quickly returns results (with a simple file share Repository). 
    
    .PARAMETER Name
    [string] Module Name[-Name modulename]
    .PARAMETER Repository
    [string]Repository to be installed from (defaults to value stored as `$global:localPsRepo)[-Repository SomeRepo]
    .PARAMETER Limit
    Number of recent revisions to return (defaults to 5)[-Limit 10]
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    PSObject of fullname & lastwritetime for the matched Repository nupkg objects
    .EXAMPLE
    PS> $whatif = $true ; 
    PS> $modname = 'verb-io' ; 
    PS> write-verbose "Get most recent published .nupkg file information for named module on local Repository & capture the output to a variable" ; 
    PS> $revs = get-ModuleRecentPublishedRevisions -name $modname ;
    PS> write-verbose "Output the most recent two revisionss information to console" ; 
    PS> $revs[-2..-1] | ft -a ; 
    PS> write-verbose "Regex the version # of the second-most-recent release" ; 
    PS> $ReqVers = [regex]::match($revs[-2].fullname,'(\d+\.\d+\.\d+)').captures[0].groups[1].value ;
    PS> write-verbose "Uninstall *allVersions* of the module locally" ; 
    PS> uninstall-module -name $modname -AllVersions -force -whatif:$($whatif) ; 
    PS> write-verbose "Install the 2nd-most-recent release to CurrentUser scope, with force/AllowClobber." ; 
    PS> install-module -name $modname -RequiredVersion $reqvers -Repository $localpsrepo -force -allowclobber -scope CurrentUser -whatif:$($whatif) ;
    PS> write-verbose "Delete the most recent published revision .nupkg file from the PSRepository.Source directory" ; 
    PS> gci -path $revs[-1].fullname | remove-item -whatif:$($whatif) ;
    
        (retrieving most recent 5 revisions in Repo for verb-io...)
        11:13:10:5 most recent lyncRepo-published revisions of verb-io:
        FullName                         LastWriteTime
        --------                         -------------
        \\REPO\SHARE\verb-IO.2.0.3.nupkg 5/23/2022 2:14:08 PM
        \\REPO\SHARE\verb-IO.3.0.0.nupkg 6/2/2022 11:02:33 AM
        \\REPO\SHARE\verb-IO.3.0.1.nupkg 7/21/2022 1:39:50 PM
        \\REPO\SHARE\verb-IO.3.1.0.nupkg 8/30/2022 5:00:05 PM
        \\REPO\SHARE\verb-IO.4.0.0.nupkg 9/8/2022 4:08:31 PM

        (returning object to pipeline)

        FullName                                          LastWriteTime
        --------                                          -------------
        \\REPO\SHARE\verb-IO.3.1.0.nupkg 8/30/2022 5:00:05 PM
        \\REPO\SHARE\verb-IO.4.0.0.nupkg 9/8/2022 4:08:31 PM

        What if: Performing the operation "Uninstall-Module" on target "Version '4.0.0' of module 'verb-IO'".
        What if: Performing the operation "Install-Module" on target "Version '3.1.0' of module 'verb-IO'".
        What if: Performing the operation "Remove File" on target "\\REPO\SHARE\verb-IO.4.0.0.nupkg".     
    
    Above demos remediating around a recent damaged revision, clearing all local versions, installing the prior revision from the PSRepo, and clearing the last revision .nupkg file from the PSRepo.
    .LINK
    https://github.com/tostka/verb-mods
    .LINK
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    ## [OutputType('bool')] # optional specified output type
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Module Name[-Name modulename]")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(HelpMessage="[string]Repository to be installed from (defaults to `$global:localPsRepo/profile value) Name[-Repository SomeRepo]")]
        [string]$Repository=$localPsRepo,
        [Parameter(HelpMessage="Number of recent revisions to return (defaults to 5)[-Limit 10]")]
        [int]$Limit = 5
    ) ;
    $verbose = ($VerbosePreference -eq "Continue") ;
    TRY {
        $error.clear() ;
        $pltGrpo=[ordered]@{name = $localpsrepo ; ErrorAction='STOP'} ;
        $pltGCI=[ordered]@{path="$((get-psrepository @pltGrpo).SourceLocation)\$($Name)*.nupkg" ; ErrorAction='STOP'} ;
        write-host "(retrieving most recent $($Limit) revisions in Repo for $($Name)...)" ;
        write-verbose "get-psrepository w`n$(($pltGrpo|out-string).trim())" ;
        write-verbose "gci w`n$(($pltGCI|out-string).trim())" ;
        $Allvers = gci @pltGCI | sort lastwriteTime ;
        $smsg = "$($Limit) most recent $($Repository)-published revisions of $($Name):`n$(($Allvers | select -last $Limit | ft -a fullname,lastwritetime|out-string).trim())" ; 
        $smsg += "`n`n(returning object to pipeline)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
        $Allvers | select -last $Limit | select fullname,lastwritetime | write-output ; 
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
        write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        Break ;
    } ;
} ; 
#*------^ get-ModuleRecentPublishedRevisions.ps1 ^------