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
# MINIMUM_REQUIRED_BOOST, 1.47.0
# AX_BOOST_SYSTEM
# AX_BOOST_FILESYSTEM
# AX_BOOST_THREAD
# AX_BOOST_CHRONO
# dnl Boost 1.56 through 1.62 allow using std::atomic instead of its own atomic
# dnl counter implementations. In 1.63 and later the std::atomic approach is default.
# m4_pattern_allow(DBOOST_AC_USE_STD_ATOMIC) dnl otherwise it's treated like a macro
# BOOST_CPPFLAGS="-DBOOST_SP_USE_STD_ATOMIC -DBOOST_AC_USE_STD_ATOMIC $BOOST_CPPFLAGS"
# dnl If boost (prior to 1.57) was built without c++11, it emulated scoped enums
# dnl using c++98 constructs. Unfortunately, this implementation detail leaked into
# dnl the abi. This was fixed in 1.57.
# dnl When building against that installed version using c++11, the headers pick up
# dnl on the native c++11 scoped enum support and enable it, however it will fail to
# dnl link. This can be worked around by disabling c++11 scoped enums if linking will
# dnl fail.
# dnl BOOST_NO_SCOPED_ENUMS was changed to BOOST_NO_CXX11_SCOPED_ENUMS in 1.51.
MESSAGE(STATUS "try Found boost libraries")
FIND_PACKAGE(Boost 1.47.0 REQUIRED COMPONENTS
        system
        filesystem
        thread
        chrono)

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
# Generate the bitcion-config.h
# from ../configure.ac
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/config_h   ${CMAKE_CURRENT_BINARY_DIR}/config_h)

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


