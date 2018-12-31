# The Cmake build script for test_bitcoin_fuzzy
# for what's a Fuzzing test, see following docs for more detais:
# https://github.com/bitcoin/bitcoin/blob/master/doc/fuzzing.md
# http://lcamtuf.coredump.cx/afl/
# https://en.wikipedia.org/wiki/Fuzzing

project(test_bitcoin_fuzzy)  #fuzzy test has to be standalone project, because it use diffrent toolchain

# use the fast LLVM-based afl-fuzz, default is OFF
# see https://github.com/mcarpenter/afl/tree/master/llvm_mode for details
option(USE_AFL_CLANG_FAST "use the fast llvm afl-fuzz" OFF)
# ----------------------------
# check for AFLPATH set correctly
if("${AFLPATH}" STREQUAL "" AND NOT "$ENV{AFLPATH}" STREQUAL "")
    set(CMAKE_PATH AFLPATH "$ENV{AFLPATH}")
endif()
file(TO_CMAKE_PATH "${AFLPATH}" AFLPATH) #make sure the path correct formatted

if("${AFLPATH}" STREQUAL "")
    message(FATAL_ERROR "must set AFLPATH when try to enable fuzzy test, or you might need to swith to -DENABLE_FUZZY_TEST=off")
elseif(NOT EXISTS ${AFLPATH})
    message(FATAL_ERROR "The appointed AFLPATH '${AFLPATH}' not exist")
endif()

# ----------------------------
# check for AFL_CC and AFC_CXX
if(APPLE)
    if (CMAKE_C_COMPILER_ID STREQUAL "GNU")
        # afl don't support use GNU/Gcc on Apple, only for Xcode/gcc aka AppleClang
        message(FATAL_ERROR "Can't use GNU gcc on MacOS with afl_cc, Please use Xcode gcc or swith to Linux.")
    endif()
    if (USE_AFL_CLANG_FAST)
        if(NOT CMAKE_C_COMPILER_ID STREQUAL "Clang") #fast mode only for Clang, can't use AppleClang
            message(FATAL_ERROR "Can't use fast llvm mode on compiler `${CMAKE_C_COMPILER_ID}`, you need LLVM Clang. "
                    "Or you might need to swith to -DUSE_AFL_CLANG_FAST=off")
        endif()
        set(AFL_CC   ${AFLPATH}/afl-clang-fast)
        set(AFL_CXX  ${AFLPATH}/afl-clang-fast++)
    else()
        set(AFL_CC   ${AFLPATH}/afl-clang)
        set(AFL_CXX  ${AFLPATH}/afl-clang++)
    endif()
else()
    set(AFL_CC   ${AFLPATH}/afl-gcc)
    set(AFL_CXX  ${AFLPATH}/afl-g++)
endif()
if(NOT EXISTS "${AFL_CC}")
    message(FATAL_ERROR "The '${AFL_CC}' not found, you might need to specify a correct AFLPATH")
endif()
if(NOT EXISTS "${AFL_CXX}")
    message(FATAL_ERROR "The '${AFL_CXX}' not found, you might need to specify a correct AFLPATH")
endif()

message(STATUS "Fuzzying test is enabled, AFLPATH is ${AFLPATH}")
message(STATUS "  AFL_CC  : ${AFL_CC}")
message(STATUS "  AFL_CXX : ${AFL_CXX}")
message(STATUS "  AFL_CLANG_FAST : ${USE_AFL_CLANG_FAST}")


set( CMAKE_C_COMPILER   "${AFL_CC}" )
set( CMAKE_CXX_COMPILER "${AFL_CXX}" )

# TODO: clear the gobal CMAKE_CXX_FLAGS setting if need
# set( CMAKE_CXX_FLAGS    "${AFL_CXX_FLAGS}" )

message(STATUS "  C_COMPILER        : ${CMAKE_C_COMPILER}")
message(STATUS "  CXX_COMPILER      : ${CMAKE_CXX_COMPILER}")
message(STATUS "  CXX_FLAGS         : ${CMAKE_CXX_FLAGS}")
message(STATUS "  CXX_FLAGS_DEBUG   : ${CMAKE_CXX_FLAGS_DEBUG}")
message(STATUS "  CXX_FLAGS_RELEASE : ${CMAKE_CXX_FLAGS_RELEASE}")

# ----------------------------
# build for test_bitcoin_fuzzy
#
list(APPEND test_bitcoin_fuzzy_SOURCES ../../src/test/test_bitcoin_fuzzy.cpp)
add_executable(test_bitcoin_fuzzy ${test_bitcoin_fuzzy_SOURCES})
target_link_libraries(test_bitcoin_fuzzy
        univalue
        bitcoin_server
        bitcoin_common
        bitcoin_util
        bitcoin_consensus
        bitcoin_crypto
        secp256k1
        Boost::filesystem
        Boost::thread
        Boost::chrono
        ${OPENSSL_CRYPTO_LIBRARY}
        )
target_include_directories(test_bitcoin_fuzzy PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src)
target_compile_definitions(test_bitcoin_fuzzy PRIVATE HAVE_CONFIG_H)

#
# TODO: refactor the usage the global CMAKE_CXX_FALG
# use the CMake generator expressions to handle the target's ${BUILD_FLAGS}
# the problem is cmake use the pattern like
#   ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS} ${BUILD_FLAGS} -o foo.o -c foo.cc
# the global setting can't not be specified for a single target
# unless we elimiate all usage of CMAKE_CXX_FLAGS, we can use the target
# specfied setting without being effected by the global setting.
# ex:
# target_compile_options(test_bitcoin_fuzzy PRIVATE
#        $<$<COMPILE_LANGUAGE:CXX>:${BUILD_FLAGS_FOR_CXX}>
#        $<$<CXX_COMPILER_ID:Clang>:${BUILD_FLAGS_FOR_CLANG}>
#        $<$<CXX_COMPILER_ID:GNU>:${BUILD_FLAGS_FOR_GCC}>)




