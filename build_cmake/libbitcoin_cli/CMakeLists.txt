
list(APPEND libbitcoin_cli_SOURCES
        ../../src/rpc/client.cpp
)

add_library(bitcoin_cli STATIC ${libbitcoin_cli_SOURCES})
target_compile_definitions(bitcoin_cli PRIVATE -DHAVE_CONFIG_H)
target_include_directories(bitcoin_cli PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
)
