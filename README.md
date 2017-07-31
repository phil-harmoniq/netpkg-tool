# netpkg-tool [![License][License]](LICENSE.md) [![Build Status](https://travis-ci.org/phil-harmoniq/netpkg-tool.svg?branch=develop)](https://travis-ci.org/phil-harmoniq/netpkg-tool)

[License]: https://img.shields.io/badge/License-MIT-blue.svg

<img src="http://imgur.com/Yl2F57K.gif" width="732" height="438">

A pre-packaged version of the most current netpkg-tool is available from the [releases tab](https://github.com/phil-harmoniq/netpkg-tool/releases):

```bash
# The Master branch will always hold the latest release
wget https://github.com/phil-harmoniq/netpkg-tool/releases/download/master/netpkg-tool
chmod a+x netpkg-tool

# Place it somewhere on your $PATH (Optional)
mv ./netpkg-tool ~/.local/bin
```

To build netpkg-tool from source, just run `build.sh` and specify a destination folder:

```bash
git clone https://github.com/phil-harmoniq/netpkg-tool
./netpkg-tool/build.sh ~/Desktop
```

## Examples

Packaging a default ASP.NET Core MVC template:

```bash
dotnet new mvc -n aspnet-src
netpkg-tool aspnet-src . -n aspnet-pkg
./aspnet-pkg
```

Packaging a simple ["Hello World"](https://github.com/phil-harmoniq/Hello) app:

```bash
git clone https://github.com/phil-harmoniq/Hello
netpkg-tool Hello .
./Hello one two thr33
```

## Optional Flags

<img src="http://imgur.com/Is6HKDO.png" width="732" height="438">

## Details

Using netpkg-tool will restore and compile your project based on settings in your `*.csproj` file. By default, netpkg-tool will use [Framework Dependent Deployment](https://docs.microsoft.com/en-us/dotnet/core/deploying/#framework-dependent-deployments-fdd) to compile your project. To use [Self-Contained Deployment](https://docs.microsoft.com/en-us/dotnet/core/deploying/#self-contained-deployments-scd), use the `--scd` flag. The full process for netpkg-tool:

1. Restore project dependencies
2. Compile .NET Core app
3. Create AppDir and transfer files
4. Run appimagetool on created AppDir
5. Delete temporary files

## Mono

While this project is mainly aimed at Microsoft's new [.NET Core](https://www.microsoft.com/net/core/) ecosystem, it should be possible to eventually make this tool work with [Mono](http://www.mono-project.com/). Mono support is planned but no exact ETA can be given until the core utility is in a more stable state.

## Disclaimer

The netpkg-tool project is still in alpha development. Names, commands, and features are subject to change. Please keep this in mind when using this utility.
