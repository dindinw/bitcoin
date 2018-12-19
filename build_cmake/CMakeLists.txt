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
option(ENABLE_TEST   "enable test"    ON)
option(ENABLE_WALLET "enable wallet"  ON)
option(ENABLE_ZMQ    "enable zmq"     ON)
option(USE_ASM       "enable use asm" ON)
option(USE_UPNP      "enable UPnP"    OFF)


# ==============================
# Check Requried Dependeces:
#  - Boost       (required)
#  - OpenSSL     (required)
#  - libevent    (required)
#  - berkeley-db (if wallet enabled)
#  - zmq         (if enbale)
#  - miniupnpc   (if enable)
#  - qt          (if enable)

if(WIN32)
    include(${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/vcpkg.cmake)
endif()

find_package(Boost 1.47.0 REQUIRED COMPONENTS system filesystem thread chrono)

include(${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindOpenSSLHelper.cmake)
find_package(OpenSSL REQUIRED)
message(STATUS "Found OpenSSL/Crypto ${OPENSSL_INCLUDE_DIR} ${OPENSSL_CRYPTO_LIBRARY}")

find_package(Libevent REQUIRED)
message(STATUS "Found libevent ${LIBEVENT_LIBRARIES}")

if(ENABLE_WALLET)
    find_package(libdb_cxx REQUIRED)  #bdb only required for support wallet
endif()

if(ENABLE_ZMQ)
    find_package (ZMQ)
    if(NOT ZMQ_FOUND)
        message(FATAL_ERROR "ENABLE_ZMQ is ${ENABLE_ZMQ} but libzmq not found, you might need swith to -DENABLE_ZMQ=off")
    endif()
endif()

if(USE_UPNP)
    find_package (Libminiupnpc)
    if(NOT Libminiupnpc_FOUND)
        message(FATAL_ERROR "USE_UPNP is ${USE_UPNP} but libminiupnpc not found, you might need swith to -DUSE_UPNP=off")
    endif()
endif()

# miniupnpc
# qt

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

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_common)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_consensus)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_server)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_cli)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_util)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_crypto)
if (ENABLE_WALLET)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_wallet)
endif()
if (ENABLE_ZMQ)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoin_zmq)
endif()

# LIBBITCOINQT=qt/libbitcoinqt.a
# add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libbitcoinqt  ${CMAKE_CURRENT_BINARY_DIR}/libbitcoinqt)
# if (ENABLE_QT)
# endif()

#========================
# Build Executable :
#  - bitcoind
#  - bitcoin-cli
#  - bitcoin-tx
#     - $(BOOST_LIBS) $(CRYPTO_LIBS)
#     - $(LIBUNIVALUE) $(LIBBITCOIN_COMMON) $(LIBBITCOIN_UTIL) $(LIBBITCOIN_CONSENSUS) $(LIBBITCOIN_CRYPTO) $(LIBSECP256K1)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/bitcoind)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/bitcoin-cli)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/bitcoin-tx)

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
if(ENABLE_TEST)
    find_package(Boost REQUIRED unit_test_framework)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/test_bitcoin)
endif()


#========================
# BENCHMARKS :

#========================
# Build bitcion-qt :

#========================
# Build bitcion-qt TEST :

#========================
#
message(STATUS "Build Configuration:")
message(STATUS "  ENABLE_TEST is ${ENABLE_TEST}")
message(STATUS "  ENABLE_WALLET is ${ENABLE_WALLET}")
message(STATUS "  ENABLE_ZMQ is ${ENABLE_ZMQ}")
message(STATUS "  USE_ASM is ${USE_ASM}")
message(STATUS "  USE_UPNP is ${USE_UPNP}")
message(STATUS "  ENABLE_SHANI/ENABLE_AVX2/ENABLE_SSE41 : ${ENABLE_SHANI}/${ENABLE_AVX2}/${ENABLE_SSE41}")

