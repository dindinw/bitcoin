# MacOS

#### -DSTATIC_BUILD=on (but depends might not all static)

```
$ otool -L test_bitcoin/test_bitcoin
test_bitcoin/test_bitcoin:
        /usr/local/opt/berkeley-db@4/lib/libdb_cxx-4.8.dylib (compatibility version 0.0.0, current version 0.0.0)
        /usr/local/opt/libevent/lib/libevent-2.1.6.dylib (compatibility version 7.0.0, current version 7.2.0)
        /usr/local/opt/libevent/lib/libevent_core-2.1.6.dylib (compatibility version 7.0.0, current version 7.2.0)
        /usr/local/opt/libevent/lib/libevent_extra-2.1.6.dylib (compatibility version 7.0.0, current version 7.2.0)
        /usr/local/opt/libevent/lib/libevent_pthreads-2.1.6.dylib (compatibility version 7.0.0, current version 7.2.0)
        /usr/local/opt/libevent/lib/libevent_openssl-2.1.6.dylib (compatibility version 7.0.0, current version 7.2.0)
        /usr/local/opt/zeromq/lib/libzmq.5.dylib (compatibility version 7.0.0, current version 7.5.0)
        /usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 400.9.0)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.50.4)
```

#### -DSTATIC_BUILD=off (all dynmatic)

```
$ otool -L test_bitcoin/test_bitcoin
test_bitcoin/test_bitcoin:
        /usr/local/opt/boost/lib/libboost_unit_test_framework-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
        /usr/local/opt/boost/lib/libboost_filesystem-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
        /usr/local/opt/boost/lib/libboost_system-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
        /usr/local/opt/boost/lib/libboost_thread-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
        /usr/local/opt/boost/lib/libboost_chrono-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
        /usr/local/opt/berkeley-db@4/lib/libdb_cxx-4.8.dylib (compatibility version 0.0.0, current version 0.0.0)
        /usr/local/opt/libevent/lib/libevent-2.1.6.dylib (compatibility version 7.0.0, current version 7.2.0)
        /usr/local/opt/libevent/lib/libevent_core-2.1.6.dylib (compatibility version 7.0.0, current version 7.2.0)
        /usr/local/opt/libevent/lib/libevent_extra-2.1.6.dylib (compatibility version 7.0.0, current version 7.2.0)
        /usr/local/opt/libevent/lib/libevent_pthreads-2.1.6.dylib (compatibility version 7.0.0, current version 7.2.0)
        /usr/local/opt/libevent/lib/libevent_openssl-2.1.6.dylib (compatibility version 7.0.0, current version 7.2.0)
        /usr/local/opt/zeromq/lib/libzmq.5.dylib (compatibility version 7.0.0, current version 7.5.0)
        /usr/local/opt/boost/lib/libboost_date_time-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
        /usr/local/opt/boost/lib/libboost_atomic-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
        /usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 400.9.0)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.50.4)
```


#### the pure static version (with all depends are static)

using Xcode's gcc

```
$ otool -L ./bitcoind
./bitcoind:
        /usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 400.9.0)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.50.4)

```

#### using GNU gcc (more pure static version)

we can also remove the libc++ depends, only required System.B

```
$ otool -L  bitcoind/bitcoind
bitcoind/bitcoind:
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.50.4)
```

#### Can we remove System.B ?

Its depends


#### Notes on using `-static`

Using -static is impossible, since the linker tries to statically link the standard library as well, which is prohibited in OSX. On the other hand, clang doesn't know -Wl,-Bstatic.

There's no crt0.o or crt0.a or anything like that on OS X and XCode.


```
ld: library not found for -lcrt0.o
```



# Linux

## The Download Version from

https://bitcoin.org/bin/bitcoin-core-0.17.1/bitcoin-0.17.1-x86_64-linux-gnu.tar.gz

```
alex@lfs:~/work$ sha256sum bitcoin-0.17.1-x86_64-linux-gnu.tar.gz
53ffca45809127c9ba33ce0080558634101ec49de5224b2998c489b6d0fc2b17  bitcoin-0.17.1-x86_64-linux-gnu.tar.gz
alex@lfs:~/work$ sha256sum bitcoin-0.17.1/bin/bitcoind
5886026ab5c84145778c1c45e63dbaaad8732923f9e0477885b6505fa6621e6c  bitcoin-0.17.1/bin/bitcoind
alex@lfs:~/work$ ldd bitcoin-0.17.1/bin/bitcoind
        linux-vdso.so.1 (0x00007ffc5fcb6000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x00007f7bcf722000)
        librt.so.1 => /lib/librt.so.1 (0x00007f7bcf718000)
        libm.so.6 => /lib/libm.so.6 (0x00007f7bcf595000)
        libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007f7bcf57b000)
        libc.so.6 => /lib/libc.so.6 (0x00007f7bcf3ba000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f7bd03ea000)
```

