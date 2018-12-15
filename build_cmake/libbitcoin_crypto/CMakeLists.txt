
list(APPEND libbitcoin_crypto_base_SOURCES
        ../../src/crypto/aes.cpp
        ../../src/crypto/aes.h
        ../../src/crypto/chacha20.h
        ../../src/crypto/chacha20.cpp
        ../../src/crypto/common.h
        ../../src/crypto/hmac_sha256.cpp
        ../../src/crypto/hmac_sha256.h
        ../../src/crypto/hmac_sha512.cpp
        ../../src/crypto/hmac_sha512.h
        ../../src/crypto/ripemd160.cpp
        ../../src/crypto/ripemd160.h
        ../../src/crypto/sha1.cpp
        ../../src/crypto/sha1.h
        ../../src/crypto/sha256.cpp
        ../../src/crypto/sha256.h
        ../../src/crypto/sha512.cpp
        ../../src/crypto/sha512.h
        ../../src/crypto/siphash.cpp
        ../../src/crypto/siphash.h
)
if (USE_ASM)
    list(APPEND libbitcoin_crypto_base_SOURCES
        ../../src/crypto/sha256_sse4.cpp)
endif()

add_library(bitcoin_crypto_base STATIC ${libbitcoin_crypto_base_SOURCES})
target_compile_definitions(bitcoin_crypto_base PRIVATE -DHAVE_CONFIG_H)
target_include_directories(bitcoin_crypto_base PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
)

# LIBBITCOIN_CRYPTO_SSE41 = crypto/libbitcoin_crypto_sse41.a
if (ENABLE_SSE41)
    list(APPEND libbitcoin_crypto_sse41_SOURCES
        ../../src/crypto/sha256_sse41.cpp
    )
    add_library(bitcoin_crypto_sse41 STATIC ${libbitcoin_crypto_sse41_SOURCES})
    target_compile_definitions(bitcoin_crypto_sse41 PRIVATE -DHAVE_CONFIG_H)
    target_compile_definitions(bitcoin_crypto_sse41 PRIVATE -DENABLE_SSE41)
    target_compile_options(bitcoin_crypto_sse41 PRIVATE -msse4.1)
    target_include_directories(bitcoin_crypto_sse41 PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
    )
endif()

# LIBBITCOIN_CRYPTO_AVX2 = crypto/libbitcoin_crypto_avx2.a
if (ENABLE_AVX2)
    list(APPEND libbitcoin_crypto_avx2_SOURCES
        ../../src/crypto/sha256_avx2.cpp
    )
    add_library(bitcoin_crypto_avx2 STATIC ${libbitcoin_crypto_avx2_SOURCES})
    target_compile_definitions(bitcoin_crypto_avx2 PRIVATE -DHAVE_CONFIG_H)
    target_compile_definitions(bitcoin_crypto_avx2 PRIVATE -DENABLE_AVX2)
    target_compile_options(bitcoin_crypto_avx2 PRIVATE -mavx -mavx2)
    target_include_directories(bitcoin_crypto_avx2 PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
    )
endif()

# LIBBITCOIN_CRYPTO_SHANI = crypto/libbitcoin_crypto_shani.a
if (ENABLE_SHANI)
    list(APPEND libbitcoin_crypto_shani_SOURCES
        ../../src/crypto/sha256_shani.cpp
    )
    add_library(bitcoin_crypto_shani STATIC ${libbitcoin_crypto_shani_SOURCES})
    target_compile_definitions(bitcoin_crypto_shani PRIVATE -DHAVE_CONFIG_H)
    target_compile_definitions(bitcoin_crypto_shani PRIVATE -DENABLE_SHANI)
    target_compile_options(bitcoin_crypto_shani PRIVATE -msse4 -msha)
    target_include_directories(bitcoin_crypto_shani PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
    )
endif()

message(STATUS "crypto use asm : ${USE_ASM}")
message(STATUS "crypto SHANI/AVX2/SSE41 : ${ENABLE_SHANI}/${ENABLE_AVX2}/${ENABLE_SSE41}")
