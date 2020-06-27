# Giraffe API Template

![Giraffe](https://raw.githubusercontent.com/giraffe-fsharp/Giraffe/master/giraffe.png)

Giraffe API template for the `dotnet new` command. Building off the original giraffe template.

Updated to use dotnet core 3.1 (from 2.1), and to avoid using mono on linux.
Also updated to change the defaults and remove Razor and DotLiquid, in favor of an API first approach.
Now uses msbuild and dotnet pack instead of nuget pack - for improved cross platform compatibility.

<!-- [![NuGet Info](https://buildstats.info/nuget/giraffe-api-template)](https://www.nuget.org/packages/giraffe-api-template/) -->

## Table of contents

- [Installation](#installation)
- [Basics](#basics)
- [Optional parameters](#optional-parameters)
    - [--ViewEngine](#--viewengine)
    - [--IncludeTests](#--includetests)
    - [--UsePaket](#--usepaket)
- [Updating the template](#updating-the-template)
- [Nightly builds and NuGet feed](#nightly-builds-and-nuget-feed)
- [Contributing](#contributing)
- [More information](#more-information)
- [License](#license)

## Installation

The easiest way to install the Giraffe template is by running the following command in your terminal:

```
dotnet new -i "giraffe-api-template::*"
```

This will pull and install the [giraffe-template NuGet package](https://www.nuget.org/packages/giraffe-template/) in your .NET environment and make it available to subsequent `dotnet new` commands.

**(Note - not yet pushed to nuget)**

## Basics

After the template has been installed you can create a new Giraffe web application by simply running `dotnet new giraffe` in your terminal:

```
dotnet new giraffeapi
```

If you wish to use [Paket](https://fsprojects.github.io/Paket/) for your dependency management use the `--UsePaket` parameter when creating a new application:

```
dotnet new giraffeapi --UsePaket
```

The Giraffe template only supports the F# language at the moment.

Please be also aware that you cannot name your project "giraffe" (`dotnet new giraffe -o giraffe`) as this will lead the .NET Core CLI to fail with the error "NU1108-Cycle detected" when trying to resolve the project's dependencies.

Further information and more help can be found by running `dotnet new giraffe --help` in your terminal.

### ATTENTION: Use with .NET Core 3.1 or higher.

## Optional parameters

### --IncludeTests

When creating a new Giraffe web application you can optionally specify the `--IncludeTests` (short `-I`) parameter to automatically generate a default unit test project for your application:

```
dotnet new giraffeapi --IncludeTests
```

### --UsePaket

If you prefer [Paket](https://fsprojects.github.io/) for managing your project dependencies then you can specify `--UsePaket` (`-U` for short):

```
dotnet new giraffe --UsePaket
```

This will exclude the package references from the *fsproj* file and include the needed *paket.dependencies* and *paket.references* files.

> If you do not run *build.bat* (or *build.sh* on **nix) before running `dotnet restore` you need to manually run `./.paket/paket.exe install` (or `mono ./.paket/paket.exe install`).

See the [Paket documentation](https://fsprojects.github.io/) for more details.

## Updating the template

Whenever there is a new version of the Giraffe template you can update it by re-running the [instructions from the installation](#installation).

You can also explicitly set the version when installing the template:

```
dotnet new -i "giraffe-api-template::0.0.1"
```

## Contributing

Please use the `./build.ps1` PowerShell script to build and test the Giraffe template before submitting a PR.

The `./build.ps1` PowerShell script comes with the following feature switches:

| Switch | Description |
| :----- | :---------- |
| No switch | The default script without a switch will build all projects and run all tests before producing a Giraffe template NuGet package. | `./build.ps1` |
| `InstallTemplate` | After successfully creating a new NuGet package for the Giraffe template the `-InstallTemplate` switch will uninstall any existing Giraffe templates before installing the freshly built template again. |
| `CreatePermutations` | The `-CreatePermutations` switch does everything what the `-InstallTemplate` switch does plus it will create a new test project for each individual permutation of the Giraffe template options. All test projects will be created under the `.temp` folder. An existing folder of the same name will be cleared before creating all test projects. |
| `TestPermutations` | The `-TestPermutations` switch does everything what the `-CreatePermutations` switch does plus it will build all test projects and execute their unit tests. This is the most comprehensive build and will likely take several minutes before completing. It is recommended to run this build before submitting a PR. |
| `UpdatePaketDependencies` | The `-UpdatePaketDependencies` switch does everything what the `-TestPermutations` switch does plus it will update the Giraffe NuGet dependencies for all Paket enabled test projects. After updating the Giraffe dependency it will automatically copy the upated `paket.lock` file into the correct template of the `./src` folder. It is recommended to run this build when changing any dependencies for one or many templates. |

### Examples

#### Default:

Windows:

```powershell
> ./build.ps1
```

MacOS and Linux:

```powershell
$ pwsh ./build.ps1
```

#### Installing the new template:

Windows:

```powershell
> ./build.ps1 -InstallTemplate
```

MacOS and Linux:

```powershell
$ pwsh ./build.ps1 -InstallTemplate
```

#### Creating a test project for each permutation:

Windows:

```powershell
> ./build.ps1 -CreatePermutations
```

MacOS and Linux:

```powershell
$ pwsh ./build.ps1 -CreatePermutations
```

#### Creating and testing all test projects for all permutations:

Windows:

```powershell
> ./build.ps1 -TestPermutations
```

MacOS and Linux:

```powershell
$ pwsh ./build.ps1 -TestPermutations
```

#### Creating and testing all permutations and updating the `paket.lock` file afterwards:

Windows:

```powershell
> ./build.ps1 -UpdatePaketDependencies
```

MacOS and Linux:

```powershell
$ pwsh ./build.ps1 -UpdatePaketDependencies
```

## More information

For more information about Giraffe, how to set up a development environment, contribution guidelines and more please visit the [main documentation](https://github.com/giraffe-fsharp/Giraffe#table-of-contents) page.

## License

[Apache 2.0](https://raw.githubusercontent.com/giraffe-fsharp/giraffe-template/master/LICENSE)
