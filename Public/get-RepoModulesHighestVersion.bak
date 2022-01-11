#*------v Function get-RepoModulesHighestVersion v------
function get-RepoModulesHighestVersion {
    <#
    .SYNOPSIS
    get-RepoModulesHighestVersion.ps1 - Check specified Repository (defaults to $global:localPsRepo) for highest .nupkg verison for each of module directories specified by -Paths.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-11-03
    FileName    : get-RepoModulesHighestVersion.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-mods
    Tags        : Powershell,Module,Maintenance,Repository
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 2:02 PM 11/3/2021 init, flipped to verb-mods func
    .DESCRIPTION
    get-RepoModulesHighestVersion.ps1 - Check specified Repository (defaults to $global:localPsRepo) for highest .nupkg verison for each of module directories specified by -Paths.
    Calculates and sorts on _actual_ semantic version (rather than strict n.n.n text), to determine highest/latest revision. 
    .PARAMETER Paths
    Module source paths to be processed[-paths 'c:\path-to\','c:\path2-to']
    .PARAMETER OutObject
    Switch to return a summarizing object to the pipeline (defaults true)[-OutObject `$false]
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)
    .EXAMPLE
    PS> $Paths += (resolve-path c:\sc\verb*) ;
    PS> get-RepoModulesHighestVersion -Paths $Paths -verbose ; 
    Run a pass against all paths below the c:\sc\ directory, with directory names starting with verb*, with verbose output.
    .EXAMPLE
    PS> $latestRevs = (resolve-path c:\sc\verb*) | get-RepoModulesHighestVersion ; 
    PS> $latestRevs |ft -a name,lastwritetime,version ; 
    Pipeline example, process list of dirs matching pattern c:\sc\verb*, for highest .nupkg revision in the default local repository, and assign summary object to $latestRevs, then output a summary of the returned object.
    .LINK
    https://github.com/tostka/verb-Mods
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("(lyn|bcc|spb|adl)ms6(4|5)(0|1).(china|global)\.ad\.toro\.com")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Module source paths to be processed[-paths 'c:\path-to\','c:\path2-to']")]
        [ValidateScript({Test-Path $_})]
        [string[]]$Paths,
        [Parameter(HelpMessage="Repository (defaults to `$global:localPsRepo)[-Repository 'somerepo']")]
        [string]$Repository=$localPsRepo,
        [Parameter(HelpMessage="Switch to return a summarizing object to the pipeline (defaults true)[-OutObject `$false]")]
        [switch] $OutObject=$true
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ;
        $rgxNuPkgFileName = '.*\.(\d+\.\d+\.\d+)\.nupkg$' ; 
        $repoDirs=$allPkgs=@() ; 
        $RepoSrc = (Get-PSRepository -name $Repository).SourceLocation ; 
        $allPkgs=@() ; 
    } ; 
    PROCESS{
        $procd=0 ; $ttl = ($Paths|measure).count ; 
        foreach ($path in $Paths){
            $procd++ ; 
            TRY {
                $error.clear() ;
                write-host "(processing:$($path)...)" ; 
                $pltGci=[ordered]@{path ="$($reposrc)\$(split-path $path -leaf)*.nupkg" ; ea = 'STOP'} ;
                write-verbose "`nget-childitem w`n$(($pltGci|out-string).trim())" ; 
                $pkgs = gci @pltGci ; 
                $pkgs = $pkgs | select *,@{name="version";expression={[version]([regex]::match($_.name,'.*\.(\d+\.\d+\.\d+)\.nupkg$').captures[0].groups[1].value)}} | sort version ;
                if($pkgs){
                    if($pkgs -is [system.array]){$allPkgs += $pkgs[-1]}
                    else {$allPkgs += $pkgs} ; 
                    write-verbose "`n$(($allPkgs[-1]|ft -a name,lastwritetime,version|out-string).trim())" ; 

                } ; 
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Break  #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
            } ; 
        } ; 
    }  # PROC-E
    END {
        if(-not($outObject)){
            $smsg = "`n$(($allpkgs|ft -a name,lastwritetime,version|out-string).trim())" ; 
            write-host $smsg ; 
        } else { 
          $allpkgs | write-output ; 
        } ; 
    } ;
} ; 
#*------^ END Function get-RepoModulesHighestVersion ^------