```
alex@ubuntu1804:~/work$ sha256sum bitcoin-0.17.1-x86_64-linux-gnu.tar.gz
53ffca45809127c9ba33ce0080558634101ec49de5224b2998c489b6d0fc2b17  bitcoin-0.17.1-x86_64-linux-gnu.tar.gz
alex@ubuntu1804:~/work$ sha256sum bitcoin-0.17.1/bin/bitcoind
5886026ab5c84145778c1c45e63dbaaad8732923f9e0477885b6505fa6621e6c  bitcoin-0.17.1/bin/bitcoind
alex@ubuntu1804:~/work$ ldd bitcoin-0.17.1/bin/bitcoind
        linux-vdso.so.1 (0x00007ffe4c6c7000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007efe6d453000)
        librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007efe6d24b000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007efe6cead000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007efe6cc95000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007efe6c8a4000)
        /lib64/ld-linux-x86-64.so.2 (0x00007efe6e312000)
```

```
alex@ubuntu1604:/work/bitcoin$ sha256sum bitcoin-0.17.1-x86_64-linux-gnu.tar.gz
53ffca45809127c9ba33ce0080558634101ec49de5224b2998c489b6d0fc2b17  bitcoin-0.17.1-x86_64-linux-gnu.tar.gz
alex@ubuntu1604:/work/bitcoin$ sha256sum bitcoin-0.17.1/bin/bitcoind
5886026ab5c84145778c1c45e63dbaaad8732923f9e0477885b6505fa6621e6c  bitcoin-0.17.1/bin/bitcoind
alex@ubuntu1604:/work/bitcoin$ ldd bitcoin-0.17.1/bin/bitcoind
        linux-vdso.so.1 =>  (0x00007fff309de000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f0419d53000)
        librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007f0419b4b000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f0419842000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f041962a000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f0419260000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f041ac10000)
```

it shows the usage of dynamic link libc/libgcc

## Ubuntu 1804

-static-libstdc++

```
alex@ubuntu1804:~/work/bitcoin-ubuntu1804/build_cmake/build$ ldd bitcoind/bitcoind
        linux-vdso.so.1 (0x00007ffcda3fe000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f0bbb6ca000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f0bbb4ab000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f0bbb10d000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f0bbaef5000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f0bbab04000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f0bbc920000)

```

-static-libgcc -static-libstdc++
```
alex@ubuntu1804:~/work/bitcoin-ubuntu1804/build_cmake/build$ ldd bitcoind/bitcoind
        linux-vdso.so.1 (0x00007ffc945d8000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f01be8b8000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f01be699000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f01be2fb000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f01bdf0a000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f01bfb14000)
```

## Ubuntu 1604

-static-libstdc++

```
alex@ubuntu1604:/work/bitcoin/bitcoin-cmake/build_cmake/build$ ldd bitcoind/bitcoind
        linux-vdso.so.1 =>  (0x00007ffe2fde7000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f8963cf0000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f8963ad3000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f89637ca000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f89635b2000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f89631e8000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f8963ef4000)

```

-static-libgcc -static-libstdc++
```
alex@ubuntu1604:/work/bitcoin/bitcoin-cmake/build_cmake/build$ ldd bitcoind/bitcoind
        linux-vdso.so.1 =>  (0x00007fff5b1e1000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fa92234e000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fa922131000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fa921e28000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fa921a5e000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fa922552000)

```

libgcc should be excluded

## LFS (kernel 4.19.6 & gcc 8.2.0)

-static-libstdc++

```
alex@lfs:~/work/bitcoin/build_cmake/build$ ldd bitcoind/bitcoind
        linux-vdso.so.1 (0x00007ffdf3354000)
        libdl.so.2 => /lib/libdl.so.2 (0x00007f60685fd000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x00007f60685dc000)
        libm.so.6 => /lib/libm.so.6 (0x00007f6068459000)
        libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007f606843f000)
        libc.so.6 => /lib/libc.so.6 (0x00007f606827e000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f6068609000)
```

