function ResolveModuleManifest {
    <#
        .Synopsis
            Resolve the module manifest path in the module source base.
    #>
    [OutputType([string])]
    param(
        # The path to the module folder, manifest or build.psd1
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                if (Test-Path $_ -PathType Container) {
                    $true
                } else {
                    throw "ModuleBase must point to the source base for a module: $_"
                }
            })]
        [Alias("ModuleManifest")]
        [string]$ModuleBase = $(Get-Location -PSProvider FileSystem),

        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [string]$Name
    )
    Push-Location $ModuleBase -StackName ResolveModuleManifest

    if(!$PSBoundParameters.ContainsKey("ModuleName")) {
        # Do not use GetFileNameWithoutExtension, because some module names have dots in them
        $Name = (Split-Path $ModuleBase -Leaf) -replace "\.psd1$"
        # If we're in a "well known" source folder, look higher for a name
        if ($Name -in "Source", "src") {
            $Name = Split-Path (Split-Path $ModuleBase) -Leaf
        }
    }

    $Manifest = Join-Path $ModuleBase "$Name.psd1"
    if (!(Test-Path $Manifest)) {
        throw "Can't find module manifest $Manifest"
    }

    Pop-Location -StackName ResolveModuleManifest
    $Manifest
}