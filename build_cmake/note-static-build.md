## MacOS


#### -DSTATIC_BUILD=on

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

#### -DSTATIC_BUILD=off

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


#### the work version


```
$ otool -L ./bitcoind
./bitcoind:
        /usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 400.9.0)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.50.4)

```

####  -static

Using -static is impossible, since the linker tries to statically link the standard library as well, which is prohibited in OSX. On the other hand, clang doesn't know -Wl,-Bstatic.

There's no crt0.o or crt0.a or anything like that on OS X and XCode.


```
ld: library not found for -lcrt0.o
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


### Ubuntu 1804

```

```
