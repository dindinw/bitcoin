
add_executable(bitcoin-tx ../../src/bitcoin-tx.cpp )

list(APPEND bitcoin-tx_LIBRARIES
        univalue
        bitcoin_common
        bitcoin_util
        bitcoin_consensus
        bitcoin_crypto
        secp256k1
        Boost::filesystem
        Boost::system
        Boost::thread
        Boost::chrono
        ${OPENSSL_CRYPTO_LIBRARY}
)
if(WIN32)
    list(APPEND bitcoin-tx_LIBRARIES ws2_32 shlwapi crypt32)
endif()

target_link_libraries(bitcoin-tx ${bitcoin-tx_LIBRARIES})

target_compile_definitions(bitcoin-tx PRIVATE HAVE_CONFIG_H)
target_include_directories(bitcoin-tx PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
        ${BITCOIN_ROOT}/src/secp256k1/include
)
