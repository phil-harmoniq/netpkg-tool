# Use an official .NET Core image from Microsoft
FROM microsoft/dotnet:2.0-sdk

# Install dependencies for appimagetool
RUN apt-get update && apt-get install -y libglib2.0-0

# Set the working directory to /netpkg-build
WORKDIR /netpkg-build

# Copy the current directory contents into the container
ADD . /netpkg-build

# Build netpkg-tol using build script
RUN bash /netpkg-build/build.sh /netpkg-build

# Extract netpkg-tool when complete (FUSE incompatibility)
CMD ["/netpkg-build/netpkg-tool", "--appimage-extract"]
CMD ["mv", "/netpkg-build/squashfs-root", "/"]
CMD ["mv", "/squashfs-root", "/netpkg-tool"]

ENTRYPOINT ["ls -lhaF"]
