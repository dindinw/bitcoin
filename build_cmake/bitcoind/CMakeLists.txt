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

cmake_minimum_required(VERSION 3.11)
project(bitcoind)

set(CMAKE_CXX_STANDARD 14)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../CMakeModules")

# open-ssl
MESSAGE(STATUS "try Found open-ssl libraries")
# add defaults for openssl
if ("${OPENSSL_ROOT_DIR}" STREQUAL "")
    if (NOT "$ENV{OPENSSL_ROOT_DIR}" STREQUAL "")
        set(OPENSSL_ROOT_DIR $ENV{OPENSSL_ROOT_DIR})
        set(OPENSSL_INCLUDE_DIR ${OPENSSL_ROOT_DIR}/include)
    elseif (APPLE)
        set(OPENSSL_ROOT_DIR "/usr/local/opt/openssl")
        set(OPENSSL_INCLUDE_DIR "/usr/local/opt/openssl/include")
        MESSAGE(STATUS "Found open-ssl libraries ${OPENSSL_ROOT_DIR}")
        include_directories(${OPENSSL_INCLUDE_DIR})
    elseif(UNIX AND NOT APPLE)
        set(OPENSSL_ROOT_DIR "/usr/include/openssl")
        set(OPENSSL_INCLUDE_DIR "/usr/include/openssl/include")
    else()
        message(FATAL_ERROR "openssl not found and don't know where to look, please specify OPENSSL_ROOT_DIR")
    endif()
endif()

# berkeley-db 4
MESSAGE(STATUS "try Found libdb libraries")

FIND_PACKAGE( libdb_cxx REQUIRED)
IF (LIBDB_CXX_INCLUDE_DIR AND LIBDB_CXX_LIBRARIES)
    MESSAGE(STATUS "Found libdb include dir ${LIBDB_CXX_INCLUDE_DIR} and lib ${LIBDB_CXX_LIBRARIES}")
    include_directories(${LIBDB_CXX_INCLUDE_DIR})
ENDIF (LIBDB_CXX_INCLUDE_DIR AND LIBDB_CXX_LIBRARIES)

# Boost
MESSAGE(STATUS "try Found boost libraries")
FIND_PACKAGE(Boost REQUIRED COMPONENTS
        thread
        filesystem)



include_directories(../../src)

include_directories(../../src/compat)
include_directories(../../src/config)
include_directories(../../src/consensus)
include_directories(../../src/crypto)
include_directories(../../src/crypto/ctaes)
include_directories(../../src/index)
include_directories(../../src/interfaces)

include_directories(../../src/leveldb/include)
include_directories(../../src/leveldb/include/leveldb)
include_directories(../../src/leveldb/helpers/memenv)

include_directories(../../src/obj)
include_directories(../../src/policy)
include_directories(../../src/primitives)

include_directories(../../src/rpc)
include_directories(../../src/script)


include_directories(../../src/support)
include_directories(../../src/support/allocators)

include_directories(../../src/test)
include_directories(../../src/test/data)
include_directories(../../src/test/gen)

include_directories(../../src/univalue)
include_directories(../../src/univalue/include)
include_directories(../../src/univalue/lib)

include_directories(../../src/wallet)
include_directories(../../src/wallet/test)
include_directories(../../src/zmq)

