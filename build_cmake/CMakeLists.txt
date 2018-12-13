cmake_minimum_required(VERSION 3.5)

project(bitcoin)

set(CMAKE_CXX_STANDARD 14)

# The cmake helper modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules")

# The root dir
set(BITCOIN_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/..)

# ====================
# Check Requried Dependeces:
#  - berkeley-db
#  - Boost
#  - OpenSSL
#  - qt (if GUI)
# ====================


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

# ====================
# build library
#  - leveldb
#  - secp256k1
#  - univalue
# ====================
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libleveldb   ${CMAKE_CURRENT_BINARY_DIR}/libleveldb)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libsecp256k1 ${CMAKE_CURRENT_BINARY_DIR}/libsecp256k1)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libunivalue  ${CMAKE_CURRENT_BINARY_DIR}/libunivalue)


# =======================
# Build bitcoin librarys :
#  - common (shared between bitcoind, and bitcoin-qt and non-server tools)
#  - consensus (shared between all executables that validate any consensus rules.)
#  - cli    (cli: shared between bitcoin-cli and bitcoin-qt)
#  - server (shared between bitcoind & boincoin-qt)
#  - util   (util: shared between all executables. This library *must* be included to make sure that the glibc
#  - wallet (shared between bitcoind and bitcoin-qt, but only linked when wallet enabled)
#  - crypto
#    - base   (crypto primitives library)
#    - others (if enable : SSE41,AVX2,SHANI )
#  - zmq (if enable)
#  - qt (LIBBITCOINQT)

# LIBBITCOIN_COMMON=libbitcoin_common.a
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_common    ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_common)
# LIBBITCOIN_CONSENSUS=libbitcoin_consensus.a
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_consensus ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_consensus)
# LIBBITCOIN_SERVER=libbitcoin_server.a
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_server    ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_server)
# LIBBITCOIN_CLI=libbitcoin_cli.a
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_cli       ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_cli)

# LIBBITCOIN_UTIL=libbitcoin_util.a
# LIBBITCOIN_CRYPTO_BASE=crypto/libbitcoin_crypto_base.a
# LIBBITCOINQT=qt/libbitcoinqt.a

option(ZMQ "enable zmq" OFF)
if (ZMQ)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_zmq  ${CMAKE_CURRENT_BINARY_DIR}/libbitcoin_zmq)
endif()


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

