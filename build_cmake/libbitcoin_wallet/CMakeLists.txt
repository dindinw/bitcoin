
list(APPEND libbitcoin_wallet_SOURCES
        ../../src/interfaces/wallet.cpp
        ../../src/wallet/coincontrol.cpp
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
        ../../src/wallet/coinselection.cpp
)

add_library(libbitcoin_wallet STATIC ${libbitcoin_wallet_SOURCES})
        target_compile_definitions(libbitcoin_wallet PRIVATE -DHAVE_CONFIG_H)
        target_include_directories(libbitcoin_wallet PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
)
