#
#  Copyright (c) 2018 Alex Wu
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
#
cmake_minimum_required(VERSION 3.5)

project(bitcoin)

set(CMAKE_CXX_STANDARD 11)

# The cmake helper modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules")

# The root dir
set(BITCOIN_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/..)

# ==============================
# All Options
option(ENABLE_WALLET "enable wallet" ON)
option(ENABLE_ZMQ    "enable zmq"    OFF)
option(USE_ASM "enable use asm" ON)

# ==============================
# Check Requried Dependeces:
#  - berkeley-db (required)
#  - Boost       (required)
#  - OpenSSL     (required)
#  - libevent    (required)
#  - miniupnpc   (if enable, should auto-checked)
#  - qt          (if enable)
#

# BDB berkeley-db 4
MESSAGE(STATUS "try Found libdb libraries")

FIND_PACKAGE( libdb_cxx REQUIRED)
IF (LIBDB_CXX_INCLUDE_DIR AND LIBDB_CXX_LIBRARIES)
    MESSAGE(STATUS "Found libdb include dir ${LIBDB_CXX_INCLUDE_DIR} and lib ${LIBDB_CXX_LIBRARIES}")
    include_directories(${LIBDB_CXX_INCLUDE_DIR})
ENDIF (LIBDB_CXX_INCLUDE_DIR AND LIBDB_CXX_LIBRARIES)


# Boost
MESSAGE(STATUS "try Found boost libraries")
FIND_PACKAGE(Boost REQUIRED COMPONENTS
        thread
        filesystem)

# open-ssl
MESSAGE(STATUS "try Found open-ssl libraries")
# add defaults for openssl
if ("${OPENSSL_ROOT_DIR}" STREQUAL "")
    if (NOT "$ENV{OPENSSL_ROOT_DIR}" STREQUAL "")
        set(OPENSSL_ROOT_DIR $ENV{OPENSSL_ROOT_DIR})
        set(OPENSSL_INCLUDE_DIR ${OPENSSL_ROOT_DIR}/include)
    elseif (APPLE)
        set(OPENSSL_ROOT_DIR "/usr/local/opt/openssl")
        set(OPENSSL_INCLUDE_DIR "/usr/local/opt/openssl/include")
        MESSAGE(STATUS "Found open-ssl libraries ${OPENSSL_ROOT_DIR}")
        include_directories(${OPENSSL_INCLUDE_DIR})
    elseif(UNIX AND NOT APPLE)
        set(OPENSSL_ROOT_DIR "/usr/include/openssl")
        set(OPENSSL_INCLUDE_DIR "/usr/include/openssl/include")
    else()
        message(FATAL_ERROR "openssl not found and don't know where to look, please specify OPENSSL_ROOT_DIR")
    endif()
endif()

if(ENABLE_QT)
    # Qt5, the package_config way not work
    #FIND_PACKAGE( Qt5 REQUIRED)
    #IF (PKG_QT5_FOUND)
    #    MESSAGE(STATUS "Found qt5 ${PKG_QT5_VERSION}")
    #    MESSAGE(STATUS "add qt5 include dir ${PKG_QT5_INCLUDEDIR}")
    #    include_directories(${PKG_QT5_INCLUDEDIR})
    #ENDIF(PKG_QT5_FOUND)

    # Qt5
    MESSAGE(STATUS "try Found qt5 libraries")
    list(APPEND CMAKE_PREFIX_PATH "/usr/local/opt/qt/")

    FIND_PACKAGE(Qt5Core CONFIG REQUIRED)
    IF (Qt5Core_FOUND)
        MESSAGE(STATUS "add qt5 include dir ${Qt5Core_INCLUDE_DIRS}")
        include_directories(${Qt5Core_INCLUDE_DIRS})
    ENDIF(Qt5Core_FOUND)

    FIND_PACKAGE(Qt5Test CONFIG REQUIRED)
    IF (Qt5Test_FOUND)
        MESSAGE(STATUS "add qt5 include dir ${Qt5Test_INCLUDE_DIRS}")
        include_directories(${Qt5Test_INCLUDE_DIRS})
    ENDIF(Qt5Test_FOUND)
endif()

# ===========================
# Generate the config_h
# from ../configure.ac

include(CheckIncludeFiles)
include(CheckSymbolExists)

set(CLIENT_VERSION_MAJOR 0)
set(CLIENT_VERSION_MINOR 17)
set(CLIENT_VERSION_REVISION 99)
set(CLIENT_VERSION_BUILD 0)
set(CLIENT_VERSION_RC 0)                            # rev version (https://github.com/bitcoin/bitcoin/pull/14612)
set(CLIENT_VERSION_IS_RELEASE false)                # true for release (../doc/release-process.md)
set(COPYRIGHT_YEAR 2018)
set(COPYRIGHT_HOLDERS "The %s developers")
set(COPYRIGHT_HOLDERS_SUBSTITUTION "Bitcoin Core")
string(REPLACE "%s" ${COPYRIGHT_HOLDERS_SUBSTITUTION} COPYRIGHT_HOLDERS_FINAL ${COPYRIGHT_HOLDERS})

