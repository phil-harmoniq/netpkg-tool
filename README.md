# netpkg-tool [![License][License]](LICENSE.md) [![Build Status](https://travis-ci.org/phil-harmoniq/netpkg-tool.svg?branch=develop)](https://travis-ci.org/phil-harmoniq/netpkg-tool)

[License]: https://img.shields.io/badge/License-MIT-blue.svg

<img src="http://imgur.com/Yl2F57K.gif" width="732" height="438">

A pre-packaged version of the most current netpkg-tool is available from the [releases tab](https://github.com/phil-harmoniq/netpkg-tool/releases):

```bash
wget https://github.com/phil-harmoniq/netpkg-tool/releases/download/master/netpkg-tool
chmod a+x netpkg-tool
```

To build netpkg-tool from source, just run `build.sh` and specify a destination folder:

```bash
git clone https://github.com/phil-harmoniq/netpkg-tool
./netpkg-tool/build.sh ~/Desktop
```

## Examples

Packaging a simple ["Hello World"](https://github.com/phil-harmoniq/Hello) app:

```bash
git clone https://github.com/phil-harmoniq/Hello
netpkg-tool Hello ~/Desktop
~/Desktop/Hello one two three
```

There are several optional commands that offer more control:

<img src="http://imgur.com/Is6HKDO.png" width="732" height="438">

## Details

Using netpkg-tool will restore and compile your project based on settings in your `*.csproj` file. By default, netpkg-tool will use [Framework Dependent Deployment](https://docs.microsoft.com/en-us/dotnet/core/deploying/#framework-dependent-deployments-fdd) to compile your project. To use [Self-Contained Deployment](https://docs.microsoft.com/en-us/dotnet/core/deploying/#self-contained-deployments-scd), use the `--scd` flag. The full process for netpkg-tool:

1. Restore project dependencies
2. Compile .NET Core app
3. Create AppDir and transfer files
4. Run appimagetool on created AppDir
5. Delete temporary files

## Disclaimer

The netpkg-tool project is still in alpha development. Names, commands, and features are subject to change. Please keep this in mind when using this repo.
