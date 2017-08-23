netpkg-tool Docker Image
========================

This Docker image contains the [*netpkg-tool*](https://github.com/phil-harmoniq/netpkg-tool) binary and is based on the [microsoft/dotnet](https://hub.docker.com/r/microsoft/dotnet/) 2.0-sdk image, so that you can use *netpkg-tool* without having to install any dependencies like the .NET Core SDK.

Build
-----

The Docker image will be available on Docker Hub in the future, but until then you have to build it yourself:

```bash
git clone https://github.com/phil-harmoniq/netpkg-tool
cd netpkg-tool
docker build -f docker/Dockerfile -t local/netpkg-tool .
```

Usage
-----

*netpkg-tool* requires in- and output directories as parameters. These are set to `/root/src` and `/root/out` in the Docker image by default, so you simply have to supply volumes that map your local directories to the directories in the Docker container:

```bash
# Assuming the working directory contains your .NET Core project.
# Note: ${PWD}/out doesn't have to exist - Docker creates the directory if necessary
docker run --rm -v ${PWD}:/root/src -v ${PWD}/out:/root/out local/netpkg-tool
```

You can also supply parameters like `-n MyApp` to the container. **Full example**:

```bash
git clone https://github.com/phil-harmoniq/Hello
cd Hello
docker run --rm -v ${PWD}:/root/src -v ${PWD}/out:/root/out local/netpkg-tool -n MyApp
./out/MyApp
```

For other parameters, see the project's main [README](https://github.com/phil-harmoniq/netpkg-tool/blob/master/README.md).
