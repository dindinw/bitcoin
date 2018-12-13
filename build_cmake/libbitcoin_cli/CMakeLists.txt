
list(APPEND libbitcoin_cli_SOURCES
        ../../src/rpc/client.cpp
)

add_library(libbitcoin_cli STATIC ${libbitcoin_cli_SOURCES})
        target_compile_definitions(libbitcoin_cli PRIVATE -DHAVE_CONFIG_H)
        target_include_directories(libbitcoin_cli PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
)
