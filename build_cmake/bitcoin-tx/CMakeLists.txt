
add_executable(bitcoin-tx ../../src/bitcoin-tx.cpp )

target_link_libraries(bitcoin-tx
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
        OpenSSL::Crypto
)

target_compile_definitions(bitcoin-tx PRIVATE HAVE_CONFIG_H)
target_include_directories(bitcoin-tx PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
        ${BITCOIN_ROOT}/src/secp256k1/include
)