add_executable(${PROJECT_NAME}
        ../../src/addrdb.cpp
        ../../src/addrman.cpp
        ../../src/arith_uint256.cpp
        ../../src/base58.cpp
        ../../src/bech32.cpp
        ../../src/blockencodings.cpp
        ../../src/blockfilter.cpp
        ../../src/bloom.cpp
        ../../src/bitcoind.cpp
        ../../src/chain.cpp
        ../../src/chainparams.cpp
        ../../src/chainparamsbase.cpp
        ../../src/checkpoints.cpp
        ../../src/clientversion.cpp
        ../../src/coins.cpp
        ../../src/compressor.cpp
        ../../src/core_read.cpp
        ../../src/core_write.cpp
        ../../src/dbwrapper.cpp
        ../../src/fs.cpp
        ../../src/hash.cpp
        ../../src/httprpc.cpp
        ../../src/httpserver.cpp
        ../../src/init.cpp
        ../../src/key.cpp
        ../../src/key_io.cpp
        ../../src/keystore.cpp
        ../../src/logging.cpp
        ../../src/merkleblock.cpp
        ../../src/miner.cpp
        ../../src/net.cpp
        ../../src/net_processing.cpp
        ../../src/netaddress.cpp
        ../../src/netbase.cpp
        ../../src/noui.cpp
        ../../src/outputtype.cpp
        ../../src/pow.cpp
        ../../src/protocol.cpp
        ../../src/pubkey.cpp
        ../../src/random.cpp
        ../../src/rest.cpp
        ../../src/scheduler.cpp
        ../../src/serialize.h
        ../../src/shutdown.cpp
        ../../src/sync.cpp
        ../../src/threadinterrupt.cpp
        ../../src/timedata.cpp
        ../../src/torcontrol.cpp
        ../../src/txdb.cpp
        ../../src/txmempool.cpp
        ../../src/ui_interface.cpp
        ../../src/uint256.cpp
        ../../src/validation.cpp
        ../../src/validationinterface.cpp
        ../../src/versionbits.cpp
        ../../src/versionbitsinfo.cpp
        ../../src/warnings.cpp

        ../../src/compat/glibc_sanity.cpp
        ../../src/compat/glibcxx_sanity.cpp

        #../../src/crypto/ctaes/ctaes.c
        ../../src/crypto/aes.cpp
        ../../src/crypto/chacha20.cpp
        ../../src/crypto/hmac_sha256.cpp
        ../../src/crypto/hmac_sha512.cpp
        ../../src/crypto/ripemd160.cpp
        ../../src/crypto/sha1.cpp
        ../../src/crypto/sha256.cpp
        #../../src/crypto/sha256_avx2.cpp
        ../../src/crypto/sha256_shani.cpp
        ../../src/crypto/sha256_sse4.cpp
        #../../src/crypto/sha256_sse41.cpp
        ../../src/crypto/sha512.cpp
        ../../src/crypto/siphash.cpp

        ../../src/index/base.cpp
        ../../src/index/txindex.cpp

        ../../src/interfaces/chain.cpp
        ../../src/interfaces/handler.cpp
        ../../src/interfaces/node.cpp
        ../../src/interfaces/wallet.cpp

        ../../src/script/bitcoinconsensus.cpp
        ../../src/script/descriptor.cpp
        ../../src/script/interpreter.cpp
        ../../src/script/ismine.cpp
        ../../src/script/script.cpp
        ../../src/script/script_error.cpp
        ../../src/script/sigcache.cpp
        ../../src/script/sign.cpp
        ../../src/script/standard.cpp

        ../../src/rpc/blockchain.cpp
        ../../src/rpc/client.cpp
        ../../src/rpc/mining.cpp
        ../../src/rpc/misc.cpp
        ../../src/rpc/net.cpp
        ../../src/rpc/protocol.cpp
        ../../src/rpc/rawtransaction.cpp
        ../../src/rpc/server.cpp
        ../../src/rpc/util.cpp

        ../../src/policy/feerate.cpp
        ../../src/policy/fees.cpp
        ../../src/policy/policy.cpp
        ../../src/policy/rbf.cpp

        ../../src/primitives/block.cpp
        ../../src/primitives/transaction.cpp

        ../../src/consensus/merkle.cpp
        ../../src/consensus/tx_verify.cpp

        ../../src/support/cleanse.cpp
        ../../src/support/lockedpool.cpp

        ../../src/zmq/zmqabstractnotifier.cpp
        ../../src/zmq/zmqnotificationinterface.cpp
        ../../src/zmq/zmqpublishnotifier.cpp
        ../../src/zmq/zmqrpc.cpp

        ../../src/wallet/coincontrol.cpp
        ../../src/wallet/coinselection.cpp
        ../../src/wallet/crypter.cpp
        ../../src/wallet/db.cpp
        ../../src/wallet/feebumper.cpp
        ../../src/wallet/fees.cpp
        ../../src/wallet/init.cpp
        ../../src/wallet/rpcdump.cpp
        ../../src/wallet/rpcwallet.cpp
        ../../src/wallet/wallet.cpp
        ../../src/wallet/walletdb.cpp
        ../../src/wallet/walletutil.cpp

        ../../src/util/bytevectorhash.cpp
        ../../src/util/system.cpp
        ../../src/util/moneystr.cpp
        ../../src/util/strencodings.cpp
        ../../src/util/time.cpp)


add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../libunivalue ${CMAKE_CURRENT_BINARY_DIR}/libunivalue)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../libleveldb  ${CMAKE_CURRENT_BINARY_DIR}/libleveldb)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../libsecp256k1  ${CMAKE_CURRENT_BINARY_DIR}/libsecp256k1)

target_link_libraries(${PROJECT_NAME}
        PRIVATE univalue
        PRIVATE leveldb
        PRIVATE leveldb_sse42
        PRIVATE memenv
        PRIVATE secp256k1
        crypto
        miniupnpc
        event
        event_pthreads
        ${Boost_LIBRARIES}
        zmq
        ${LIBDB_CXX_LIBRARIES}
        )
target_compile_definitions(${PROJECT_NAME} PRIVATE -DHAVE_CONFIG_H)
target_compile_definitions(${PROJECT_NAME} PRIVATE -DBUILD_BITCOIN_INTERNAL)  # required from SHA256AutoDetect() sha256.cpp
target_include_directories(${PROJECT_NAME} PRIVATE ../../src/secp256k1/include)

