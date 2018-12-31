# The cmake script to gen bench_bitcoin

# basic bench_bitcion source
list(APPEND bench_bitcoin_SOURCES
        ../../src/bench/bench_bitcoin.cpp
        ../../src/bench/bench.cpp
        ../../src/bench/bench.h
        ../../src/bench/block_assemble.cpp
        ../../src/bench/checkblock.cpp
        ../../src/bench/checkqueue.cpp
        ../../src/bench/duplicate_inputs.cpp
        ../../src/bench/examples.cpp
        ../../src/bench/rollingbloom.cpp
        ../../src/bench/crypto_hash.cpp
        ../../src/bench/ccoins_caching.cpp
        ../../src/bench/gcs_filter.cpp
        ../../src/bench/merkle_root.cpp
        ../../src/bench/mempool_eviction.cpp
        ../../src/bench/verify_script.cpp
        ../../src/bench/base58.cpp
        ../../src/bench/bech32.cpp
        ../../src/bench/lockedpool.cpp
        ../../src/bench/prevector.cpp)

# the generate blockxxx.raw.h for checkblock.cpp
set(RAW_BENCH_FILE  ../../src/bench/data/block413567.raw)
list(APPEND bench_bitcoin_SOURCES "${RAW_BENCH_FILE}.h")

get_filename_component(_full_path_of_raw ${RAW_BENCH_FILE} ABSOLUTE)
get_filename_component(_name_of_raw ${RAW_BENCH_FILE} NAME_WE)
set(GENERATED_BENCH_FILE "${_full_path_of_raw}.h")

if(CMAKE_VERSION VERSION_GREATER 3.11)
    find_package (Python REQUIRED COMPONENTS Interpreter)
else()
    find_program(Python_EXECUTABLE python)
endif()
add_custom_command(OUTPUT ${GENERATED_BENCH_FILE}
        COMMAND ${Python_EXECUTABLE}
        ARGS "${CMAKE_CURRENT_SOURCE_DIR}/gen_raw_h.py"
        "${_full_path_of_raw}" "${_name_of_raw}" > ${GENERATED_BENCH_FILE}
        MAIN_DEPENDENCY  ${RAW_BENCH_FILE}
        DEPENDS "../../src/bench/checkblock.cpp")

# the wallet related bench tests
if(ENABLE_WALLET)
    list(APPEND bench_bitcoin_SOURCES
        ../../src/bench/coin_selection.cpp)
endif()

# build bench
add_executable(bench_bitcoin ${bench_bitcoin_SOURCES})
target_link_libraries(bench_bitcoin
        bitcoin_server
        bitcoin_common
        bitcoin_util
        bitcoin_consensus
        bitcoin_crypto
        leveldb leveldb_sse42 memenv
        secp256k1
        univalue
        Boost::filesystem
        Boost::system
        Boost::thread
        Boost::chrono
        ${OPENSSL_CRYPTO_LIBRARY})
if(ENABLE_ZMQ)
    target_link_libraries(bench_bitcoin bitcoin_zmq ${ZMQ_LIBRARIES})
endif()
if(ENABLE_WALLET)
    target_link_libraries(bench_bitcoin bitcoin_wallet ${LIBDB_CXX_LIBRARIES})
endif()
if(STATIC_BUILD AND UNIX AND NOT APPLE)
    target_link_libraries(bench_bitcoin dl) # required by static link of libcrypto.a
endif()

target_include_directories(bench_bitcoin PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/leveldb/include
        ${LIBDB_CXX_INCLUDE_DIR})
target_compile_definitions(bench_bitcoin PRIVATE HAVE_CONFIG_H)




