
list(APPEND libbitcoin_consensus_SOURCES
        ../../src/amount.h
        ../../src/arith_uint256.cpp
        ../../src/arith_uint256.h
        ../../src/consensus/merkle.cpp
        ../../src/consensus/merkle.h
        ../../src/consensus/params.h
        ../../src/consensus/validation.h
        ../../src/hash.cpp
        ../../src/hash.h
        ../../src/prevector.h
        ../../src/primitives/block.cpp
        ../../src/primitives/block.h
        ../../src/primitives/transaction.cpp
        ../../src/primitives/transaction.h
        ../../src/pubkey.cpp
        ../../src/pubkey.h
        ../../src/script/bitcoinconsensus.cpp
        ../../src/script/interpreter.cpp
        ../../src/script/interpreter.h
        ../../src/script/script.cpp
        ../../src/script/script.h
        ../../src/script/script_error.cpp
        ../../src/script/script_error.h
        ../../src/serialize.h
        ../../src/span.h
        ../../src/tinyformat.h
        ../../src/uint256.cpp
        ../../src/uint256.h
        ../../src/util/strencodings.cpp
        ../../src/util/strencodings.h
        ../../src/version.h
        )

add_library(bitcoin_consensus STATIC ${libbitcoin_consensus_SOURCES})
target_compile_definitions(bitcoin_consensus PRIVATE -DHAVE_CONFIG_H)
if(WIN32)
    target_compile_definitions(bitcoin_consensus PUBLIC NOMINMAX)
endif()
target_include_directories(bitcoin_consensus PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/secp256k1/include
)