-static-libgcc -static-libstdc++
```
alex@lfs:~/work/bitcoin/build_cmake/build$ ldd bitcoind/bitcoind
        linux-vdso.so.1 (0x00007ffd67dfc000)
        libdl.so.2 => /lib/libdl.so.2 (0x00007fbafb0a2000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x00007fbafb081000)
        libm.so.6 => /lib/libm.so.6 (0x00007fbafaefe000)
        libc.so.6 => /lib/libc.so.6 (0x00007fbafad3d000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fbafb0ae000)
```
## Linux Static Link issue

### LFS
#### --static

```
/usr/bin/ld: ../libbitcoin_common/libbitcoin_common.a(netbase.cpp.o): in function `LookupIntern(char const*, std::vector<CNetAddr, std::allocator<CNetAddr> >&, unsigned int, bool)':
netbase.cpp:(.text+0x3b0): warning: Using 'getaddrinfo' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
/usr/bin/ld: /usr/lib/libcrypto.a(b_sock.o): in function `BIO_gethostbyname':
b_sock.c:(.text+0x51): warning: Using 'gethostbyname' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
/usr/bin/ld: /usr/lib/libevent.a(evutil.o): in function `evutil_unparse_protoname':
/sources/libevent-2.1.8-stable/evutil.c:911: warning: Using 'getprotobynumber' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
/usr/bin/ld: /usr/lib/libevent.a(evutil.o): in function `evutil_parse_servname':
/sources/libevent-2.1.8-stable/evutil.c:883: warning: Using 'getservbyname' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_globallookup':
dso_dlfcn.c:(.text+0x11): undefined reference to `dlopen'
/usr/bin/ld: dso_dlfcn.c:(.text+0x24): undefined reference to `dlsym'
/usr/bin/ld: dso_dlfcn.c:(.text+0x2f): undefined reference to `dlclose'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_bind_func':
dso_dlfcn.c:(.text+0x1b8): undefined reference to `dlsym'
/usr/bin/ld: dso_dlfcn.c:(.text+0x282): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_load':
dso_dlfcn.c:(.text+0x2e8): undefined reference to `dlopen'
/usr/bin/ld: dso_dlfcn.c:(.text+0x359): undefined reference to `dlclose'
/usr/bin/ld: dso_dlfcn.c:(.text+0x395): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_pathbyaddr':
dso_dlfcn.c:(.text+0x441): undefined reference to `dladdr'
/usr/bin/ld: dso_dlfcn.c:(.text+0x4a1): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_unload':
dso_dlfcn.c:(.text+0x672): undefined reference to `dlclose'
collect2: error: ld returned 1 exit status
make[3]: *** [bitcoind/CMakeFiles/bitcoind.dir/build.make:111: bitcoind/bitcoind] Error 1
make[2]: *** [CMakeFiles/Makefile2:1091: bitcoind/CMakeFiles/bitcoind.dir/all] Error 2
make[1]: *** [CMakeFiles/Makefile2:1103: bitcoind/CMakeFiles/bitcoind.dir/rule] Error 2
make: *** [Makefile:391: bitcoind] Error 2

```


#### -static -static-libgcc -static-libstdc++

