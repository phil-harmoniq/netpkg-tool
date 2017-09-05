# netpkg-tool [![Build Status](https://travis-ci.org/phil-harmoniq/netpkg-tool.svg?branch=master)](https://travis-ci.org/phil-harmoniq/netpkg-tool) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/phil-harmoniq/netpkg-tool/blob/master/README.md)

<img src="http://imgur.com/1wmkrX0.gif" width="84%">

## Download

### Released Binary

Pre-packaged versions of *netpkg-tool* are available from the [releases tab](https://github.com/phil-harmoniq/netpkg-tool/releases):

```bash
# Github releases are tagged with their version (ex: 0.3.7)
wget https://github.com/phil-harmoniq/netpkg-tool/releases/download/0.3.7/netpkg-tool
chmod a+x ./netpkg-tool

# Place netpkg-tool somewhere on your $PATH (Optional)
mv ./netpkg-tool ~/.local/bin
```

### Docker Image

*netpkg-tool* is also available as a Docker image if you don't want to install any dependencies:

```bash
# Pull the latest netpkg-tool Docker image
docker pull philharmoniq/netpkg-tool
```

For more information, see the [Docker README](https://github.com/phil-harmoniq/netpkg-tool/blob/master/docker/README.md).

### Build From Source

To build netpkg-tool from source, run `build.sh` and specify a destination folder:

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

Packaging a default ASP.NET Core MVC template:

```bash
dotnet new mvc -n aspnet-src
netpkg-tool aspnet-src . -n aspnet-pkg
./aspnet-pkg
```

## Optional Flags

<img src="http://imgur.com/NAUfM0N.png" width="84%">

## ASP.NET

ASP.NET is picky about where its content root directory is located. By default, it searches for `wwwroot` in `Directory.GetCurrentDirectory()`. Using *netpkg-tool* on an unmodified ASP.NET project will result in your web app being unable to locate any of its assets. A simple workaround would be to check for the existence of an environment variable set by *netpkg-tool*, like `$NET_PKG`, and setting the content directory to the Assembly location if it exists. This will allow the project's content to be found regardless of whether it's packaged up or being run with `dotnet run`. Example:

```C#
public class Program
{
    public static void Main(string[] args)
    {
        var assembly = Assembly.GetExecutingAssembly().Location;
        var pkgEnv = Environment.GetEnvironmentVariable("NET_PKG");

        if (string.IsNullOrEmpty(pkgEnv))
            BuildWebHost(args, Directory.GetCurrentDirectory()).Run();
        else
            BuildWebHost(args, Path.GetDirectoryName(assembly)).Run();
    }

    public static IWebHost BuildWebHost(string[] args, string root) =>
        WebHost.CreateDefaultBuilder(args)
            .UseContentRoot(root)
            .UseStartup<Startup>()
            .Build();
}
```

## Details

Using *netpkg-tool* will restore and compile your project based on settings in your `*.csproj` file. By default, *netpkg-tool* will use [Framework Dependent Deployment](https://docs.microsoft.com/en-us/dotnet/core/deploying/#framework-dependent-deployments-fdd) to compile your project. To use [Self-Contained Deployment](https://docs.microsoft.com/en-us/dotnet/core/deploying/#self-contained-deployments-scd), use the `--scd` flag. The full process for *netpkg-tool*:

1. Restore project dependencies
2. Compile .NET Core app
3. Create AppDir and transfer files
4. Run appimagetool on created AppDir
5. Delete temporary files

## Dependencies

- [.NET Core 2.0 SDK](https://www.microsoft.com/net/core/preview): Per-distro [RID](https://docs.microsoft.com/en-us/dotnet/core/rid-catalog) tags were replaced with the universal `linux-x64` [RID](https://github.com/dotnet/cli/issues/2727), simplifying the Linux build process. Earlier versions *should* work with *netpkg-tool* but only using [Framework Dependent Deployment](https://docs.microsoft.com/en-us/dotnet/core/deploying/#framework-dependent-deployments-fdd).
- [appimagetool](https://github.com/AppImage/AppImageKit): (Included) Bundles linux applications into AppImages.
- [Shell.NET](https://github.com/phil-harmoniq/Shell.NET): (Included) .NET Standard library for interacting with Bash.

## Mono

While this project is mainly aimed at Microsoft's new [.NET Core](https://www.microsoft.com/net/core/) ecosystem, it should be possible to eventually make this tool work with [Mono](http://www.mono-project.com/). Mono support is planned but no exact ETA can be given until the core utility is in a more stable state.

## Disclaimer

The netpkg-tool project is still in alpha development. Names, commands, and features are subject to change. Please keep this in mind when using this utility.
