
add_executable(bitcoin-cli ../../src/bitcoin-cli.cpp )

list(APPEND bitcoin-cli_LIBRARIES
        bitcoin_cli
        univalue
        bitcoin_util
        bitcoin_crypto
        Boost::filesystem
        Boost::thread
        ${OPENSSL_CRYPTO_LIBRARY}
        ${LIBEVENT_LIBRARIES}
        )
if(WIN32)
    list(APPEND bitcoin-cli_LIBRARIES ws2_32 shlwapi crypt32)
    # need MSVCRT.LIB on x86, but not on x64
    #  try libcmt.lib" and "libcmtd.lib
    #if(MSVC AND "${MSVC_CXX_ARCHITECTURE_ID}" STREQUAL "X86")
    #    target_link_libraries(bitcoin-tx libcmt)
    #endif()
endif()
target_link_libraries( bitcoin-cli ${bitcoin-cli_LIBRARIES})

if(STATIC_BUILD AND UNIX AND NOT APPLE)
    # required by static link of libcrypto.a
    target_link_libraries(bitcoin-cli dl)
endif()

target_compile_definitions(bitcoin-cli PRIVATE HAVE_CONFIG_H)
target_include_directories(bitcoin-cli PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
)
