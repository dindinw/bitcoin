cmake_minimum_required(VERSION 3.11)
project(bitcoin-tx)

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

# Boost
MESSAGE(STATUS "try Found boost libraries")
FIND_PACKAGE(Boost REQUIRED COMPONENTS
        thread
        filesystem)


# HAVE_CONFIG_H
add_definitions(-DHAVE_CONFIG_H)
add_definitions(-DBUILD_BITCOIN_INTERNAL)

include_directories(../../src)

include_directories(../../src/compat)
include_directories(../../src/config)
include_directories(../../src/consensus)
include_directories(../../src/crypto)
include_directories(../../src/crypto/ctaes)
include_directories(../../src/index)
include_directories(../../src/interfaces)

# levedb, should be a libary
include_directories(../../src/leveldb/include)
include_directories(../../src/leveldb/include/leveldb)
include_directories(../../src/leveldb/helpers/memenv)

include_directories(../../src/obj)
include_directories(../../src/policy)
include_directories(../../src/primitives)

include_directories(../../src/rpc)
include_directories(../../src/script)
include_directories(../../src/secp256k1/contrib)
include_directories(../../src/secp256k1/include)
include_directories(../../src/secp256k1/src/modules)
include_directories(../../src/secp256k1/src/modules/ecdh)
include_directories(../../src/secp256k1/src/modules/recovery)

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
        ../../src/bitcoin-tx.cpp
        ../../src/addrdb.cpp
        ../../src/addrdb.h
        ../../src/addrman.cpp
        ../../src/addrman.h
        ../../src/amount.h
        ../../src/arith_uint256.cpp
        ../../src/arith_uint256.h
        ../../src/base58.cpp
        ../../src/base58.h
        ../../src/bech32.cpp
        ../../src/bech32.h
        ../../src/blockencodings.cpp
        ../../src/blockencodings.h
        ../../src/blockfilter.cpp
        ../../src/blockfilter.h
        ../../src/bloom.cpp
        ../../src/bloom.h
        ../../src/chain.cpp
        ../../src/chain.h
        ../../src/chainparams.cpp
        ../../src/chainparams.h
        ../../src/chainparamsbase.cpp
        ../../src/chainparamsbase.h
        ../../src/chainparamsseeds.h
        ../../src/checkpoints.cpp
        ../../src/checkpoints.h
        ../../src/checkqueue.h
        ../../src/clientversion.cpp
        ../../src/clientversion.h
        ../../src/coins.cpp
        ../../src/coins.h
        ../../src/compat.h
        ../../src/compressor.cpp
        ../../src/compressor.h
        ../../src/core_io.h
        ../../src/core_memusage.h
        ../../src/core_read.cpp
        ../../src/core_write.cpp
        ../../src/cuckoocache.h
        ../../src/dbwrapper.cpp
        ../../src/dbwrapper.h
        ../../src/dummywallet.cpp
        ../../src/fs.cpp
        ../../src/fs.h
        ../../src/hash.cpp
        ../../src/hash.h
        ../../src/httprpc.cpp
        ../../src/httprpc.h
        ../../src/httpserver.cpp
        ../../src/httpserver.h
        ../../src/indirectmap.h
        ../../src/init.cpp
        ../../src/init.h
        ../../src/key.cpp
        ../../src/key.h
        ../../src/key_io.cpp
        ../../src/key_io.h
        ../../src/keystore.cpp
        ../../src/keystore.h
        ../../src/limitedmap.h
        ../../src/logging.cpp
        ../../src/logging.h
        ../../src/memusage.h
        ../../src/merkleblock.cpp
        ../../src/merkleblock.h
        ../../src/miner.cpp
        ../../src/miner.h
        ../../src/net.cpp
        ../../src/net.h
        ../../src/net_processing.cpp
        ../../src/net_processing.h
        ../../src/netaddress.cpp
        ../../src/netaddress.h
        ../../src/netbase.cpp
        ../../src/netbase.h
        ../../src/netmessagemaker.h
        ../../src/noui.cpp
        ../../src/noui.h
        ../../src/outputtype.cpp
        ../../src/outputtype.h
        ../../src/compat/sanity.h
        ../../src/compat/glibc_sanity.cpp
        ../../src/compat/glibcxx_sanity.cpp
        #../../src/crypto/ctaes/ctaes.c
        #../../src/crypto/ctaes/ctaes.h
        ../../src/crypto/aes.cpp
        ../../src/crypto/aes.h
        ../../src/crypto/chacha20.cpp
        ../../src/crypto/chacha20.h
        ../../src/crypto/common.h
        ../../src/crypto/hmac_sha256.cpp
        ../../src/crypto/hmac_sha256.h
        ../../src/crypto/hmac_sha512.cpp
        ../../src/crypto/hmac_sha512.h
        ../../src/crypto/ripemd160.cpp
        ../../src/crypto/ripemd160.h
        ../../src/crypto/sha1.cpp
        ../../src/crypto/sha1.h
        ../../src/crypto/sha256.cpp
        ../../src/crypto/sha256.h
        #../../src/crypto/sha256_avx2.cpp
        ../../src/crypto/sha256_shani.cpp
        ../../src/crypto/sha256_sse4.cpp
        #../../src/crypto/sha256_sse41.cpp
        ../../src/crypto/sha512.cpp
        ../../src/crypto/sha512.h
        ../../src/index/base.cpp
        ../../src/index/base.h
        ../../src/index/txindex.cpp
        ../../src/index/txindex.h
        ../../src/script/bitcoinconsensus.cpp
        ../../src/script/bitcoinconsensus.h
        ../../src/script/descriptor.cpp
        ../../src/script/descriptor.h
        ../../src/script/interpreter.cpp
        ../../src/script/interpreter.h
        ../../src/script/ismine.cpp
        ../../src/script/ismine.h
        ../../src/script/script.cpp
        ../../src/script/script.h
        ../../src/script/script_error.cpp
        ../../src/script/script_error.h
        ../../src/script/sigcache.cpp
        ../../src/script/sigcache.h
        ../../src/script/sign.cpp
        ../../src/script/sign.h
        ../../src/script/standard.cpp
        ../../src/script/standard.h
        ../../src/pow.cpp
        ../../src/pow.h
        ../../src/prevector.h
        ../../src/protocol.cpp
        ../../src/protocol.h
        ../../src/pubkey.cpp
        ../../src/pubkey.h
        ../../src/random.cpp
        ../../src/random.h
        ../../src/rest.cpp
        ../../src/rpc/blockchain.cpp
        ../../src/rpc/blockchain.h
        ../../src/rpc/client.cpp
        ../../src/rpc/client.h
        ../../src/rpc/mining.cpp
        ../../src/rpc/mining.h
        ../../src/rpc/misc.cpp
        ../../src/rpc/net.cpp
        ../../src/rpc/protocol.cpp
        ../../src/rpc/protocol.h
        ../../src/rpc/rawtransaction.cpp
        ../../src/rpc/rawtransaction.h
        ../../src/rpc/register.h
        ../../src/rpc/server.cpp
        ../../src/rpc/server.h
        ../../src/rpc/util.cpp
        ../../src/rpc/util.h

        ../../src/policy/feerate.cpp
        ../../src/policy/feerate.h
        ../../src/policy/fees.cpp
        ../../src/policy/fees.h
        ../../src/policy/policy.cpp
        ../../src/policy/policy.h
        ../../src/policy/rbf.cpp
        ../../src/policy/rbf.h
        ../../src/primitives/block.cpp
        ../../src/primitives/block.h
        ../../src/primitives/transaction.cpp
        ../../src/primitives/transaction.h
        ../../src/consensus/consensus.h
        ../../src/consensus/merkle.cpp
        ../../src/consensus/merkle.h
        ../../src/consensus/params.h
        ../../src/consensus/tx_verify.cpp
        ../../src/consensus/tx_verify.h
        ../../src/consensus/validation.h
        ../../src/support/allocators/secure.h
        ../../src/support/allocators/zeroafterfree.h
        ../../src/support/cleanse.cpp
        ../../src/support/cleanse.h
        ../../src/support/events.h
        ../../src/support/lockedpool.cpp
        ../../src/support/lockedpool.h

        ../../src/zmq/zmqabstractnotifier.cpp
        ../../src/zmq/zmqabstractnotifier.h
        ../../src/zmq/zmqconfig.h
        ../../src/zmq/zmqnotificationinterface.cpp
        ../../src/zmq/zmqnotificationinterface.h
        ../../src/zmq/zmqpublishnotifier.cpp
        ../../src/zmq/zmqpublishnotifier.h
        ../../src/zmq/zmqrpc.cpp
        ../../src/zmq/zmqrpc.h

        ../../src/reverse_iterator.h
        ../../src/reverselock.h
        ../../src/scheduler.cpp
        ../../src/scheduler.h
        ../../src/serialize.h
        ../../src/shutdown.cpp
        ../../src/shutdown.h
        ../../src/span.h
        ../../src/streams.h
        ../../src/sync.cpp
        ../../src/sync.h
        ../../src/threadinterrupt.cpp
        ../../src/threadinterrupt.h
        ../../src/threadsafety.h
        ../../src/timedata.cpp
        ../../src/timedata.h
        ../../src/tinyformat.h
        ../../src/torcontrol.cpp
        ../../src/torcontrol.h
        ../../src/txdb.cpp
        ../../src/txdb.h
        ../../src/txmempool.cpp
        ../../src/txmempool.h
        ../../src/ui_interface.cpp
        ../../src/ui_interface.h
        ../../src/uint256.cpp
        ../../src/uint256.h
        ../../src/undo.h
        ../../src/util/system.cpp
        ../../src/util/system.h
        ../../src/util/memory.h
        ../../src/util/moneystr.cpp
        ../../src/util/moneystr.h
        ../../src/util/strencodings.cpp
        ../../src/util/strencodings.h
        ../../src/util/time.cpp
        ../../src/util/time.h
        ../../src/validation.cpp
        ../../src/validation.h
        ../../src/validationinterface.cpp
        ../../src/validationinterface.h
        ../../src/version.h
        ../../src/versionbits.cpp
        ../../src/versionbits.h
        ../../src/versionbitsinfo.cpp
        ../../src/versionbitsinfo.h
        ../../src/walletinitinterface.h
        ../../src/warnings.cpp
        ../../src/warnings.h)


target_link_libraries(${PROJECT_NAME} 
        ${CMAKE_CURRENT_SOURCE_DIR}/../../src/univalue/.libs/libunivalue.a
        ${CMAKE_CURRENT_SOURCE_DIR}/../../src/leveldb/libleveldb.a
        ${CMAKE_CURRENT_SOURCE_DIR}/../../src/leveldb/libleveldb_sse42.a
        ${CMAKE_CURRENT_SOURCE_DIR}/../../src/leveldb/libmemenv.a
        ${CMAKE_CURRENT_SOURCE_DIR}/../../src/secp256k1/.libs/libsecp256k1.a
        crypto
        miniupnpc
        event
        event_pthreads
        ${Boost_LIBRARIES}
        zmq
        )
