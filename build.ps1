# ----------------------------------------------
# Build script
# ----------------------------------------------

param
(
    [switch] $InstallTemplate,
    [switch] $CreatePermutations,
    [switch] $TestPermutations,
    [switch] $UpdatePaketDependencies
)

# ----------------------------------------------
# Main
# ----------------------------------------------

$ErrorActionPreference = "Stop"

Import-module "$PSScriptRoot/.psscripts/build-functions.ps1" -Force

Write-BuildHeader "Starting giraffe-api-template build script"

$buildfile = "./src/giraffe-api-template.csproj"
$version = Get-BuildVersion $buildfile

Update-AppVeyorBuildVersion $version

if (Test-IsAppVeyorBuildTriggeredByGitTag)
{
    $gitTag = Get-AppVeyorGitTag
    Test-CompareVersions $version $gitTag
}

Write-DotnetCoreVersions
Remove-OldBuildArtifacts

# Test Giraffe template
Write-Host "Building and testing Giraffe tempalte..." -ForegroundColor Magenta
$giraffeApp     = "src/content/Giraffe/src/AppNamePlaceholder.fsproj"
$giraffeTests   = "src/content/Giraffe/tests/AppNamePlaceholder.Tests.fsproj"

dotnet-restore $giraffeApp
dotnet-build   $giraffeApp
dotnet-restore $giraffeTests
dotnet-build   $giraffeTests
dotnet-test    $giraffeTests

# Create template NuGet package
Remove-OldBuildArtifacts
Write-Host "Building NuGet package..." -ForegroundColor Magenta
Invoke-Cmd "dotnet pack src/giraffe-api-template.csproj"

if ($UpdatePaketDependencies.IsPresent -or $TestPermutations.IsPresent -or $CreatePermutations.IsPresent -or $InstallTemplate.IsPresent)
{
    # Uninstalling Giraffe tempalte
    Write-Host "Uninstalling existing Giraffe template..." -ForegroundColor Magenta
    $giraffeInstallation = Invoke-UnsafeCmd "dotnet new giraffe --list"
    $giraffeInstallation
    if ($giraffeInstallation[$giraffeInstallation.Length - 2].StartsWith("Giraffe API"))
    {
        Invoke-Cmd "dotnet new -u giraffe-api-template"
    }

    $nupkg     = Get-ChildItem "./src/bin/Debug/giraffe-api-template.$version.nupkg"
    $nupkgPath = $nupkg.FullName

    # Installing Giraffe template
    Write-Host "Installing newly built Giraffe template..." -ForegroundColor Magenta
    Invoke-Cmd "dotnet new -i $nupkgPath"

    if ($UpdatePaketDependencies.IsPresent -or $TestPermutations.IsPresent -or $CreatePermutations.IsPresent)
    {
        # Creating new .temp folder for permutation tests
        Write-Host "Creating new .temp folder for template tests..." -ForegroundColor Magenta
        $tempFolder = ".temp"
        if (Test-Path $tempFolder) { Remove-Item $tempFolder -Recurse -Force }
        New-Item -Name ".temp" -ItemType Directory

        $viewEngine = "Giraffe"
        Write-Host "Creating templates for: $viewEngine..." -ForegroundColor Magenta

        $engine = $viewEngine.ToLower()

        Invoke-Cmd ("dotnet new giraffe -lang F# -V $engine -o $tempFolder/$viewEngine" + "App")
        Invoke-Cmd ("dotnet new giraffe -lang F# -I -V $engine -o $tempFolder/$viewEngine" + "TestsApp")
        Invoke-Cmd ("dotnet new giraffe -lang F# -U -V $engine -o $tempFolder/$viewEngine" + "PaketApp")
        Invoke-Cmd ("dotnet new giraffe -lang F# -I -U -V $engine -o $tempFolder/$viewEngine" + "TestsPaketApp")


        if ($UpdatePaketDependencies.IsPresent -or $TestPermutations.IsPresent)
        {
            # Building and testing all permutations
            Write-Host "Building and testing all permutations of the giraffe-tempalte..." -ForegroundColor Magenta

            Get-ChildItem ".temp" -Directory | ForEach-Object {
                $name = $_.Name
                Write-Host "Running build script for $name..." -ForegroundColor Magenta
                Push-Location $_.FullName

                if ($UpdatePaketDependencies.IsPresent -and $name.Contains("Paket"))
                {
                    Remove-Item -Path "paket.lock" -Force
                }

                Invoke-Cmd("sh ./build.sh")

                if ($UpdatePaketDependencies.IsPresent -and $name.Contains("Paket"))
                {
                    $viewEngine = $name.Replace("App", "").Replace("Paket", "").Replace("Tests", "")
                    Copy-Item -Path "paket.lock" -Destination "../../src/content/$viewEngine/paket.lock" -Force
                }

                Pop-Location
            }
        }
    }
}

Write-SuccessFooter "The giraffe-api-template has been successfully built!"