```
/usr/bin/ld: ../libbitcoin_common/libbitcoin_common.a(netbase.cpp.o): in function `LookupIntern(char const*, std::vector<CNetAddr, std::allocator<CNetAddr> >&, unsigned int, bool)':
netbase.cpp:(.text+0x3b0): warning: Using 'getaddrinfo' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
/usr/bin/ld: /usr/lib/libcrypto.a(b_sock.o): in function `BIO_gethostbyname':
b_sock.c:(.text+0x51): warning: Using 'gethostbyname' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
/usr/bin/ld: /usr/lib/libevent.a(evutil.o): in function `evutil_unparse_protoname':
/sources/libevent-2.1.8-stable/evutil.c:911: warning: Using 'getprotobynumber' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
/usr/bin/ld: /usr/lib/libevent.a(evutil.o): in function `evutil_parse_servname':
/sources/libevent-2.1.8-stable/evutil.c:883: warning: Using 'getservbyname' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_globallookup':
dso_dlfcn.c:(.text+0x11): undefined reference to `dlopen'
/usr/bin/ld: dso_dlfcn.c:(.text+0x24): undefined reference to `dlsym'
/usr/bin/ld: dso_dlfcn.c:(.text+0x2f): undefined reference to `dlclose'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_bind_func':
dso_dlfcn.c:(.text+0x1b8): undefined reference to `dlsym'
/usr/bin/ld: dso_dlfcn.c:(.text+0x282): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_load':
dso_dlfcn.c:(.text+0x2e8): undefined reference to `dlopen'
/usr/bin/ld: dso_dlfcn.c:(.text+0x359): undefined reference to `dlclose'
/usr/bin/ld: dso_dlfcn.c:(.text+0x395): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_pathbyaddr':
dso_dlfcn.c:(.text+0x441): undefined reference to `dladdr'
/usr/bin/ld: dso_dlfcn.c:(.text+0x4a1): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_unload':
dso_dlfcn.c:(.text+0x672): undefined reference to `dlclose'
collect2: error: ld returned 1 exit status
make[3]: *** [bitcoind/CMakeFiles/bitcoind.dir/build.make:111: bitcoind/bitcoind] Error 1
make[2]: *** [CMakeFiles/Makefile2:1091: bitcoind/CMakeFiles/bitcoind.dir/all] Error 2
make[1]: *** [CMakeFiles/Makefile2:1103: bitcoind/CMakeFiles/bitcoind.dir/rule] Error 2
make: *** [Makefile:391: bitcoind] Error 2

```

#### -static-libstdc++

```
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_globallookup':
dso_dlfcn.c:(.text+0x11): undefined reference to `dlopen'
/usr/bin/ld: dso_dlfcn.c:(.text+0x24): undefined reference to `dlsym'
/usr/bin/ld: dso_dlfcn.c:(.text+0x2f): undefined reference to `dlclose'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_bind_func':
dso_dlfcn.c:(.text+0x1b8): undefined reference to `dlsym'
/usr/bin/ld: dso_dlfcn.c:(.text+0x282): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_load':
dso_dlfcn.c:(.text+0x2e8): undefined reference to `dlopen'
/usr/bin/ld: dso_dlfcn.c:(.text+0x359): undefined reference to `dlclose'
/usr/bin/ld: dso_dlfcn.c:(.text+0x395): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_pathbyaddr':
dso_dlfcn.c:(.text+0x441): undefined reference to `dladdr'
/usr/bin/ld: dso_dlfcn.c:(.text+0x4a1): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_unload':
dso_dlfcn.c:(.text+0x672): undefined reference to `dlclose'
collect2: error: ld returned 1 exit status
make[3]: *** [bitcoind/CMakeFiles/bitcoind.dir/build.make:111: bitcoind/bitcoind] Error 1
make[2]: *** [CMakeFiles/Makefile2:1091: bitcoind/CMakeFiles/bitcoind.dir/all] Error 2
make[1]: *** [CMakeFiles/Makefile2:1103: bitcoind/CMakeFiles/bitcoind.dir/rule] Error 2
make: *** [Makefile:391: bitcoind] Error 2
```

Add `-ldl` to linker make it works

```
$ ldd bitcoind/bitcoind
        linux-vdso.so.1 (0x00007fffdd3f5000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x00007f8a5aa19000)
        libdl.so.2 => /lib/libdl.so.2 (0x00007f8a5aa14000)
        libm.so.6 => /lib/libm.so.6 (0x00007f8a5a891000)
        libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007f8a5a877000)
        libc.so.6 => /lib/libc.so.6 (0x00007f8a5a6b6000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f8a5aa41000)
$ ldd ../../../bitcoin-0.17.0/bin/bitcoind
        linux-vdso.so.1 (0x00007ffd49dd7000)
        libpthread.so.0 => /lib/libpthread.so.0 (0x00007feefcb11000)
        librt.so.1 => /lib/librt.so.1 (0x00007feefcb07000)
        libm.so.6 => /lib/libm.so.6 (0x00007feefc984000)
        libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007feefc96a000)
        libc.so.6 => /lib/libc.so.6 (0x00007feefc7a9000)
        /lib64/ld-linux-x86-64.so.2 (0x00007feefd7d7000)

```

the reason

> `-ldl` is an indirect dependency when using `-lcrypto` (on Linux). Because you are linking to a static version of libcrypto

> `-ldl` tells the linker to also link against libdl.so, which is the shared library containing  dlopen(), dlsym(), dlclose() etc.


# Windows
