#find-profileScripts.ps1
    <#
    .SYNOPSIS
    find-profileScripts - Reports on local Powershell profiles
    .NOTES
    Version     : 1.0.0
    Author      : (un-attributed Idera post)
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20201001-0900PM
    FileName    : find-profileScripts.ps1 
    License     : MIT License
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Profile
    AddedCredit : (un-attributed Idera post)
    AddedWebsite: https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/checking-profile-scripts-part-2
    AddedTwitter: URL
    REVISIONS
    .DESCRIPTION
    find-profileScripts.ps1 - Reports on local Powershell profiles
    .OUTPUTS
    Returns a custom object with 
    System.Boolean
    [| get-member the output to see what .NET obj TypeName is returned, to use here]
    .EXAMPLE
    .\find-profileScripts.ps1
    .EXAMPLE
    .\find-profileScripts.ps1
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