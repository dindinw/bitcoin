
list(APPEND libbitcoin_util_SOURCES
        ../../src/support/lockedpool.cpp
        ../../src/chainparamsbase.cpp
        ../../src/clientversion.cpp
        ../../src/compat/glibc_sanity.cpp
        ../../src/compat/glibcxx_sanity.cpp
        ../../src/compat/strnlen.cpp
        ../../src/fs.cpp
        ../../src/logging.cpp
        ../../src/random.cpp
        ../../src/rpc/protocol.cpp
        ../../src/support/cleanse.cpp
        ../../src/sync.cpp
        ../../src/threadinterrupt.cpp
        ../../src/util/bytevectorhash.cpp
        ../../src/util/system.cpp
        ../../src/util/moneystr.cpp
        ../../src/util/strencodings.cpp
        ../../src/util/time.cpp
        )

if (GLIBC_BACK_COMPAT)
        list(APPEND libbitcoin_util_SOURCES
                .../../src/compat/glibc_compat.cpp)
endif()

add_library(libbitcoin_util STATIC ${libbitcoin_util_SOURCES})
        target_compile_definitions(libbitcoin_util PRIVATE -DHAVE_CONFIG_H)
        target_include_directories(libbitcoin_util PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
)
