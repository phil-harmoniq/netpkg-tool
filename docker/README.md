netpkg-tool Docker Image
========================

This Docker image contains the [*netpkg-tool*](https://github.com/phil-harmoniq/netpkg-tool) binary and is based on the [microsoft/dotnet](https://hub.docker.com/r/microsoft/dotnet/) 2.0-sdk image. Using this Docker image allows you to use *netpkg-tool* without installing the .NET Core SDK.

Pull
-----

Docker images are automatically built using the latest source files. Use the `latest` tag for the most recent master build or the `unstable` tag for the most recent development build:

```bash
# Latest master release
docker pull philharmoniq/netpkg-tool

# Latest development release
docker pull philhamroniq/netpkg-tool:unstable
```

Usage
-----

*netpkg-tool* requires input and output directories as parameters. These are set to `/root/src` and `/root/out` in the Docker image by default, so you simply have to bind mount volumes that map your local directories to the directories in the Docker container:

```bash
# Assuming the working directory contains your .NET Core project.
# Note: ${PWD}/out doesn't have to exist - Docker creates the directory if necessary
docker run --rm -v ${PWD}:/root/src -v ${PWD}/out:/root/out local/netpkg-tool
```

You can also supply parameters like `-n MyApp` or `--scd` to the container. **Full example**:

```bash
git clone https://github.com/phil-harmoniq/Hello
cd Hello
docker run --rm -v ${PWD}:/root/src -v ${PWD}/out:/root/out local/netpkg-tool -n MyApp
./out/MyApp
```

For more parameters, see the project's main [README](https://github.com/phil-harmoniq/netpkg-tool/blob/master/README.md).
