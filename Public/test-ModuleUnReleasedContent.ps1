#*------v Function test-ModuleUnReleasedContent v------
function test-ModuleUnReleasedContent {
    <#
    .SYNOPSIS
    test-ModuleUnReleasedContent.ps1 - Check module source directory for component files dated after the most recent version .nupkg.LastWriteTime (e.g. output list of modules that need a fresh Build/Release)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-11-03
    FileName    : test-ModuleUnReleasedContent.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-mod
    Tags        : Powershell,Module,Maintenance
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 10:40 AM 2/3/2023 ren: test-UnReleasedModuleContent -> test-ModuleUnReleasedContent ; add: alias: test-ModuleBuild (hard to find/recall orig name, moudle should be in 2nd pos)
    * 8:59 AM 1/11/2022 added example 3, for quick CBH example dumps of targeted cmdlets in a known module.
    * 10:22 AM 12/2/2021 implment default use of $global:GIT_REPOSROOT, if present; flipped $paths, non-mandetory, and post test pre-run in the proceses block (make it run wo manual param's needed)
    * 1:12 PM 11/3/2021init, flipped to verb-mods func
    .DESCRIPTION
    test-ModuleUnReleasedContent.ps1 - Check module source directory for component files dated after the most recent version .nupkg.LastWriteTime (e.g. output list of modules that need a fresh Build/Release)
    ..PARAMETER Paths
    Module source paths to be processed (defaults to expanding my `$GIT_ReposRoot profile variable into array of module repos w names prefixed 'verbs*')[-paths 'c:\path-to\','c:\path2-to']
    .PARAMETER Repository
    [string]Repository to be checked against (defaults to value stored as `$global:localPsRepo)[-Repository SomeRepo]
    .PARAMETER rgxExcludeExts
    [regex]Files Extensions to be excluded from the comparison[-rgxExcludeExts '(.txt|.xml)']
    .PARAMETER rgxexclFiles
    [regex]File Names to be excluded from the comparison[-rgxexclFiles '(.*.logs)']
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)
    .EXAMPLE
    PS> $Paths += (resolve-path c:\sc\verb*) ;
    PS> test-ModuleUnReleasedContent -Paths $Paths -verbose ; 
    Run a pass against all paths below the c:\sc\ directory, with directory names starting with verb*, with verbose output.
    .EXAMPLE
    PS> (resolve-path c:\sc\verb*) |  test-ModuleUnReleasedContent;
    Pipeline example, echo solely modules that need a fresh Build/Release
    .EXAMPLE
    PS> gcm -module verb-mods | where verb -eq 'test' | %{get-help $_.name -example}
    Example locating an installed module, postfiltering the module cmdlets on verb 'test', and returning CBH examples for each cmdlet.
    .LINK
    https://github.com/tostka/verb-Mods
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    [CmdletBinding()]
    [Alias('test-UnReleasedModuleContent','test-ModuleBuild')]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,HelpMessage="Module source paths to be processed[-paths 'c:\path-to\','c:\path2-to']")]
        #[ValidateScript({Test-Path $_})]
        [string[]]$Paths=(resolve-path (join-path -path $GIT_REPOSROOT -childpath "verb*")),
        [Parameter(HelpMessage="[regex]Files Extensions to be excluded from the comparison[-rgxExcludeExts '(.txt|.xml)']")]
        [regex]$rgxExcludeExts = '(\.nupkg|\.gitignore|\.*_.*)',
        [Parameter(HelpMessage="[regex]File Names to be excluded from the comparison[-rgxexclFiles '(.*.logs)']")]
        [regex]$rgxexclFiles = '(.*-log.txt|ScriptAnalyzer-Results-.*\.xml|fingerprint)$',
        [Parameter(HelpMessage="[string]Repository to be checked against (defaults to value stored as `$global:localPsRepo)[-Repository SomeRepo]")]        
        [string]$Repository=$localPsRepo
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ;
        $rgxNuPkgFileName = '.*\.(\d+\.\d+\.\d+)\.nupkg$' ; 
        $repoDirs=$allPkgs=@() ; 
        $RepoSrc = (Get-PSRepository -name $Repository).SourceLocation ; 
    } ; 
    PROCESS{
        $procd=0 ; $ttl = ($Paths|measure).count ; 
        foreach ($path in $Paths){
            $procd++ ; 
            $sBnrS="`n#*------v PROCESSING ($($Procd)/$($ttl)):$($path) v------" ; 
            write-verbose "$($sBnrS)" ;
            $highpkg = $latermodfiles = $null ; 
            TRY {
                $error.clear() ;
                if(-not (test-path $Path -ea STOP)){throw "missing path!"} ; 
                $pltGci=[ordered]@{path ="$($path)\*.nupkg" ; recurse=$true ; ea = 'STOP'} ;
                write-verbose "get-childitem w`n$(($pltGci|out-string).trim())" ; 
                $pkgs = get-childitem @pltGci ; 
                $pkgs = $pkgs | 
                    select *,@{name="version";expression={[version]([regex]::match($_.name,$rgxNuPkgFileName).captures[0].groups[1].value)}} | 
                    sort version ;
                if($pkgs){
                    if($pkgs -is [system.array]){$highpkg = $pkgs[-1]}
                    else {$highpkg = $pkgs} ; 
                    write-verbose "$($path):High pkg:`n$(($highpkg |ft -a name,lastwritetime,version|out-string).trim())" ; 
                    $pltGci=[ordered]@{path =$path ;recurse=$true ;file = $true ; ea = 'STOP'} ;
                    write-verbose "get-childitem w`n$(($pltGci|out-string).trim())" ; 
                    $latermodfiles = get-childitem $path -recurse -file |
                        ?{$_.extension -notmatch $rgxExcludeExts -AND $_.name -notmatch $rgxexclFiles} | 
                        ?{$_.LastWriteTime -gt $highpkg.LastWriteTime} | sort LastWriteTime; 
                    if($latermodfiles){
                        $smsg = "`n`n===Module $($path) has files dated *after* last .pkg!:`n" ; 
                        $smsg += "`n$(($highpkg|ft -a name,lastwritetime,version|out-string).trim())`n" ; 
                        $smsg += "`n$(($latermodfiles |ft -a name,lastwritetime |out-string).trim())`n`n" ; 
                        $smsg += "`n===" ; 
                        write-warning $smsg ; 
                    } else {
                        write-verbose "`n(Module $($path) has no post-build updated files)`n`n"
                    } ; 
                } ; 
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Continue  #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
            } ; 
            write-verbose $sBnrS.replace('-v','-^').replace('v-','^-') ;
        } ; 
    }  # PROC-E
    END {} ;
} ; 
#*------^ END Function test-ModuleUnReleasedContent ^------