# ENABLE_AVX2/ENABLE_SHANI/ENABLE_SSE41
set(ENABLE_SHANI on) # TODO test logic
set(ENABLE_AVX2 on)  # TODO test logic
set(ENABLE_SSE41 on) # TODO test logic

# HAVE_BOOST_XXX ...
# Boost is required, HAVE_BOOST_XXX should be set to on directly
set(HAVE_BOOST on)
set(HAVE_BOOST_CHRONO on)
set(HAVE_BOOST_FILESYSTEM on)
set(HAVE_BOOST_SYSTEM on)
set(HAVE_BOOST_THREAD on)
set(HAVE_BOOST_UNIT_TEST_FRAMEWORK on)

# AC_CHECK_DECLS([le16toh, le32toh, le64toh, htole16, htole32, htole64, be16toh, be32toh, be64toh, htobe16, htobe32, htobe64],,,
#		[#if HAVE_ENDIAN_H
                 #include <endian.h>
                 #elif HAVE_SYS_ENDIAN_H
                 #include <sys/endian.h>
                 #endif])
CHECK_INCLUDE_FILE("endian.h"     HAVE_ENDIAN_H)
CHECK_INCLUDE_FILE("sys/endian.h" HAVE_SYS_ENDIAN_H)

if(HAVE_ENDIAN_H)
    set(ENDIAN_H "endian.h")
elseif(HAVE_SYS_ENDIAN_H)
    set(ENDIAN_H "sys/endian.h")
else()
endif()

if(ENDIAN_H)
    CHECK_SYMBOL_EXISTS(le16toh ${ENDIAN_H} HAVE_DECL_LE16TOH)
    CHECK_SYMBOL_EXISTS(le32toh ${ENDIAN_H} HAVE_DECL_LE32TOH)
    CHECK_SYMBOL_EXISTS(le64toh ${ENDIAN_H} HAVE_DECL_LE64TOH)
    CHECK_SYMBOL_EXISTS(htole16 ${ENDIAN_H} HAVE_DECL_HTOLE16)
    CHECK_SYMBOL_EXISTS(htole32 ${ENDIAN_H} HAVE_DECL_HTOLE32)
    CHECK_SYMBOL_EXISTS(htole64 ${ENDIAN_H} HAVE_DECL_HTOLE64)
    CHECK_SYMBOL_EXISTS(be16toh ${ENDIAN_H} HAVE_DECL_BE16TOH)
    CHECK_SYMBOL_EXISTS(be32toh ${ENDIAN_H} HAVE_DECL_BE32TOH)
    CHECK_SYMBOL_EXISTS(be64toh ${ENDIAN_H} HAVE_DECL_BE64TOH)
    CHECK_SYMBOL_EXISTS(htobe16 ${ENDIAN_H} HAVE_DECL_HTOBE16)
    CHECK_SYMBOL_EXISTS(htobe32 ${ENDIAN_H} HAVE_DECL_HTOBE32)
    CHECK_SYMBOL_EXISTS(htobe64 ${ENDIAN_H} HAVE_DECL_HTOBE64)
endif()


# HAVE_BYTESWAP_H
CHECK_INCLUDE_FILE(byteswap.h HAVE_BYTESWAP_H)
CHECK_SYMBOL_EXISTS(bswap_16 "byteswap.h" HAVE_DECL_BSWAP_16)
CHECK_SYMBOL_EXISTS(bswap_32 "byteswap.h" HAVE_DECL_BSWAP_32)
CHECK_SYMBOL_EXISTS(bswap_64 "byteswap.h" HAVE_DECL_BSWAP_64)







# USE_ASM
# set(USE_ASM on)  see option

CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/bitcoin-config.h.in ${BITCOIN_ROOT}/src/config/bitcoin-config.cmake.h)


# ===========================
#  Build dependence library
#  - leveldb
#  - secp256k1
#  - univalue
#
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libleveldb   ${CMAKE_CURRENT_BINARY_DIR}/libleveldb)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libsecp256k1 ${CMAKE_CURRENT_BINARY_DIR}/libsecp256k1)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libunivalue  ${CMAKE_CURRENT_BINARY_DIR}/libunivalue)


# ======================
# Build bitcoin librarys
#  - common    (shared between bitcoind, and bitcoin-qt and non-server tools)
#  - consensus (shared between all executables that validate any consensus rules)
#  - cli       (shared between bitcoin-cli and bitcoin-qt)
#  - server    (shared between bitcoind & boincoin-qt)
#  - util      (shared between all executables. This library *must* be included to make sure
#               the glibc backward-compatibility objects and their sanity checks are linked.)
#  - crypto
#    - base    (crypto primitives library)
#    - others  (if enable : SSE41,AVX2,SHANI)
#  - wallet    (shared between bitcoind and bitcoin-qt, but only linked when wallet enabled)
#  - zmq       (if enable)
#  - qt        (if enable)


