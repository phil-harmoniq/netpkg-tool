# NET_Pkg [![License][License]](LICENSE.md)

[License]: https://img.shields.io/badge/License-MIT-blue.svg

## Instructions

A pre-compiled version of the most current netpkg-tool is available from the [releases tab](https://github.com/phil-harmoniq/NET_Pkg/releases):

```bash
wget "https://github.com/phil-harmoniq/NET_Pkg/releases/download/current/netpkg-tool"
chmod a+x netpkg-tool
```
To build netpkg-tool from source, just run `build.sh` and specify a destination folder:
```bash
./build.sh ~/.local/bin
```

## Usage

Run netpkg-tool and specify a .NET project folder and a destination folder:

```bash
./netpkg-tool [Project Folder] [Destination] [Flags]
```

There are several optional commands that offer more control:

```
  --verbose or -v : Verbose output"
  --compile or -c : Skip checks & dotnet-restore
     --name or -n : Set ouput file to custom name
      --scd or -s : Self-Contained Deployment (SCD)
  --scd-rid or -r : SCD with custom RID (default: linux-x64)
      --dir or -d : View location of .NET runtime
     --help or -h : Help menu (this page)

          --nodel : Skip deleting NET_Pkg temporary folder
    --install-sdk : Install .NET SDK locally
  --uninstall-sdk : Remove local .NET SDK install
```

Examples:

```bash
./netpkg-tool ~/Documents/CoolApp ~/Desktop
```

```bash
# Verbose output for more details
./netpkg-tool relative/folders/too . -v
```

```bash
# Specify a custom output name after the -n flag
./netpkg-tool ~/AnotherApp ~/Desktop -n NewName
```

```bash
# A Runtime Identifer is required for Self-Contained Deployment
./netpkg-tool ~/CsharpProject /tmp --scd ubuntu.16.04-x64
```

```bash
# Use --keep to inspect the structure of your AppDir located in /tmp/netpkg-tool
./netpkg-tool TestProject ../Output --keep
```

## Requirements

* [appimagetool](https://github.com/probonopd/appimagekit/) - bundles binaries along with needed libraries into a single file
* [.NET Core SDK](https://www.microsoft.com/net/download/linux) - open-source implementation of Microsoft's .NET framework.

## Details

Using netpkg-tool will restore and compile your project based on settings in your `*.csproj` file. By default; netpkg-tool will use [Framework Dependent Deployment](https://docs.microsoft.com/en-us/dotnet/core/deploying/#framework-dependent-deployments-fdd) to compile your project and create a customized AppImage with the extension `*.npk`. To use [Self-Contained Deployment](https://docs.microsoft.com/en-us/dotnet/core/deploying/#self-contained-deployments-scd), use the `--scd` flag and designate your target Linux Distro; the resulting file will have an `*.AppImage` extension. The full process for netpkg-tool:

1. Check for appimagetool (netpkg-tool can download if missing)
2. Check for .NET Core SDK (netpkg-tool can download if missing)
3. Restore project dependencies
4. Compile .NET Core app
5. Create AppDir and transfer files
6. Run appimagetool on created AppDir
7. Delete temporary files

## .AppImage vs .npk

TL;DR: Essentially, an `.npk` file *is* an `.AppImage` file with some extra features.

.NET Core supports two types of application deployment, [Framework Dependent Deployment (SCD)](https://docs.microsoft.com/en-us/dotnet/core/deploying/#framework-dependent-deployments-fdd) and [Self-Contained Deployment (FDD)](https://docs.microsoft.com/en-us/dotnet/core/deploying/#self-contained-deployments-scd). The concept behind FDD seems to contradict the philosophy behind AppImage but could still be beneficial for console applications. SCD is more suited to the problem AppImage tries to solve but comes out much larger.

Since .NET Core is not installed by default on most Linux distrobutions, it seemed appropriate to designate .NET applications created using FDD with a different file extension and to include tools relevant to ensure a functioning .NET runtime. There are a few extra tools available to `.npk` files that make the process of checking for, installing, uninstalling, and updating .NET Core simpler. An `.npk` file will also designate some useful environment variables including `$HERE` as suggested for AppImages.

Using netpkg-tool with SCD eliminates the need for any of the extra goodies that come with an `.npk`, so none of those tools are included when you run netpkg-tool using the `--scd` flag. The resulting file will have an `.AppImage` extension and won't be reliant on .NET being installed.

## Disclaimer

The netpkg-tool project is still in alpha development. Names, commands, and features are subject to change. Please keep this in mind when using this repo.
