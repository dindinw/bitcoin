
list(APPEND libbitcoin_common_SOURCES
        ../../src/base58.cpp
        ../../src/bech32.cpp
        ../../src/chainparams.cpp
        ../../src/coins.cpp
        ../../src/compressor.cpp
        ../../src/core_read.cpp
        ../../src/core_write.cpp
        ../../src/key.cpp
        ../../src/key_io.cpp
        ../../src/keystore.cpp
        ../../src/netaddress.cpp
        ../../src/netbase.cpp
        ../../src/policy/feerate.cpp
        ../../src/protocol.cpp
        ../../src/scheduler.cpp
        ../../src/script/descriptor.cpp
        ../../src/script/ismine.cpp
        ../../src/script/sign.cpp
        ../../src/script/standard.cpp
        ../../src/versionbitsinfo.cpp
        ../../src/warnings.cpp
)

add_library(bitcoin_common STATIC ${libbitcoin_common_SOURCES})
target_compile_definitions(bitcoin_common PRIVATE -DHAVE_CONFIG_H)
target_include_directories(bitcoin_common PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
        ${BITCOIN_ROOT}/src/secp256k1/include
        ${Boost_INCLUDE_DIRS}
)
