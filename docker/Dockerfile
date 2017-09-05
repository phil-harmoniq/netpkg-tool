# Dockerfile for creating a Docker image that contains the .NET Core app as AppImage
# It makes use of multi-stage builds and requires Docker 17.05 or later:
# https://docs.docker.com/engine/userguide/eng-image/multistage-build/

# Builder image
# Don't bother to clean up the image - it's only used for building

FROM microsoft/dotnet:2.0-sdk as builder

# The following line is needed as long as the AppImage gets created in build.sh.
# Make use of Docker layering: cached layer
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libglib2.0-0

WORKDIR /dotnetapp
# Make use of Docker layering: cached layer
COPY netpkg-tool.csproj .
RUN dotnet restore netpkg-tool.csproj
# Make use of Docker layering: new layer
COPY . .
RUN mkdir -p artifacts \
    # RUN without "bash" leads to sh being used, which leads to an error ("scripts/build.sh not found")
    && bash build.sh artifacts \
    # Extract AppImage for use in runtime image, because FUSE doesn't work in Docker containers
    && artifacts/netpkg-tool --appimage-extract \
    && rm artifacts/netpkg-tool \
    && mv squashfs-root artifacts/netpkg-tool

# Runtime image

# SDK image needed because netpkg-tool relies on it, for example for executing `dotnet publish ...`
FROM microsoft/dotnet:2.0-sdk

LABEL maintainer "Phil Hawkins"

# Needed for creating an AppImage
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root/netpkg-tool
COPY --from=builder /dotnetapp/artifacts/netpkg-tool .

# Default parameters
# Requires Docker host to mount local directories as volumes and map to "/root/src" and "/root/out"
ENTRYPOINT ["./AppRun", "/root/src", "/root/out"]
