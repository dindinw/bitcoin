# The default ./configure
# Options used to compile and link:
#  with wallet   = yes
#  with gui / qt = yes
#    with bip70  = yes
#    with qr     = yes
#  with zmq      = yes
#  with test     = yes
#  with bench    = yes
#  with upnp     = yes
#  use asm       = yes
#  sanitizers    =
#  debug enabled = no
#  gprof enabled = no
#  werror        = no
#
#  target os     = darwin
#  build os      = darwin
#
#  CC            = gcc
#  CFLAGS        = -g -O2
#  CPPFLAGS      =   -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2  -DHAVE_BUILD_INFO -D__STDC_FORMAT_MACROS -I/usr/local/opt/berkeley-db@4/include -DMAC_OSX
#  CXX           = g++ -std=c++11
#  CXXFLAGS      =   -Wstack-protector -fstack-protector-all  -Wall -Wextra -Wformat -Wvla -Wformat-security -Wthread-safety-analysis -Wrange-loop-analysis -Wredundant-decls  -Wno-unused-parameter -Wno-self-assign -Wno-unused-local-typedef -Wno-deprecated-register -Wno-implicit-fallthrough   -g -O2
#  LDFLAGS       = -pthread    -Wl,-headerpad_max_install_names -Wl,-dead_strip
#  ARFLAGS       = cr
#

add_executable(bitcoind ../../src/bitcoind.cpp )

list(APPEND bitcoind_LIBRARIES bitcoin_server )

if(ENABLE_WALLET)
    list(APPEND bitcoind_LIBRARIES bitcoin_wallet)
endif()

list(APPEND bitcoind_LIBRARIES
        bitcoin_common
        univalue
        bitcoin_util
        bitcoin_consensus
        bitcoin_crypto
)

if(ENABLE_ZMQ)
    list(APPEND bitcoind_LIBRARIES
        bitcoin_zmq {ZMQ_LIBRARIES})
endif()

if(USE_UPNP)
    set(LIB_MINIUPNP miniupnpc)
endif()

list(APPEND bitcoind_LIBRARIES
        leveldb
        leveldb_sse42
        memenv
        secp256k1
        Boost::filesystem
        Boost::system
        Boost::thread
        Boost::chrono
        ${LIBDB_CXX_LIBRARIES}
        OpenSSL::Crypto
        ${LIB_MINIUPNP}
        ${LIBEVENT_LIBRARIES}
)

if(WIN32)
    list(APPEND bitcoind_LIBRARIES ws2_32 shlwapi crypt32)
endif()

target_link_libraries(bitcoind PRIVATE ${bitcoind_LIBRARIES})


target_compile_definitions(bitcoind PRIVATE -DHAVE_CONFIG_H)
target_include_directories(bitcoind PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
        ${BITCOIN_ROOT}/src/secp256k1/include
        ${Boost_INCLUDE_DIRS}
)