# LIBBITCOIN_COMMON=libbitcoin_common.a
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_common    ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_common)

# LIBBITCOIN_CONSENSUS=libbitcoin_consensus.a
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_consensus ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_consensus)

# LIBBITCOIN_SERVER=libbitcoin_server.a
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_server    ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_server)

# LIBBITCOIN_CLI=libbitcoin_cli.a
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_cli       ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_cli)

# LIBBITCOIN_UTIL=libbitcoin_util.a
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_util      ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_util)

# LIBBITCOIN_CRYPTO_BASE=crypto/libbitcoin_crypto_base.a
# LIBBITCOIN_CRYPTO_SSE41=crypto/libbitcoin_crypto_sse41.a
# LIBBITCOIN_CRYPTO_AVX2=crypto/libbitcoin_crypto_avx2.a
# LIBBITCOIN_CRYPTO_SHANI=crypto/libbitcoin_crypto_shani.a
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_crypto     ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_crypto)
# LIBBITCOIN_WALLET=libbitcoin_wallet.a
if(ENABLE_WALLET)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_wallet ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_wallet)
endif()
# LIBBITCOIN_ZMQ=libbitcoin_zmq.a
if (ENABLE_ZMQ)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_zmq    ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_zmq)
endif()

# LIBBITCOINQT=qt/libbitcoinqt.a
# add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoinqt  ${CMAKE_CURRENT_BINARY_DIR}/libbitcoinqt)
# if (ENABLE_QT)
# endif()

#========================
# Build Executable :
#  - bitcoind
#     - $(BOOST_LIBS) $(BDB_LIBS) $(CRYPTO_LIBS) $(MINIUPNPC_LIBS) $(EVENT_PTHREADS_LIBS) $(EVENT_LIBS) $(ZMQ_LIBS)
#     - $(LIBBITCOIN_SERVER) $(LIBBITCOIN_WALLET) $(LIBBITCOIN_COMMON)
#     - $(LIBBITCOIN_UTIL)   $(LIBBITCOIN_CONSENSUS)
#     - $(LIBBITCOIN_CRYPTO) $(LIBBITCOIN_ZMQ)
#     - $(LIBLEVELDB) $(LIBLEVELDB_SSE42) $(LIBMEMENV)
#     - $(LIBSECP256K1)
#     - $(LIBUNIVALUE)
#  - bitcoin-cli
#     - $(BOOST_LIBS) $(CRYPTO_LIBS) $(EVENT_LIBS)
#     - $(LIBBITCOIN_CLI) $(LIBUNIVALUE) $(LIBBITCOIN_UTIL) $(LIBBITCOIN_CRYPTO)
#  - bitcoin-tx
#     - $(BOOST_LIBS) $(CRYPTO_LIBS)
#     - $(LIBUNIVALUE) $(LIBBITCOIN_COMMON) $(LIBBITCOIN_UTIL) $(LIBBITCOIN_CONSENSUS) $(LIBBITCOIN_CRYPTO) $(LIBSECP256K1)
#

# bitcoind
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/bitcoind  ${CMAKE_CURRENT_BINARY_DIR}/bitcoind)

# bitcion-cli

# bitcion-tx



#========================
# TEST :
#  - test_bitcoin
#     - $(LIBLEVELDB) $(LIBLEVELDB_SSE42) $(LIBMEMENV)
#     - $(BOOST_LIBS) $(BOOST_UNIT_TEST_FRAMEWORK_LIB) $(LIBSECP256K1) $(EVENT_LIBS) $(EVENT_PTHREADS_LIBS)
#     - $(LIBBITCOIN_SERVER) $(LIBBITCOIN_CLI) $(LIBBITCOIN_COMMON) $(LIBBITCOIN_UTIL)
#     - $(LIBBITCOIN_CONSENSUS) $(LIBBITCOIN_CRYPTO) $(LIBUNIVALUE)
#     if enable :
#        - $(LIBBITCOIN_WALLET) $(ZMQ_LIBS)
#  - test_bitcoin_fuzzy
#     - $(LIBUNIVALUE) $(LIBBITCOIN_SERVER) $(LIBBITCOIN_COMMON) $(LIBBITCOIN_UTIL)
#     - $(LIBBITCOIN_CONSENSUS) $(LIBBITCOIN_CRYPTO) $(LIBBITCOIN_CRYPTO_SSE41)
#     - $(LIBBITCOIN_CRYPTO_AVX2) $(LIBBITCOIN_CRYPTO_SHANI) $(LIBSECP256K1)
#     - $(BOOST_LIBS) $(CRYPTO_LIBS)

#========================
# BENCHMARKS :

#========================
# Build bitcion-qt :

#========================
# Build bitcion-qt TEST :


