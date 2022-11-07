#*------v register-localPSRepository.ps1 v------
function register-localPSRepository {
    <#
    .SYNOPSIS
    register-localPSRepository.ps1 - Confirms, or manually-registers, local PSRepository, as specified by profile $localPSRepo variable. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-12-01
    FileName    : register-localPSRepository.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-Mods
    Tags        : Powershell
    REVISIONS
    * 8:36 AM 12/1/2020 init
    .DESCRIPTION
    register-localPSRepository.ps1 - Confirms, or manually-registers, local PSRepository, as specified by profile $localPSRepo variable. 
    .PARAMETER  Repository
    Local Repository name (defaults to profile $localRepo value)[-Repository someRepo]
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
    register-localPSRepository ;
    Default pass - confirms or manaually registers default local Repository (as specified in profile $localPSRepo value)
    .LINK
    https://github.com/tostka/verb-XXX
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,HelpMessage="local Repository name (defaults to profile `$localRepo value)[-Repository someRepo]")]
        [string] $Repository=$localPSRepo,
        [Parameter(Position=0,Mandatory=$false,HelpMessage="local Repository path (defaults to profile `$localPSRepoPath value)[-RepositoryPath \\server\path_to\ModulesAndScripts]")]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string] $RepositoryPath=$localPSRepoPath,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    BEGIN {
        $Verbose = ($VerbosePreference -eq "Continue") ; 
        $smsg = "Confirming registration of $($Repository) PSRepository" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
    } 
    PROCESS {
        if ($Repository -AND $RepositoryPath){
            if(!($registeredRepo = Get-PSRepository -Name $Repository)){
                $pltRepo = @{Name = $Repository ;SourceLocation = $RepositoryPath; PublishLocation = $RepositoryPath ;InstallationPolicy = 'Trusted' ;} ;
                if (Test-Path $pltRepo.SourceLocation){
                    $error.clear() ;
                    TRY {
                        write-host -foregroundcolor yellow "FIXING MISSING:Register-PSRepository w`n$(($pltRepo|out-string).trim())" ; 
                        Register-PSRepository @pltRepo ; 
                        $registeredRepo = Get-PSRepository -Name $pltRepo.name  ; 
                    } CATCH {
                        Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
                        BREAK ; 
                    } ; 
                } else {throw "Repository $pltRepo.SourceLocation is offline" }  ;
            } else {
                #write-verbose "$((get-date).ToString('HH:mm:ss')):repo registered w`n$(($registeredRepo| ft -a name,installationpolicy,sourcelocation|out-string).trim())" ; 
                #$registeredRepo | write-output ;
            } ;  

        } else { 
            throw "Missing -Repository and/or -RepositoryPath for registration!`n(or source `$localPSRepo & `$localPSRepoPath are not configured in profile)"  ; 
        } ; 
    } ; 
    END {
        if($registeredRepo){
            $registeredRepo | write-output ;
        } else { $false | write-output } ; 
    } ; 
} ;
#*------^ END Function register-localPSRepository ^------
