# NET_Pkg [![License][License]](LICENSE.md) [![Build Status](https://travis-ci.org/phil-harmoniq/NET_Pkg.svg?branch=develop)](https://travis-ci.org/phil-harmoniq/NET_Pkg)

[License]: https://img.shields.io/badge/License-MIT-blue.svg

A pre-packaged version of the most current netpkg-tool is available from the [releases tab](https://github.com/phil-harmoniq/NET_Pkg/releases):

```bash
wget https://github.com/phil-harmoniq/NET_Pkg/releases/download/master/netpkg-tool
chmod a+x netpkg-tool
```

To build netpkg-tool from source, just run `build.sh` and specify a destination folder:

```bash
git clone https://github.com/phil-harmoniq/NET_Pkg
./NET_Pkg/build.sh .
```

## Example

```bash
# Download netpkg-tool and compile a simple .NET Core app
wget https://github.com/phil-harmoniq/NET_Pkg/releases/download/master/netpkg-tool
git clone https://github.com/phil-harmoniq/ArgTest
chmod a+x netpkg-tool
./netpkg-tool ArgTest .
./ArgTest.npk one two --npk-v three
```

[ArgTest source](https://github.com/phil-harmoniq/ArgTest)

## Usage

Run netpkg-tool and specify a .NET project folder and a destination folder:

```bash
./netpkg-tool [Project Folder] [Destination] [Flags]
```

There are several optional commands that offer more control:

```
     --verbose or -v: Verbose output
     --compile or -c: Skip checks & dotnet-restore
        --name or -n: Set ouput file to custom name
         --scd or -s: Self-Contained Deployment (SCD)
     --scd-rid or -r: SCD with custom RID (default: linux-x64)
        --keep or -k: Keep /tmp/npk.temp directory

        --help or -h: Help menu (this page)
       --install-sdk: Install .NET SDK locally
     --uninstall-sdk: Remove local .NET SDK install
```

## Requirements

* [appimagetool](https://github.com/probonopd/appimagekit/) - bundles binaries along with needed libraries into a single file
* [.NET Core 2.0 SDK](https://github.com/dotnet/core/blob/master/release-notes/download-archives/2.0.0-preview1-download.md) - open-source implementation of Microsoft's .NET framework.

Note: netpkg-tool can attempt to install these locally to your home directory

## Details

Using netpkg-tool will restore and compile your project based on settings in your `*.csproj` file. By default; netpkg-tool will use [Framework Dependent Deployment](https://docs.microsoft.com/en-us/dotnet/core/deploying/#framework-dependent-deployments-fdd) to compile your project and create a customized AppImage with the extension `*.npk`. To use [Self-Contained Deployment](https://docs.microsoft.com/en-us/dotnet/core/deploying/#self-contained-deployments-scd), use the `--scd` flag and designate your target Linux Distro; the resulting file will have an `*.AppImage` extension. The full process for netpkg-tool:

1. Check for .NET Core SDK (netpkg-tool can download if missing)
2. Restore project dependencies
3. Compile .NET Core app
4. Create AppDir and transfer files
5. Run appimagetool on created AppDir
6. Delete temporary files

## .AppImage vs .npk

TL;DR: Essentially, an `.npk` file *is* an `.AppImage` file with some extra features.

.NET Core supports two types of application deployment, [Framework Dependent Deployment (SCD)](https://docs.microsoft.com/en-us/dotnet/core/deploying/#framework-dependent-deployments-fdd) and [Self-Contained Deployment (FDD)](https://docs.microsoft.com/en-us/dotnet/core/deploying/#self-contained-deployments-scd). The concept behind FDD seems to contradict the philosophy behind AppImage but could still be beneficial for console applications. SCD is more suited to the problem AppImage tries to solve but comes out much larger.

Since .NET Core is not installed by default on most Linux distrobutions, it seemed appropriate to designate .NET applications created using FDD with a different file extension and to include tools relevant to ensure a functioning .NET runtime. There are a few extra tools available to `.npk` files that make the process of checking for, installing, uninstalling, and updating .NET Core simpler. An `.npk` file will also designate some useful environment variables including `$HERE` as suggested for AppImages.

Using netpkg-tool with SCD eliminates the need for any of the extra goodies that come with an `.npk`, so none of those tools are included when you run netpkg-tool using the `--scd` flag. The resulting file will have an `.AppImage` extension and won't be reliant on .NET being installed.

## Disclaimer

The netpkg-tool project is still in alpha development. Names, commands, and features are subject to change. Please keep this in mind when using this repo.
