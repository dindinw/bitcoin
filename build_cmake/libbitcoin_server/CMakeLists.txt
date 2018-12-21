
list(APPEND libbitcoin_server_SOURCES
        ../../src/addrdb.cpp
        ../../src/addrman.cpp
        ../../src/bloom.cpp
        ../../src/blockencodings.cpp
        ../../src/blockfilter.cpp
        ../../src/chain.cpp
        ../../src/checkpoints.cpp
        ../../src/consensus/tx_verify.cpp
        ../../src/httprpc.cpp
        ../../src/httpserver.cpp
        ../../src/index/base.cpp
        ../../src/index/txindex.cpp
        ../../src/interfaces/chain.cpp
        ../../src/interfaces/handler.cpp
        ../../src/interfaces/node.cpp
        ../../src/init.cpp
        ../../src/dbwrapper.cpp
        ../../src/merkleblock.cpp
        ../../src/miner.cpp
        ../../src/net.cpp
        ../../src/net_processing.cpp
        ../../src/noui.cpp
        ../../src/outputtype.cpp
        ../../src/policy/fees.cpp
        ../../src/policy/policy.cpp
        ../../src/policy/rbf.cpp
        ../../src/pow.cpp
        ../../src/rest.cpp
        ../../src/rpc/blockchain.cpp
        ../../src/rpc/mining.cpp
        ../../src/rpc/misc.cpp
        ../../src/rpc/net.cpp
        ../../src/rpc/rawtransaction.cpp
        ../../src/rpc/server.cpp
        ../../src/rpc/util.cpp
        ../../src/script/sigcache.cpp
        ../../src/shutdown.cpp
        ../../src/timedata.cpp
        ../../src/torcontrol.cpp
        ../../src/txdb.cpp
        ../../src/txmempool.cpp
        ../../src/ui_interface.cpp
        ../../src/validation.cpp
        ../../src/validationinterface.cpp
        ../../src/versionbits.cpp
        )

if(NOT ENABLE_WALLET)
        message(STATUS "wallet disnabled, using dummy wallet internally")
        list(APPEND libbitcoin_server_SOURCES
        ../../src/dummywallet.cpp)
endif()

add_library(bitcoin_server STATIC ${libbitcoin_server_SOURCES})
target_compile_definitions(bitcoin_server PRIVATE -DHAVE_CONFIG_H)
target_include_directories(bitcoin_server PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
        ${BITCOIN_ROOT}/src/leveldb/include
        ${BITCOIN_ROOT}/src/leveldb/helpers/memenv
        ${Boost_INCLUDE_DIRS}
        ${OPENSSL_INCLUDE_DIR}
        ${LIBEVENT_INCLUDE_DIR}
		${LIBMINIUPNPC_INCLUDE_DIRS}
)