#---------------
# Windows Build: (test on Win10 + VS2017)
#
# 1.) Install Dependes by using `vcpkg` :
#  vcpkg install berkeleydb:x64-windows-static
#  vcpkg install boost:x64-windows-static
#  vcpkg install openssl:x64-windows-static
#  vcpkg install libevent:x64-windows-static
#  vcpkg install zeromq:x64-windows-static
# The vcpkg installed static libs speretely on the folder : <vcpkg_root>\installed\x64-windows-static\
#
# 2.) Toolchain configuation
#  - The toolchain need to specify the architecture to match with x64 (instead of the x86 by default for CLion)
#  - /MD flag MD_DynamicRelease should be RuntimeLibrary -> swich to /MT
#    https://docs.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library?view=vs-2017
#    https://github.com/Kitware/CMake/blob/v3.13.2/Modules/Platform/Windows-MSVC.cmake#L362
#  - NDEBUG on Release
#    - the cmake add the NDEBUG define https://github.com/Kitware/CMake/blob/v3.13.2/Modules/Platform/Windows-MSVC.cmake#L362
#    - net_processing.cpp (#if defined(NDEBUG))
#    - validation.cpp (#if defined(NDEBUG))
#
# 3.) fix Code :
#  - need to fix non-portable usage in the bitcoin's leveldb code
#    - remove non-portable headers <sys/types.h> and <unistd.h>  in db/c.cc db/c_test.c
#      - https://github.com/google/leveldb/commit/623d014a54f8cf9b74ad6aaba9181ca1e65c43a1
#    - remove ssize in db/db_iter.cc
#      - https://github.com/google/leveldb/commit/89af27bde59fbbb3025653812b45fec10a655cb7
#      - remove #define snprintf _snprintf in port/port_win.h
#  - refactor unicode filename wrapper (src/fs.cpp src/fs.h src/test/fs_test.cpp)
#    - https://github.com/bitcoin/bitcoin/pull/13878/
#    - https://github.com/bitcoin/bitcoin/issues/13869
#  - test-bitcion have 2 failed tests on the unicode filename
#      - fixed by using the /utf-8 flag to MSVC
#
# 4.) Fix linker
#  - need to add ws2_32 and shlwapi to linker
#    - __imp__PathFileExistsW -> shlwapi.lib
#    - net.cpp (FD_ISSET) -> ws2_32.lib
#  - need link crypt32.lib (if static link openssl)
#    - libeay32.lib __imp_CertOpenStore -> crypt32.lib
#  - need Iphlpapi.lib for test-bitcoin
#
# 5.) Warnings
#  - https://github.com/bitcoin/bitcoin/pull/14151
#

if(MSVC)
    # 1.) Make sure to use the /MT flag for the static lib
    #   - https://docs.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library?view=vs-2017
    #   - https://github.com/Kitware/CMake/blob/v3.13.2/Modules/Platform/Windows-MSVC.cmake#L362
    # 2.) remove /DNDEBUG
    message(STATUS "${CMAKE_CXX_FLAGS}")         # /DWIN32 /D_WINDOWS /W3 /GR /EHsc
    message(STATUS "${CMAKE_CXX_FLAGS_DEBUG}")   # /MDd /Zi /Ob0 /Od /RTC1
    message(STATUS "${CMAKE_CXX_FLAGS_RELEASE}") # /MD /O2 /Ob2 /DNDEBUG
    set(CMAKE_CXX_FLAGS_DEBUG    "/MT /Zi /Ob0 /Od /RTC1" CACHE INTERNAL "") #  MTd -> MT
    set(CMAKE_CXX_FLAGS_RELEASE  "/MT /O2 /Ob2" CACHE INTERNAL "")           #  MD  -> MT , remvoe NDEBUG
endif()
message(STATUS "Compiler : ${CMAKE_CXX_COMPILER}")
message(STATUS "  CXX_FLAGS         : ${CMAKE_CXX_FLAGS}")
message(STATUS "  CXX_FLAGS_DEBUG   : ${CMAKE_CXX_FLAGS_DEBUG}")
message(STATUS "  CXX_FLAGS_RELEASE : ${CMAKE_CXX_FLAGS_RELEASE}")