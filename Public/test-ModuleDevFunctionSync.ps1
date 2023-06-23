# test-ModuleDevFunctionSync.ps1

#*------v Function test-ModuleDevFunctionSync v------
function test-ModuleDevFunctionSync {
    <#
    .SYNOPSIS
    test-ModuleDevFunctionSync - Check specified dev directory *_func.ps1 files after -Cutoff date, for matching like-named scripts in module source directory for dev coded that hasn't been copied to the mod .ps1 copy. Also can prompt for/run Windiff compare per match.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-06-23
    FileName    : test-ModuleDevFunctionSync.ps1
    License     : MIT License
    Copyright   : (c) 2023 Todd Kadrie
    Github      : https://github.com/tostka/verb-mods
    Tags        : Powershell,Module,Maintenance
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 3:28 PM 6/23/2023 init
    .DESCRIPTION
    test-ModuleDevFunctionSync - Check specified dev directory *_func.ps1 files after -Cutoff date, for matching like-named scripts in module source directory for dev coded that hasn't been copied to the mod .ps1 copy. Also can prompt for/run Windiff compare per match.
    .PARAMETER Paths 
    directories to be checked for xxx_func.ps1 files matching xxx.ps1 files in the specified -ModuleName Public subfolder[-Paths 'c:\path-to\','c:\path-to2']
    .PARAMETER ModuleName
    ModuleName to be checked against -Paths[-ModuleName 'verb-aad']
    .PARAMETER CutoffDate
    Date against which to filter *after* (checked against LastWriteTime)[-CutoffDate '3/22/2022']
    .PARAMETER DiffPrompt
    Switch that prompts each return for an optional Windiff pass[-DiffPrompt]
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
    PS> test-ModuleDevFunctionSync -Paths C:\usr\work\o365\scripts\ -ModuleName verb-aad -CutoffDate '3/28/2022' -verbose ;
    Run a pass against a directory, checking for scripts with name-noun-prefixes matching verb-AAD module (e.g. '-aad*').
    .EXAMPLE
    PS> test-ModuleDevFunctionSync -Paths C:\usr\work\o365\scripts\ -ModuleName verb-aad -CutoffDate '3/28/2022' -diffPrompt -verbose ;
    Run a pass against a directory, checking for scripts with name-noun-prefixes matching verb-AAD module (e.g. '-aad*').
    .EXAMPLE
    PS> test-ModuleDevFunctionSync -Paths @('C:\usr\work\o365\scripts\','c:\usr\work\ps\scripts\') -ModuleName verb-aad -CutoffDate '3/28/2022' -diffPrompt -verbose ;
    Run a pass against a directory, checking for scripts with name-noun-prefixes matching verb-AAD module (e.g. '-aad*'). Prompts each for optional WinDiff compare.
    .LINK
    https://github.com/tostka/verb-Mods
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    [CmdletBinding()]
    [Alias('test-UnReleasedModuleContent','test-ModuleBuild')]
    PARAM(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Development directories to be checked for updated xxx_func.ps1 files matching xxx.ps1 files in the specified -ModuleName repository\Public folder[-Paths 'c:\path-to\','c:\path-to2']")]
        [ValidateScript({Test-Path $_ -PathType container})]
        [string[]]$Paths,
        [Parameter(Position=1,Mandatory=$true,HelpMessage="ModuleName to be checked against -Paths[-ModuleName 'verb-aad']")]
        [string]$ModuleName,
        [Parameter(HelpMessage="Root from which ModuleName should be checked for matching GIT Repo subdirectory (defaults to local existing `$GIT_REPOSROOT)[-RepoRoot 'c:\sc\']")]
        [ValidateScript({Test-Path $_ -PathType container})]
        [string]$RepoRoot = $GIT_REPOSROOT, 
        [Parameter(HelpMessage="Date against which to filter *after* (checked against LastWriteTime)[-CutoffDate '3/22/2022']")]
        [datetime]$CutoffDate,
        [Parameter(HelpMessage="Switch that prompts each return for an optional Windiff pass[-DiffPrompt]")]
        [switch]$DiffPrompt,
        [Parameter(HelpMessage="[regex]Files Extensions to be excluded from the comparison[-rgxExcludeExts '(.txt|.xml)']")]
        [regex]$rgxExcludeExts = '(\.nupkg|\.gitignore|\.*_.*)',
        [Parameter(HelpMessage="[regex]File Names to be excluded from the comparison[-rgxexclFiles '(.*.logs)']")]
        [regex]$rgxexclFiles = '(.*-log.txt|ScriptAnalyzer-Results-.*\.xml|fingerprint)$',
        [Parameter(HelpMessage="[string]Repository to be checked against (defaults to value stored as `$global:localPsRepo)[-Repository SomeRepo]")]        
        [string]$Repository=$localPsRepo
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ;
        #$rgxNuPkgFileName = '.*\.(\d+\.\d+\.\d+)\.nupkg$' ; 
        #$repoDirs=$allPkgs=@() ; 
        $prpGCI = 'FullName','Length','LastWriteTime' ;
        #$RepoSrc = (Get-PSRepository -name $Repository).SourceLocation ; 
        $GitRepoPath = get-item (join-path -path $RepoRoot -ChildPath $ModuleName) -ea STOP | select -expand fullname ; 
        $GitPublicPath = get-item (join-path -path $GitRepoPath -childpath 'Public') -ea STOP | select -expand fullname ; 
        $smsg = "Resolved:`n`$GitRepoPath:$($GitRepoPath)" ; 
        $smsg += "`$GitPublicPath:$($GitPublicPath)" ; 
        write-verbose $smsg ; 
    } ; 
    PROCESS{
        $procd=0 ; $ttl = ($Paths|measure).count ; 
        foreach ($path in $Paths){
            $procd++ ; 
            $sBnr="#*======v PROCESSING $($ModuleName) against: ($($Procd)/$($ttl)):$($path) v======" ; 
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnr)" ;
            $devfiles = $modfile = $null ; 
            TRY {
                $error.clear() ;
                $pltGci=[ordered]@{
                    path ="$($path)" ;
                    recurse=$true ;
                    filter = "*-$($ModuleName.split('-')[1])*_func.ps1" ; 
                    ea = 'STOP' ;
                } ;
                write-verbose "get-childitem w`n$(($pltGci|out-string).trim())" ; 
                $devfiles = get-childitem @pltGci |
                        ?{$_.extension -notmatch $rgxExcludeExts -AND $_.name -notmatch $rgxexclFiles} | 
                            sort LastWriteTime ; 
                if($devfiles){
                    if($CutoffDate){
                        write-verbose "reducing returns to those after $(get-date $CutoffDate -format 'yyyyMMdd-HHmmtt')" ; 
                        $devfiles = $devfiles | ?{$_.LastWriteTime -gt $CutoffDate }
                    } ; 
                    foreach ($devfile in $devfiles){
                        $sBnrS="`n#*------v PROCESSING Match:$($devfile.basename) v------" ; 
                        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnrS)" ;
                        # $GitRepoPath
                        $pltGci=[ordered]@{
                            path = $GitPublicPath ;
                            recurse = $false ;
                            filter = "$($devfile.basename.replace('_func','')).ps1"  ;
                            ea = 'STOP' ;
                        } ;
                        write-verbose "Locating Modfile:get-childitem w`n$(($pltGci|out-string).trim())" ; 
                        if($modfiles = get-childitem @pltGCI){
                            write-host "`nMATCHES:" ;
                            $devfile,$modfiles | ft -a $prpGCI  ;
                            if($DiffPrompt){
                                $bRet=Read-Host "Enter Y to WinDiff"  ; 
                                if ($bRet.ToUpper() -eq "Y") {
                                    $pltSP = [ordered]@{
                                        filepath = "WinDiff.Exe" ; 
                                        ArgumentList = "$($modfiles[0].fullname) $($devfile.fullname)" ; 
                                        Wait = $true ;
                                    } ;  
                                    write-verbose "start-Process w`n$(($pltSP|out-string).trim())" ; 
                                    start-process @pltSP ; 
                                }  ; 
                            } ; 
                        } else { 
                            write-warning "`nNO MODFILE MATCHES for devfile:" ;
                            $devfile | ft -a $prpGCI  ;
                        } ; 
                        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnrS.replace('-v','-^').replace('v-','^-'))`n" ;
                    } ; 
                } ; 
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Continue  #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
            } ; 
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnr.replace('=v','=^').replace('v=','^='))" ;
        } ; 
    }  # PROC-E
    END {} ;
} ; 
#*------^ END Function test-ModuleDevFunctionSync ^------
