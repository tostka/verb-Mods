#*------v Function Uninstall-AllModules v------
function Uninstall-AllModules {
    <#
.SYNOPSIS
Uninstall-AllModules.ps1 - Queries Powershell Gallery to uninstall a module and all dependent submodules.
.NOTES
Author: Stephen Tramer (MSFT)
Website:	https://docs.microsoft.com/en-us/powershell/azure/uninstall-az-ps?view=azps-1.0.0
Updated by: Todd Kadrie
Website:	http://www.toddomation.com
Twitter:	@tostka, http://twitter.com/tostka
REVISIONS   :
* 12/12/2018 posted version
.DESCRIPTION
Queries the PowerShell Gallery to get a list of dependent submodules. Then, the script uninstalls the correct version of each submodule. You will need to have administrator access to run this script in a scope other than Process or CurrentUser.
.PARAMETER  TargetModule
.PARAMETER  Version
.PARAMETER  Force
.PARAMETER  WhatIf
.EXAMPLE
Get-InstalledModule -Name Az -AllVersions ;
Uninstall-AllModules -TargetModule Az -Version 0.7.0 -Force -whatif ;
Query Az module and specific version installed and then remove the module & dependancies
.LINK
https://docs.microsoft.com/en-us/powershell/azure/uninstall-az-ps?view=azps-1.0.0
#>
    param(
        [Parameter(Mandatory = $true)][string]$TargetModule,
        [Parameter(Mandatory = $true)][string]$Version,
        [switch]$Force,
        [switch]$WhatIf
    ) ;
    $AllModules = @() ;
    'Creating list of dependencies...' ;
    $target = Find-Module $TargetModule -RequiredVersion $version ;
    $target.Dependencies | ForEach-Object {
        if ($_.requiredVersion) {
            $AllModules += New-Object -TypeName psobject -Property @{name = $_.name; version = $_.requiredVersion } ;
        }
        else {
            # Assume minimum version ;
            # Minimum version actually reports the installed dependency
            # which is used, not the actual "minimum dependency." Check to
            # see if the requested version was installed as a dependency earlier.
            $candidate = Get-InstalledModule $_.name -RequiredVersion $version ;
            if ($candidate) {
                $AllModules += New-Object -TypeName psobject -Property @{name = $_.name; version = $version } ;
            }
            else {
                Write-Warning ("Could not find uninstall candidate for {0}:{1} - module may require manual uninstall" -f $_.name, $version) ;
            } ;
        } ;
    } ;
    $AllModules += New-Object -TypeName psobject -Property @{name = $TargetModule; version = $Version } ;
    foreach ($module in $AllModules) {
        Write-Host ('Uninstalling {0} version {1}...' -f $module.name, $module.version) ;
        try {
            Uninstall-Module -Name $module.name -RequiredVersion $module.version -Force:$Force -ErrorAction Stop -WhatIf:$WhatIf ;
        }
        catch {
            Write-Host ("`t" + $_.Exception.Message) ;
        } ;
    } ; # loop-E
} ; #*------^ END Function Uninstall-AllModules ^------
