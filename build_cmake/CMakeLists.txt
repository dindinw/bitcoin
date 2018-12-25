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

# The cmake helper modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules")

# The root dir
set(BITCOIN_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/..)

# ==============================
# All Options
#

# The STATIC_BUILD is on by default, it try to do the static link, which
# means it will looking for the static libraries only.
option(STATIC_BUILD           "create static executable if possible" ON)
option(ENABLE_TEST            "enable test"      ON)
option(ENABLE_PROPERTY_TESTS  "enable RapidCheck property based tests" OFF)
option(ENABLE_BENCH           "enable benchmark" ON)
option(ENABLE_WALLET          "enable wallet"    ON)
option(ENABLE_ZMQ             "enable zmq"       ON)
option(USE_ASM                "enable use asm"   ON)
option(USE_UPNP               "enable UPnP"      OFF)

# the compiler depends options
if(MSVC)
    option(USE_VCPKG  "use vcpgk to mange depends on windows" ON)
endif()

# ==============================
# Compiler Settings
#

# use -std=c++11 by default, in most cases we don't need set -std=gnc++11 globally
set(CMAKE_CXX_STANDARD 11)


if(MSVC)
    # 1.) force to use the /MT flag for the static lib
    #     - https://docs.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library?view=vs-2017
    #     - https://github.com/Kitware/CMake/blob/v3.13.2/Modules/Platform/Windows-MSVC.cmake#L362
    # 2.) remove /DNDEBUG flag
    #message(STATUS "${CMAKE_CXX_FLAGS}")         # /DWIN32 /D_WINDOWS /W3 /GR /EHsc
    #message(STATUS "${CMAKE_CXX_FLAGS_DEBUG}")   # /MDd /Zi /Ob0 /Od /RTC1
    #message(STATUS "${CMAKE_CXX_FLAGS_RELEASE}") # /MD /O2 /Ob2 /DNDEBUG
    string(REPLACE "MDd" "MTd"   CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG}")     # MDd -> MTd
    string(REPLACE "MD"  "MT"    CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")   # MD  -> MT
    string(REPLACE "/DNDEBUG" "" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")   # remove NDEBUG

else()

    # Keep build static exetuable (special on MacOSX)
    # try to ask the compiler to create static libraries and the link to do the static
    # link if possible, use the add_compile_options() for the plalform/compiler in-depends.
    # for example, in macOS the `-static` will be ignored.
    if(STATIC_BUILD AND NOT APPLE)
        # for -static
        string(REGEX MATCH "-static" _force_static "${CMAKE_CXX_FLAGS}")
        if(NOT _force_static)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static")
        endif()

    endif()
    # if GNU :  -static-libgcc -static-libstdc++
    if(STATIC_BUILD AND NOT APPLE)
        string(REGEX MATCH "-static-libgcc" _force_static "${CMAKE_CXX_FLAGS}")
        if(NOT _force_static)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static-libgcc -static-libstdc++")
        endif()
    endif()

#    if(STATIC_BUILD)
#        add_compile_options(-static)
#    endif()

    #    if(NOT APPLE)
    #        string(REGEX MATCH "-static" _force_static "${CMAKE_CXX_FLAGS_RELEASE}")
    #        if(NOT _force_static)
    #            set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -static")
    #        endif()
    #    endif()
    # for other compiler, we need to remove -DNDEBUG flag anyway even in release, because bitcoin always use assert()
    # for example : src/net_processing.cpp#L34~37
    string(REPLACE "-DNDEBUG" "" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
endif()

# requried workaround force the compiler flags take effect by replacing the CMakeCache.txt
# set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG}"   CACHE INTERNAL "")
# set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}" CACHE INTERNAL "")

# ==============================
# Find Requried Dependeces:
#  - Boost       (required)
#  - OpenSSL     (required)
#  - libevent    (required)
#  - berkeley-db (if wallet enabled)
#  - zmq         (if enbale)
#  - miniupnpc   (if enable)
#  - qt          (if enable)

# try to use vcpkg if MSVC
if(MSVC)
    if(USE_VCPKG)
        include(${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/vcpkg.cmake)
    endif()
endif()

# Static lib config
# Please Note: vcpkg is special
# vcpkg use the special triple folder such as xxx-xxx-static for all static libaries
# for example : you can't find static boost by naming pattern when set Boost_USE_STATIC_LIBS on
if(STATIC_BUILD AND NOT USE_VCPKG)
    set(Boost_USE_STATIC_LIBS ON)
    set(OPENSSL_USE_STATIC_LIBS ON)
    set(LIBEVENT_USE_STATIC_LIBS ON)
    set(ZMQ_USE_STATIC_LIBS ON)
endif()

# Boost
list(APPEND required_boost_components system filesystem thread chrono)
if(ENABLE_TEST)
    list(APPEND required_boost_components unit_test_framework)
endif()
find_package(Boost 1.47.0 REQUIRED COMPONENTS ${required_boost_components})
if(Boost_DEBUG) # show debug message if Boost_DEBUG is on
    message(STATUS "Boost_LIBRARIES : ${Boost_LIBRARIES}")
    message(STATUS "Boost_UNIT_TEST_FRAMEWORK_LIBRARY : ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY}")
    message(STATUS "Boost_UNIT_TEST_FRAMEWORK_LIBRARY_RELEASE : ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY_RELEASE}")
    message(STATUS "Boost_UNIT_TEST_FRAMEWORK_LIBRARY_DEBUG : ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY_DEBUG}")
endif()

# OpenSSL
include(${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindOpenSSLHelper.cmake)

# libevent
find_package(Libevent REQUIRED)

# berkeyley-db
if(ENABLE_WALLET)
    find_package(libdb_cxx REQUIRED)  #bdb only required for support wallet
endif()

# zmq
if(ENABLE_ZMQ)
    find_package (ZMQ)
    if(NOT ZMQ_FOUND)
        message(FATAL_ERROR "ENABLE_ZMQ is ${ENABLE_ZMQ} but libzmq not found, you might need swith to -DENABLE_ZMQ=off")
    endif()
endif()

# miniupnpc
if(USE_UPNP)
    find_package (Libminiupnpc)
    if(NOT Libminiupnpc_FOUND)
        message(FATAL_ERROR "USE_UPNP is ${USE_UPNP} but libminiupnpc not found, you might need swith to -DUSE_UPNP=off")
    endif()
endif()

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
# Build Test Executable :
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
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/test_bitcoin)
endif()


#========================
# Build BENCHMARKS :
if(ENABLE_BENCH)
endif()

#========================
# Build bitcion-qt :

#========================
# Build bitcion-qt TEST :

#========================
# Show Configuations

message(STATUS "Build Configuration:")
message(STATUS "  STATIC_BUILD is ${STATIC_BUILD}")
message(STATUS "  ENABLE_TEST is ${ENABLE_TEST}")
message(STATUS "  ENABLE_PROPERTY_TESTS is ${ENABLE_PROPERTY_TESTS}")
message(STATUS "  ENABLE_BENCH is ${ENABLE_BENCH}")
message(STATUS "  ENABLE_WALLET is ${ENABLE_WALLET}")
message(STATUS "  ENABLE_ZMQ is ${ENABLE_ZMQ}")
message(STATUS "  USE_ASM is ${USE_ASM}")
message(STATUS "  USE_UPNP is ${USE_UPNP}")
message(STATUS "  ENABLE_SHANI/ENABLE_AVX2/ENABLE_SSE41 : ${ENABLE_SHANI}/${ENABLE_AVX2}/${ENABLE_SSE41}")
if(MSVC)
    message(STATUS "  USE_VCPKG is ${USE_VCPKG}")
endif()

message(STATUS "Build Type:")
get_property(_isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
message(STATUS "  isMultiConfig=${_isMultiConfig}  CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")

message(STATUS "Compiler : ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "  CXX_COMPILER      : ${CMAKE_CXX_COMPILER}")
message(STATUS "  CXX_FLAGS         : ${CMAKE_CXX_FLAGS}")
message(STATUS "  CXX_FLAGS_DEBUG   : ${CMAKE_CXX_FLAGS_DEBUG}")
message(STATUS "  CXX_FLAGS_RELEASE : ${CMAKE_CXX_FLAGS_RELEASE}")

# Show target architecture
if(MSVC)                                          # if MSVC
    set(_target_arch ${MSVC_CXX_ARCHITECTURE_ID})
elseif(APPLE AND CMAKE_OSX_ARCHITECTURES)         # if macOS find '-arch'
    set(_target_arch ${CMAKE_OSX_ARCHITECTURES})
elseif(CMAKE_C_FLAGS OR CMAKE_CXX_FLAGS)    # otherwise find '-march'
    set(_target_arch_regex "^.*-march[= ]([^ ]+).*$")
    string(REGEX MATCH "${_target_arch_regex}" _target_arch_match ${CMAKE_C_FLAGS} ${CMAKE_CXX_FLAGS})
    if (_target_arch_match)
        string(REGEX REPLACE "${_target_arch_regex}" "\\1" _target_arch ${CMAKE_C_FLAGS} ${CMAKE_CXX_FLAGS})
    endif()
endif()
if(NOT _target_arch)  #nothing find, fall back to use system processor, use (os default) as a notice
    set(_target_arch "${CMAKE_HOST_SYSTEM_PROCESSOR} (os default)")
endif()
message(STATUS "Target Archtecture : ${_target_arch}")


