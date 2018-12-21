
list (APPEND JSON_TEST_FILES
        ../../src/test/data/script_tests.json
        ../../src/test/data/base58_encode_decode.json
        ../../src/test/data/blockfilters.json
        ../../src/test/data/key_io_valid.json
        ../../src/test/data/key_io_invalid.json
        ../../src/test/data/script_tests.json
        ../../src/test/data/sighash.json
        ../../src/test/data/tx_invalid.json
        ../../src/test/data/tx_valid.json
)


list (APPEND BITCOIN_TEST_SUITE
        ../../src/test/test_bitcoin_main.cpp
        ../../src/test/test_bitcoin.h
        ../../src/test/test_bitcoin.cpp)

list (APPEND BITCOIN_TESTS
        ../../src/test/arith_uint256_tests.cpp
        ../../src/test/scriptnum10.h
        ../../src/test/addrman_tests.cpp
        ../../src/test/amount_tests.cpp
        ../../src/test/allocator_tests.cpp
        ../../src/test/base32_tests.cpp
        ../../src/test/base58_tests.cpp
        ../../src/test/base64_tests.cpp
        ../../src/test/bech32_tests.cpp
        ../../src/test/bip32_tests.cpp
        ../../src/test/blockchain_tests.cpp
        ../../src/test/blockencodings_tests.cpp
        ../../src/test/blockfilter_tests.cpp
        ../../src/test/bloom_tests.cpp
        ../../src/test/bswap_tests.cpp
        ../../src/test/checkqueue_tests.cpp
        ../../src/test/coins_tests.cpp
        ../../src/test/compress_tests.cpp
        ../../src/test/crypto_tests.cpp
        ../../src/test/cuckoocache_tests.cpp
        ../../src/test/denialofservice_tests.cpp
        ../../src/test/descriptor_tests.cpp
        ../../src/test/fs_tests.cpp
        ../../src/test/getarg_tests.cpp
        ../../src/test/hash_tests.cpp
        ../../src/test/key_io_tests.cpp
        ../../src/test/key_tests.cpp
        ../../src/test/limitedmap_tests.cpp
        ../../src/test/dbwrapper_tests.cpp
        ../../src/test/main_tests.cpp
        ../../src/test/mempool_tests.cpp
        ../../src/test/merkle_tests.cpp
        ../../src/test/merkleblock_tests.cpp
        ../../src/test/miner_tests.cpp
        ../../src/test/multisig_tests.cpp
        ../../src/test/net_tests.cpp
        ../../src/test/netbase_tests.cpp
        ../../src/test/pmt_tests.cpp
        ../../src/test/policyestimator_tests.cpp
        ../../src/test/pow_tests.cpp
        ../../src/test/prevector_tests.cpp
        ../../src/test/raii_event_tests.cpp
        ../../src/test/random_tests.cpp
        ../../src/test/reverselock_tests.cpp
        ../../src/test/rpc_tests.cpp
        ../../src/test/sanity_tests.cpp
        ../../src/test/scheduler_tests.cpp
        ../../src/test/script_p2sh_tests.cpp
        ../../src/test/script_tests.cpp
        ../../src/test/script_standard_tests.cpp
        ../../src/test/scriptnum_tests.cpp
        ../../src/test/serialize_tests.cpp
        ../../src/test/sighash_tests.cpp
        ../../src/test/sigopcount_tests.cpp
        ../../src/test/skiplist_tests.cpp
        ../../src/test/streams_tests.cpp
        ../../src/test/sync_tests.cpp
        ../../src/test/timedata_tests.cpp
        ../../src/test/torcontrol_tests.cpp
        ../../src/test/transaction_tests.cpp
        ../../src/test/txindex_tests.cpp
        ../../src/test/txvalidation_tests.cpp
        ../../src/test/txvalidationcache_tests.cpp
        ../../src/test/uint256_tests.cpp
        ../../src/test/util_tests.cpp
        ../../src/test/validation_block_tests.cpp
        ../../src/test/versionbits_tests.cpp
)

if(ENABLE_PROPERTY_TESTS) #need rapidcheck
    find_package(Rapidcheck)
    list(APPEND BITCOIN_TESTS
        ../../src/test/key_properties.cpp)

    list(APPEND BITCOIN_TEST_SUITE
        ../../src/test/gen/crypto_gen.cpp
        ../../src/test/gen/crypto_gen.h)
endif()

