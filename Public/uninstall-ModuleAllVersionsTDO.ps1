# uninstall-ModuleAllVersionsTDO.ps1

#region UNINSTALL_MODULEALLVERSIONSTDO ; #*------v uninstall-ModuleAllVersionsTDO v------
function uninstall-ModuleAllVersionsTDO {
    <#
    .SYNOPSIS
    uninstall-ModuleAllVersionsTDO - Force Uninstalls all installed versions of the specified -Modules entry.
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2026-06-30
    FileName    : uninstall-ModuleAllVersionsTDO.ps1
    License     : MIT
    Copyright   : (c) 2026 Todd Kadrie
    Github      : https://github.com/tostka/verb-mods
    Tags        : Powershell,Module,Lifecycle
    AddedCredit : 
    AddedWebsite: 
    AddedTwitter: 
    REVISIONS
    * 8:49 AM 6/30/2026 init
    .DESCRIPTION
    uninstall-ModuleAllVersionsTDO - Force Uninstalls all installed versions of the specified -Modules entry.
    .PARAMETER Modules
    Specific Module(s) to be processed[-Modules array-of-module-descrptors]
    .PARAMETER whatIf
    Whatif Flag  [-whatIf]
    .EXAMPLE
    PS> uninstall-ModuleAllVersionsTDO -Modules @('verb-xty','verb-yup') -whatif:$true ; 
    Demo pass with two specified modules (passed as an array)
    .LINK
    https://github.com/tostka
    #>
    [CmdletBinding()] 
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Array of specific Module(s) to be processed[-Modules 'mod1','mod2']")]
            [Alias('Name')]
            $Modules,
        #[Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Source Repository, for which *all* associated local installed modules should be processed (should match Repository property of module, as returned by Get-InstalledModule cmdlet)[-Repository 'Repo1']")]
        #    [array]$Repository,
        #[Parameter(HelpMessage="Scope to be targeted (AllUsers|CurrentUser, default: no filtering)[-Scope AllUsers]")]
        #    [ValidateSet("AllUsers","CurrentUser")]
        #    [array]$Scope,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
            [switch]$whatIf
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 
        # construct dynamic scope regex's (accomodates profile redirection and system variant progfiles locations)
        # AllUsers scope
        [regex]$rgxModsAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\Modules" ;
        # CurrUser scope
        [regex]$rgxModsCurrUserScope="^$([regex]::escape([environment]::getfolderpath('Mydocuments')))\\((Windows)*)PowerShell\\Modules" ;
    } ;
    PROCESS {
        $ttl=($Modules|Measure-Object).count ;
        $Procd=0 ; 
        $smsg = "($(($Modules|measure).count) modules specifid)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        $results = @() ; 
        foreach ($Module in $Modules) {
            $Procd++ ;
            $sBnr="#*======v ($($Procd)/$($ttl)):PROCESSING:$($Module) v======" ; 
            $smsg=$sBnr ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $fltrMod = "$($Module)*" ; 
            write-host "Uninstall-Module $($fltrMod) -AllVersions -Force for any discovered versions..." ; 
            Get-Module $fltrMod -ListAvailable | ForEach-Object {
                write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):Uninstalling discovered`n$(($_ | ft -a name,version,path|out-string).trim())" ; 
                Uninstall-Module $_.Name -AllVersions -Force -ErrorAction SilentlyContinue -whatif:$($whatif); 
            } ; 
            write-host "Checking all 'Modules' PSModulePath entries for remaining $($fltrMod.replace('*','')) module content" ; 
            $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
            ($env:PSModulePath.split(';') |?{$_ -match '\\Modules'}) | foreach-object{
                $thispth = (join-path -path $_ -child $($fltrMod.replace('*','')) -verbose ) ;
                write-host "`n===$($thispth)" ;
                if($hits = get-childitem -path $thispth -verbose -ea 0){
                    write-warning "DIRECTORIES REMAIN!`n$(($hits|ft -a |out-string).trim())" ;     
                    $results += $false ;            
                }else{
                    write-host -foregroundcolor green 'directories cleared'
                    $results += $true ; 
                } ;
            } ;            
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ; # loop-E
        $smsg = "PASS COMPLETED" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 
    END{
        if($results -contains $false){
            $smsg = "FAILED to remove all copies of one of the processed Modules (see above)" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            $false | write-output 
        } else {
            $smsg = "Successfully removed all copies of the processed Modules (see above)" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Success } 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            $true | write-output 
        }; 
    } ;
} ; 
#*------^ uninstall-ModuleAllVersionsTDO.ps1 ^------
