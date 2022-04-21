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
    * 4:21 PM 4/21/2022 add: PSv2, PsGet module, backrev support: added -names param (to drive name lookup) ; added code to detec if -Repository is a uncpath (vs repo name), and that drives skip on psv2-missing get-psrepository call, and just sets the specified path as the $RepoSrc for scanning for updated nupkg files, agains the specified Names module name values; Add: test-isUNCPath () ; PSv2-compatible PSGet:install-module supporting approach:  as PsV2 lacks PowershellGet support, this specifies the PSRepository.SourceLocation property as the -Repository input.  The script then skips the normal get-PSRepository resolution, and uses the specified UNC path, and the -Names (array of module names), to target variant revisions on the Repository.
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
    .EXAMPLE
    PS> $latestRevs = get-RepoModulesHighestVersion -Names verb-IO -Repository "\\lynmsv10\lync_fs\scripts\sc" -verbose ;
    PS> $latestRevs |ft -a name,lastwritetime,version ;
    PS> install-Module -ModulePath $lvers.fullname -Global
    PSv2-compatible PSGet:install-module supporting approach:
    - as PsV2 lacks PowershellGet support, this specifies the PSRepository.SourceLocation property as the -Repository input.
    - The script then skips the normal get-PSRepository resolution, and uses the specified UNC path, and the -Names (array of module names), to target variant revisions on the Repository.
    - The resulting highest semantic-version is returned and assigned to the $latestRevs variable, which is summarized in an echo back to console.
    - Finally the $latestRev version fullname is used with the PsGet install-module command, under the -ModulePath, to install the latest version locally on a Psv2 machine.
    .LINK
    https://github.com/tostka/verb-Mods
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    [CmdletBinding(DefaultParameterSetName='Paths')]
    PARAM(
        [Parameter(ParameterSetName='Paths',Position=0,Mandatory=$false,ValueFromPipeline=$true,HelpMessage="Module source paths to be processed[-paths 'c:\path-to\','c:\path2-to']")]
        [ValidateScript({Test-Path $_})]
        [string[]]$Paths,
        [Parameter(ParameterSetName='Names',Position=0,Mandatory=$false,ValueFromPipeline=$true,HelpMessage="Array of Module names to be searched on the specified Repository[-paths 'c:\path-to\','c:\path2-to']")]
        [string[]]$Names,
        [Parameter(HelpMessage="Repository (defaults to `$global:localPsRepo). Can also be set to the UNC path to a Repository.SourceLocation path (for use with PsGet, which lacks PSRepository support)[-Repository 'somerepo']")]
        [string]$Repository=$localPsRepo,
        [Parameter(HelpMessage="Switch to return a summarizing object to the pipeline (defaults true)[-OutObject `$false]")]
        [switch] $OutObject=$true
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ;
        $rgxNuPkgFileNames = '.*\.(\d+\.\d+\.\d+)\.nupkg$' ;
        $repoDirs=$allPkgs=@() ;
        if($Paths -AND $Names){
            throw "-Paths and -Names both specified. Please use one or the other!" ;
            break ;
        } ;
        #*======v FUNCTIONS v======
        if(-not (gcm test-isUNCPath -ea 0)){
            #*------v Function test-IsUncPath v------
            function test-IsUncPath {
                [OutputType('bool')]
                [CmdletBinding()]
                PARAM(
                    [Parameter(Mandatory,Position=0,ValueFromPipeline=$true)]
                    [ValidateNotNullOrEmpty()]
                    [string]$Path
                ) ;
                PROCESS {
                    $Error.Clear() ;
                    foreach($item in $path) {
                        $PathInfo=[System.Uri]$item ;
                        if($PathInfo.IsUnc){
                            $true | write-output ;
                        } else {
                            $false | write-output ;
                        } ;
                    } ;
                } ;
            } ;
            #*------^ END Function test-IsUncPath ^------
        } ;
        #*======^ END FUNCTIONS ^======

        # make it flip a UNC path in the $Repository value, into assumption it's the $SourceLocation of the repository (doesn't use get-psrepository to resolve path, just uses it as passed in).
        if( (test-IsUncPath -path $Repository) -AND (test-path $Repository) ){
            $smsg = '-Repository detected to contain a UNC path spec:' ;
            $smsg += "`nflipping specified Repository into the $RepoSsrc specification" ;
            write-verbose $smsg ;
            $RepoSrc = $Repository ;
        } else {
            if( -not (get-module -name PowershellGet)){
                $smsg = "Missing Required module PowershellGet!" ;
                if($host.version.major -lt 3){
                    $smsg += "`nPSv2 lacks PowershellGet support" ;
                    $smsg += "`nspecify the PSRepository.SourceLocation value, for the -Repository parameter"
                    $smsg += "`nto work around the gap."
                    $smsg += "`nThen use PSGet's install-module -ModulePath [uncpathto.nupkg] -Global"
                    $smsg += "`nto install the found highest rev, to the 'Global'/System profile - as Psv2 lacks an AllUsers profile"
                } ;
            } else {
                $RepoSrc = (Get-PSRepository -name $Repository).SourceLocation ;
            } ;
        } ;
        $allPkgs=@() ;
    } ;
    PROCESS{
        $procd=0 ;
        $srchtargets = @() ;
        if($Names){
            $ttl = ($Names | measure).count ;
            foreach ($name in $Names){
                $procd++ ;
                #$srchtargets += "$($reposrc)\$($Name)*.nupkg"
                $srchtargets += join-path -path $reposrc -childpath "$($Name)*.nupkg"
            } ;
        } elseif ($Paths){
            $ttl = ($Paths|measure).count ;
            $procd++ ;
            foreach ($path in $Paths){
                #$srchtargets += "$($reposrc)\$(split-path $path -leaf)*.nupkg"
                $srchtargets += join-path -path $reposrc -childpath "$(split-path $path -leaf)*.nupkg"
            } ;
        } ;
        foreach ($path in $srchtargets){
            $procd++ ;
            TRY {
                $error.clear() ;
                write-host "(processing:$($path)...)" ;
                #$pltGci=[ordered]@{path ="$($reposrc)\$(split-path $path -leaf)*.nupkg" ; ea = 'STOP'} ;
                $pltGci=[ordered]@{path = $path ; ea = 'STOP'} ;
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