if(ENABLE_WALLET)
    list(APPEND BITCOIN_TESTS
        ../../src/wallet/test/psbt_wallet_tests.cpp
        ../../src/wallet/test/wallet_tests.cpp
        ../../src/wallet/test/wallet_crypto_tests.cpp
        ../../src/wallet/test/coinselector_tests.cpp
        ../../src/wallet/test/init_tests.cpp)

    list(APPEND BITCOIN_TEST_SUITE
        ../../src/wallet/test/wallet_test_fixture.cpp
        ../../src/wallet/test/wallet_test_fixture.h
        ../../src/wallet/test/init_test_fixture.cpp
        ../../src/wallet/test/init_test_fixture.h)
endif()

list (APPEND test_bitcoin_SOURCES
        ${BITCOIN_TEST_SUITE}
        ${BITCOIN_TESTS}
        ${JSON_TEST_FILES}
        ${RAW_TEST_FILES})

add_executable(test_bitcoin ${test_bitcoin_SOURCES})

if (ENABLE_WALLET)
    list(APPEND test_bitcoin_LIBRARIES bitcoin_wallet)
endif()


if(USE_UPNP)
    set(LIB_MINIUPNP ${LIBMINIUPNPC_LIBRARIES})

endif()

list(APPEND test_bitcoin_LIBRARIES
        bitcoin_server bitcoin_cli bitcoin_common bitcoin_util
        bitcoin_consensus bitcoin_crypto univalue
        leveldb leveldb_sse42 memenv
        secp256k1
        Boost::unit_test_framework
        Boost::filesystem
        Boost::system
        Boost::thread
        Boost::chrono
        ${LIBDB_CXX_LIBRARIES}
        OpenSSL::Crypto
        ${LIBEVENT_LIBRARIES}
        ${LIB_MINIUPNP}
        # rapidcheck
)
if(ENABLE_ZMQ)
    list(APPEND test_bitcoin_LIBRARIES ${ZMQ_LIBRARIES})
endif()

if(WIN32)
    list(APPEND test_bitcoin_LIBRARIES ws2_32 Iphlpapi shlwapi crypt32)
endif()

# The FindPython is more powerful but only avaible on the latest versions
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.12)
    find_package (Python REQUIRED COMPONENTS Interpreter)
else()
    find_program(Python_EXECUTABLE python)
endif()

function(gen_json_header NAME)
    set(HEADERS "")
    foreach(f ${ARGN})
        # Get the proper name for the test variable.
        get_filename_component(TEST_NAME ${f} NAME_WE)
        get_filename_component(FULL_NAME ${f} ABSOLUTE)
        set(h "${FULL_NAME}.h")
        # message(STATUS "${CMAKE_CURRENT_SOURCE_DIR}/${f} > ${h}")
        add_custom_command(OUTPUT ${h}
                COMMAND ${Python_EXECUTABLE}
                ARGS
                "${CMAKE_CURRENT_SOURCE_DIR}/gen_json_h.py"
                "${TEST_NAME}"
                "${CMAKE_CURRENT_SOURCE_DIR}/${f}" > ${h}
                MAIN_DEPENDENCY ${f}
                DEPENDS
                "gen_json_h.py"
                VERBATIM
                )
        list(APPEND HEADERS ${h})
    endforeach(f)
    set(${NAME} "${HEADERS}" PARENT_SCOPE)
endfunction()

gen_json_header(JSON_HEADERS ${JSON_TEST_FILES})

target_link_libraries(test_bitcoin ${test_bitcoin_LIBRARIES})
target_compile_definitions(test_bitcoin PRIVATE HAVE_CONFIG_H)

if(Boost_VERSION GREATER 105800 AND NOT WIN32)
    message(STATUS "  use BOOST_TEST_DYN_LINK")
    target_compile_definitions(test_bitcoin PRIVATE BOOST_TEST_DYN_LINK)
endif()

if(WIN32)
    target_compile_definitions(test_bitcoin PRIVATE NOMINMAX)
    if(MSVC) # make sure the Visual Studio read soure code file as utf-8
        target_compile_options(test_bitcoin PRIVATE "/utf-8")
    endif()
endif()


target_include_directories(test_bitcoin PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
        ${BITCOIN_ROOT}/src/leveldb/include
        ${BITCOIN_ROOT}/src/leveldb/helpers/memenv
        ${BITCOIN_ROOT}/src/secp256k1/include
        ${LIBDB_CXX_INCLUDE_DIR}
        ${BITCOIN_ROOT}/src/test/data
        ${OPENSSL_INCLUDE_DIR}
)

enable_testing()
#add_test(test_bitcion test_bitcoin)

include(BoostTestHelper)
add_boost_test(test_bitcoin ${BITCOIN_TESTS})

add_custom_target(check-bitcoin
        ${CMAKE_COMMAND} -E env CTEST_OUTPUT_ON_FAILURE=1 ${CMAKE_CTEST_COMMAND})
add_dependencies(check-bitcoin test_bitcoin)
