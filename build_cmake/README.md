# How To Use

## Linux/Mac
```
   $ cd bitcoin\build_cmake && mkdir build && cd build
   $ cmake ..
   $ make
   $ make check-bitcoin
```

## Windows

### Windows (32bits) :

```
   >PS cd bitcoin\build_cmake
   >PS mkdir build32
   >PS cd build32
   >PS cmake .. -G "Visual Studio 15 2017" -DVCPKG_TRIPLE=<vcpkg_home>\installed\x86-windowns-static
   >PS cmake --build .
   >PS cmake --build . --target check-bitcoin
```

###  Windows (64bits) :

```
   >PS cd bitcoin\build_cmake
   >PS mkdir build64
   >PS cd build64
   >PS cmake .. -G "Visual Studio 15 2017 Win64" -DVCPKG_TRIPLE=<vcpkg_home>\installed\x64-windowns-static
   >PS cmake --build .
   >PS cmake --build . --target check-bitcoin
```
## Note for dependecies :

The depends can be installed by apt-get(linux) ,brew (Mac) and vcpkg (Windows)
see following doc for details
   - [linux][../doc/build-unix.md]
   - [mac][../doc/build-osx.md]

For Windows depends build and installation:
   - 32bits :

```
     >PS .\vcpkg install berkeleydb:x86-windows-static `
                       boost:x86-windows-static `
                       openssl:x86-windows-static `
                       libevent:x86-windows-static `
                       zeromq:x86-windows-static
```
   - 64bits :
```
     >PS .\vcpkg install berkeleydb:x64-windows-static `
                       boost:x64-windows-static `
                       openssl:x64-windows-static `
                       libevent:x64-windows-static `
                       zeromq:x64-windows-static `
```
