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

