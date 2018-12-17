
add_executable(bitcoin-cli ../../src/bitcoin-cli.cpp )

target_link_libraries( bitcoin-cli
        bitcoin_cli
        univalue
        bitcoin_util
        bitcoin_crypto
        Boost::filesystem
        Boost::thread
        OpenSSL::Crypto
        ${LIBEVENT_LIBRARIES}
)
message( why not boost ?  ${Boost_INCLUDE_DIRS})
target_compile_definitions(bitcoin-cli PRIVATE HAVE_CONFIG_H)
target_include_directories(bitcoin-cli PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
)
