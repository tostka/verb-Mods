#*------v Function find-profileScripts v------
function find-profileScripts {
    <#
    .SYNOPSIS
    find-profileScripts - Reports on configured local Powershell profiles:Scope, WPS|PSCore,host,path)
    .NOTES
    Version     : 1.0.0
    Author      : (un-attributed Idera post)
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20201001-0900PM
    FileName    : find-profileScripts.ps1 
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-Mods
    Tags        : Powershell,Profile
    AddedCredit : (un-attributed Idera post)
    AddedWebsite: https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/checking-profile-scripts-part-2
    AddedTwitter: URL
    REVISIONS
    * 10:16 AM 12/1/2020 cleanedup missing func decl line
    .DESCRIPTION
    find-profileScripts.ps1 - Reports on local Powershell profiles
    .OUTPUTS
    System.Object[]
    .EXAMPLE
    $profs = find-profileScripts
    .LINK
    https://github.com/tostka/verb-XXX
    .LINK
    https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/checking-profile-scripts-part-2
    #>
    # calculate the parent paths that can contain profile scripts
    $Paths = @{
        AllUser_WPS = $pshome ;
        CurrentUser_WPS = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath "WindowsPowerShell" ;
        AllUser_PS = "$env:programfiles\PowerShell\*" ;
        CurrentUser_PS = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath "PowerShell" ;
    } ;
    $OutObj = @() ; 
    # process and summarize each path
    $Paths.Keys | ForEach-Object {
        $key = $_ ;
        $path = Join-Path -Path $paths[$key] -ChildPath '*profile.ps1' ;
        Get-ChildItem -Path $Path | ForEach-Object {
            if ($_.Name -like '*_*'){$hostname = $_.Name.Substring(0, $_.Name.Length-12) } 
            else {$hostname = 'any'} ;
            $OutObj += [PSCustomObject]@{
                Scope = $key.Split('_')[0] ;
                PowerShell = $key.Split('_')[1] ;
                Host = $hostname ;
                Path = $_.FullName ;
            } ;
        } ;
    } ; 
    $outObj | write-output ; 
} ; #*------^ END Function find-profileScripts ^------