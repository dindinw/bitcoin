# Windows Build: (test on Win10 + VS2017)

## 1.) Install Dependes by using `vcpkg` :
```
  vcpkg install berkeleydb:x64-windows-static
  vcpkg install boost:x64-windows-static
  vcpkg install openssl:x64-windows-static
  vcpkg install libevent:x64-windows-static
  vcpkg install zeromq:x64-windows-static
```
 The vcpkg installed static libs speretely on the folder : <vcpkg_root>\installed\x64-windows-static\

##  2.) Toolchain configuation
  - The toolchain need to specify the architecture to match with x64 (instead of the x86 by default for CLion)
  - /MD flag MD_DynamicRelease should be RuntimeLibrary -> swich to /MT
    https://docs.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library?view=vs-2017
    https://github.com/Kitware/CMake/blob/v3.13.2/Modules/Platform/Windows-MSVC.cmake#L362
  - NDEBUG on Release
    - the cmake add the NDEBUG define https://github.com/Kitware/CMake/blob/v3.13.2/Modules/Platform/Windows-MSVC.cmake#L362
    - net_processing.cpp (#if defined(NDEBUG))
    - validation.cpp (#if defined(NDEBUG))

## 3.) fix Code :
  - need to fix non-portable usage in the bitcoin's leveldb code
    - remove non-portable headers <sys/types.h> and <unistd.h>  in db/c.cc db/c_test.c
      - https://github.com/google/leveldb/commit/623d014a54f8cf9b74ad6aaba9181ca1e65c43a1
    - remove ssize in db/db_iter.cc
      - https://github.com/google/leveldb/commit/89af27bde59fbbb3025653812b45fec10a655cb7
      - remove #define snprintf _snprintf in port/port_win.h
  - refactor unicode filename wrapper (src/fs.cpp src/fs.h src/test/fs_test.cpp)
    - https://github.com/bitcoin/bitcoin/pull/13878/
    - https://github.com/bitcoin/bitcoin/issues/13869
  - test-bitcion have 2 failed tests on the unicode filename
      - fixed by using the /utf-8 flag to MSVC

## 4.) Fix linker
  - need to add ws2_32 and shlwapi to linker
    - __imp__PathFileExistsW -> shlwapi.lib
    - net.cpp (FD_ISSET) -> ws2_32.lib
  - need link crypt32.lib (if static link openssl)
    - libeay32.lib __imp_CertOpenStore -> crypt32.lib
  - need Iphlpapi.lib for test-bitcoin

## 5.) Warnings
  - https://github.com/bitcoin/bitcoin/pull/14151
