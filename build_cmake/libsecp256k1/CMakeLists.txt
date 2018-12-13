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

project(secp256k1 VERSION 0.1 LANGUAGES C)

set(CMAKE_C_STANDARD 11)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

set(SECP256K1_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/../../src/secp256k1)

# =================================
# configuation options
# =================================

option(STATICPRECOMPUTATION "enable precomputed ecmult table for signing" ON)

option(ENDOMORPHISM "enable endomorphism optimization" OFF)

option(COVERAGE "enable compiler flags to support kcov coverage analysis" OFF)

option(BENCHMARK "compile benchmark" OFF)

option(TESTS "compile tests" ON)

option(OPENSSL_TESTS "enable OpenSSL tests, if OpenSSL is available" OFF)

option(EXHAUSTIVE_TESTS "compile exhaustive tests" ON)

option(EXPERIMENTAL "allow experimental configure options" OFF)

option(MODULE_ECDH "enable ECDH shared secret computation (experimental)" OFF)

option(MODULE_RECOVERY "enable ECDSA pubkey recovery module" ON)

option(JNI "enable libsecp256k1_jni" OFF)

# =================================
#  Multi-configuration check: for VS/Xcode
# =================================
if(CMAKE_CONFIGURATION_TYPES)
    message("Multi-configuration generator")
    set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Multi config types" FORCE)
else()
    message("Single-configuration generator")
endif()

# =================================
# general checking
# =================================

include (CheckTypeSize)
include (CheckCSourceCompiles)
include (CheckIncludeFile)
include (TestBigEndian)

# check __int128
check_type_size (__int128 HAVE___INT128)
if(HAVE___INT128)
    message(STATUS "check __int128: ok")
    list(APPEND DEFAULT "HAVE___INT128")
endif()

# check endian
test_big_endian(is_big_endian)
if(is_big_endian)
    message(STATUS "check endian: big endian")
else()
    message(STATUS "check endian: little endian")
endif()

# check __builtin_expect
check_c_source_compiles ("
int main(void) { if (__builtin_expect(0, 0)) return 1; return 0; }
" HAVE___BUILTIN_EXPECT)

if(HAVE___BUILTIN_EXPECT)
    message(STATUS "check __builtin_expec: ok")
    list(APPEND DEFAULT "HAVE_BUILTIN_EXPECT")
endif()

# =================================
#  SECP256K1_BUILD
# =================================
list(APPEND DEFAULT "SECP256K1_BUILD")

# =================================
# ecumlt static precomputation
# =================================
if (STATICPRECOMPUTATION)
    add_executable(gen_context ${SECP256K1_ROOT}/src/gen_context.c)
    target_include_directories(gen_context PRIVATE ${SECP256K1_ROOT})
    add_custom_command(
            OUTPUT ${SECP256K1_ROOT}/src/ecmult_static_context.h
            COMMAND gen_context
            WORKING_DIRECTORY ${SECP256K1_ROOT})
    add_custom_target(run_gen ALL
            DEPENDS
            ${SECP256K1_ROOT}/src/ecmult_static_context.h gen_context)
    list(APPEND DEFAULT "USE_ECMULT_STATIC_PRECOMPUTATION")
    if (CMAKE_CROSSCOMPILING)
        message(FATAL_ERROR "ecumlt static precomputation not work on cross-compiling, using -DSTATICPRECOMPUTATION=no")
    endif()
endif ()

# =================================
# assembly optimization
# =================================
if (ASM)
    if (ASM MATCHES x86_64)
        set(ASM_X86_64 1)
    elseif(ASM MATCHES arm)
        set(ASM_ARM 1)
    else()
        message(FATAL_ERROR "unknown ASM option : ${ASM}")
    endif()
else()
    set(ASM OFF)
endif()
if(ASM_X86_64)
    list(APPEND DEFAULT "USE_ASM_X86_64")
endif()
if(ASM_ARM)
    list(APPEND DEFAULT "USE_EXTERNAL_ASM")
endif()

# =================================
# bignum implementation selection
# =================================
if(BIGNUM)
    if(BIGNUM MATCHES auto)
        find_package(GMP)
        if(GMP_FOUND)
            set(BIGNUM_GMP 1)
        else()
            set(BIGNUM_NONE 1)
        endif()
    elseif(BIGNUM MATCHES gmp)
        find_package(GMP REQUIRED)
        if(GMP_FOUND)
            set(BIGNUM_GMP 1)
        endif()
    elseif(BIGNUM MATCHES none)
        set(BIGNUM_NONE 1)
    else()
        message(FATAL_ERROR "unknown BIGNUM implementation option : ${BIGNUM}")
    endif()
else()
   set(BIGNUM "none")
   set(BIGNUM_NONE 1)
endif()

if(BIGNUM_GMP)
   list(APPEND DEFAULT "USE_NUM_GMP")
   list(APPEND DEFAULT "USE_FIELD_INV_NUM")
   list(APPEND DEFAULT "USE_SCALAR_INV_NUM")
   set(LINK_GMP_LIB gmp)
endif()

if(BIGNUM_NONE)
   list(APPEND DEFAULT "USE_NUM_NONE")
   list(APPEND DEFAULT "USE_FIELD_INV_BUILTIN")
   list(APPEND DEFAULT "USE_SCALAR_INV_BUILTIN")
endif()

# =================================
# select field implementation
# =================================
if(FIELD)
    if(FIELD MATCHES auto)
        if(ASM_X86_64 OR HAVE___INT128)
            set(USE_F64 1)
        else()
            set(USE_F32 1)
        endif()
    elseif(FIELD MATCHES 32)
        set(USE_F32 1)
    elseif(FIELD MATCHES 64)
        if(NOT HAVE___INT128 AND NOT ASM_X86_64)
            message(FATAL_ERROR "64bit field explicitly requested but neither __int128 support or x86_64 assembly available")
        endif()
        set(USE_F64 1)
    else()
        message(FATAL_ERROR "unknown FIELD implementation option : ${FIELD}")
    endif()
else()
    # no input should do the auto check
    if(ASM_X86_64 OR HAVE___INT128)
        set(USE_F64 1)
        set(FIELD "64bits")
    else()
        set(USE_F32 1)
        set(FIELD "32bits")
    endif()
endif()

if (USE_F32)
    list(APPEND DEFAULT "USE_FIELD_10X26")
endif()
if (USE_F64)
    list(APPEND DEFAULT "USE_FIELD_5X52")
endif()

# =================================
# select scalar implementation
# =================================
if(SCALAR)
    if(SCALAR MATCHES auto)
        if(HAVE___INT128)
            set(USE_S64 1)
        else()
            set(USE_S32 1)
        endif()
    elseif(SCALAR MATCHES 32)
        set(USE_S32 1)
    elseif(SCALAR MATCHES 64)
        if(NOT HAVE___INT128)
            message(FATAL_ERROR "64bit scalar explicitly requested but __int128 support not available")
        endif()
        set(USE_S64 1)
    else()
        message(FATAL_ERROR "unknown SCALAR implementation option : ${SCALAR}")
    endif(SCALAR MATCHES auto)
else()
    if(HAVE___INT128)
        set(USE_S64 1)
        set(SCALAR "64bits")
    else()
        set(USE_S32 1)
        set(SCALAR "32bits")
    endif()
endif()

if(USE_S32)
    list(APPEND DEFAULT "USE_SCALAR_8X32")
endif()
if (USE_S64)
    list(APPEND DEFAULT "USE_SCALAR_4X64")
endif()

# =================================
# endomorphism optimization
# =================================
if(ENDOMORPHISM)
    list(APPEND DEFAULT "USE_ENDOMORPHISM")
endif()


# =================================
# ECDSA pubkey recovery module
# =================================
if(MODULE_RECOVERY)
        list(APPEND DEFAULT "ENABLE_MODULE_RECOVERY")
endif()

# =================================
# Experimental modules
# =================================
if(EXPERIMENTAL)
    # ECDH modules
    if(MODULE_ECDH)
        list(APPEND DEFAULT "ENABLE_MODULE_ECDH")
    endif()
    message("******")
    message("WARNING: experimental build")
    message("Experimental features do not have stable APIs or properties, and may not be safe for production use.")
    message("Building ECDH module: ${MODULE_ECDH}")
    message("******")
else()
    if(MODULE_ECDH)
       message(FATAL_ERROR "ECDH module is experimental. Use -DEXPERIMENTAL=on to allow")
    endif()
    if(ASM_ARM)
       message(FATAL_ERROR "ARM assembly optimization is experimental. Use -DEXPERIMENTAL=on to allow")
    endif()
endif()


# =================================
# The Check target :
#    Which contains all tests, keep competiable with aotomake's 'make check'
# =================================
add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND})

# =================================
# coverage analysis config
# =================================
if (COVERAGE)
    list(APPEND DEFAULT "COVERAGE")
    set(COVERAGE_COMPILE_OPTIONS -O0 --coverage)
    set(COVERAGE_LINK_FLAGS --coverage)
endif()

# =================================
# TESTS
# =================================
if (TESTS)
    enable_testing()
    list(APPEND TEST_CONF ${DEFAULT})
    # coverage analysis
    if (NOT COVERAGE)
        list(APPEND TEST_CONF "VERIFY")
    endif()
    if (OPENSSL_TESTS)
        find_package(OPENSSL REQUIRED)
        if(OPENSSL_FOUND)
            list(APPEND TEST_CONF "ENABLE_OPENSSL_TESTS")
        else()
            message(FATAL_ERROR "Required OpenSSL library to enable OPENSSL_TESTS")
        endif()
    endif()
    add_executable(tests ${SECP256K1_ROOT}/src/tests.c)
    target_compile_definitions(tests PRIVATE ${TEST_CONF})
    target_include_directories(tests PRIVATE ${SECP256K1_ROOT} ${SECP256K1_ROOT}/include)
    if (STATICPRECOMPUTATION)
        add_dependencies(tests run_gen)
    endif()
    if (OPENSSL_TESTS)
        target_include_directories(tests PRIVATE ${OPENSSL_INCLUDE_DIR})
        target_link_libraries(tests crypto)
    endif()
    if(BIGNUM_GMP)
        target_link_libraries(tests ${LINK_GMP_LIB})
    endif()
    if(COVERAGE)
        target_compile_options(tests PRIVATE ${COVERAGE_COMPILE_OPTIONS})
        target_link_libraries(tests ${COVERAGE_LINK_FLAGS})
    endif()

    # add test, to speed up the execuatation, only do 1-round
    add_test(tests tests 1)
    add_dependencies(check tests)

    get_target_property(tests_output_dir tests EXECUTABLE_OUTPUT_PATH)
endif()

# =================================
# EXHAUSTIVE_TESTS
# =================================
if (EXHAUSTIVE_TESTS)
    list(APPEND EXHAUSTIVE_TESTS_CONF ${DEFAULT})
    if (NOT COVERAGE)
        list(APPEND EXHAUSTIVE_TESTS_CONF "VERIFY")
    endif()
    add_executable(exhaustive_test ${SECP256K1_ROOT}/src/tests_exhaustive.c)
    target_compile_definitions(exhaustive_test PRIVATE ${EXHAUSTIVE_TESTS_CONF})
    target_include_directories(exhaustive_test PRIVATE ${SECP256K1_ROOT})
    add_test(exhaustive_test exhaustive_test)
    if (STATICPRECOMPUTATION)
        add_dependencies(exhaustive_test run_gen)
    endif()
    if(BIGNUM_GMP)
        target_link_libraries(exhaustive_test ${LINK_GMP_LIB})
    endif()
    if(COVERAGE)
        target_compile_options(exhaustive_test PRIVATE ${COVERAGE_COMPILE_OPTIONS})
        target_link_libraries(exhaustive_test ${COVERAGE_LINK_FLAGS})
    endif()
    add_dependencies(check exhaustive_test)
endif()

# =================================
# coverage analysis report
# =================================
if (COVERAGE)
    find_program( GCOV_PATH gcov )
    find_program( LCOV_PATH  NAMES lcov lcov.bat lcov.exe lcov.perl)
    find_program( GENHTML_PATH NAMES genhtml genhtml.perl genhtml.bat )
    if(NOT GCOV_PATH)
        message(WARNNING "gcov not found! Please install gcov before generate the coverage report...")
    endif()
    if(NOT LCOV_PATH)
        message(WARNNING "lcov not found! Please install lcov before generate the coverage report")
    endif()
    if(NOT GENHTML_PATH)
        message(WARNNING "genhtml not found! Please install genhtml before generate the coverage report")
    endif()
    set(Coverage_NAME gen_coverage_report)

    add_custom_target(${Coverage_NAME}
            # Create baseline to make sure untouched files show up in the report
            COMMAND ${LCOV_PATH} --gcov-tool ${GCOV_PATH} -c -i -d . -o ${Coverage_NAME}.base
            # Capturing lcov counters and generating report
            COMMAND ${LCOV_PATH} --gcov-tool ${GCOV_PATH} --directory . --capture --output-file ${Coverage_NAME}.info
            # add baseline counters
            COMMAND ${LCOV_PATH} --gcov-tool ${GCOV_PATH} -a ${Coverage_NAME}.base -a ${Coverage_NAME}.info --output-file ${Coverage_NAME}.total
            COMMAND ${GENHTML_PATH} -o ${Coverage_NAME} ${PROJECT_BINARY_DIR}/${Coverage_NAME}.info
            COMMAND ${CMAKE_COMMAND} -E remove ${Coverage_NAME}.base ${Coverage_NAME}.total ${PROJECT_BINARY_DIR}/${Coverage_NAME}.info
            WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
            COMMENT "Processing code coverage counters and generating report."
            )
    add_custom_command(
            TARGET ${Coverage_NAME} PRE_BUILD
            # Cleanup lcov
            COMMAND ${LCOV_PATH} --gcov-tool ${GCOV_PATH} -directory . --zerocounters
            COMMENT "Resetting code coverage counters to zero."
    )
    add_dependencies(${Coverage_NAME} check)
endif()

# =================================
# libsecp256k1
# =================================
if (NOT JNI)
    add_library(secp256k1 STATIC ${SECP256K1_ROOT}/src/secp256k1.c)
    target_compile_definitions(secp256k1 PRIVATE ${DEFAULT})
    target_include_directories(secp256k1 PRIVATE ${SECP256K1_ROOT})
    #set(COMPILE_OPTIONS -O3 -W -std=c89 -pedantic -Wall -Wextra -Wcast-align
    #            -Wnested-externs -Wshadow -Wstrict-prototypes -Wno-unused-function
    #            -Wno-long-long -Wno-overlength-strings -fvisibility=hidden)
    #target_compile_options(secp256k1 PRIVATE ${COMPILE_OPTIONS})
else (JNI)
# =================================
# With JNI support
# =================================
    # check jdk
    message(STATUS "check if java avaible")
    set(MINIMUM_REQUIRED_JAVA_VERSION 1.6)  # guava 18 minimum required
    find_package(Java ${MINIMUM_REQUIRED_JAVA_VERSION} REQUIRED)
    if(Java_FOUND)
        message(STATUS "check Java installed : ok")
        message(STATUS "  Java Version  : ${Java_VERSION}")
        message(STATUS "  Java RunTime  : ${Java_JAVA_EXECUTABLE}")
        message(STATUS "  Java Compiler : ${Java_JAVAC_EXECUTABLE}")
    else()
        message(FATAL_ERROR "Check Java installed : failed, Please install JDK first")
    endif()

    find_package(JNI)
    if (JNI_FOUND)
        message (STATUS "JNI_INCLUDE_DIRS=${JNI_INCLUDE_DIRS}")
        message (STATUS "JNI_LIBRARIES=${JNI_LIBRARIES}")
    else()
        message (FATAL_ERROR "JNI not found")
    endif()

    if (NOT MODULE_ECDH)
        message (FATAL_ERROR "JNI require ECDH Module. Please enable ECDH (-DMODULE_ECDH=on) and try again.")
    endif()

    Set(JNI_SRC_FILES
            src/secp256k1.c
            src/java/org_bitcoin_NativeSecp256k1.c
            src/java/org_bitcoin_Secp256k1Context.c)

    add_library(secp256k1 SHARED ${JNI_SRC_FILES})
    target_compile_definitions(secp256k1 PRIVATE ${DEFAULT})
    target_include_directories(secp256k1 PRIVATE . src ${JNI_INCLUDE_DIRS})

    Set(JAVA_SRC_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/src/java)
    Set(GUAVA_JAR ${JAVA_SRC_ROOT}/guava/guava-18.0.jar)
    Set(GUAVA_URL https://search.maven.org/remotecontent?filepath=com/google/guava/guava/18.0/guava-18.0.jar)

    # check guava
    message(STATUS "JNI enabled, check if guava has been installed at ${GUAVA_JAR}")
    if (NOT EXISTS ${GUAVA_JAR})
        message(STATUS "guava not found, try to download ${GUAVA_URL} => ${GUAVA_JAR}")
        file(DOWNLOAD ${GUAVA_URL} ${GUAVA_JAR} STATUS status)
        list(GET status 0 status_code)
        list(GET status 1 status_string)
        if(NOT status_code EQUAL 0)
            # clean up the failed download file before exist
            file(REMOVE "${GUAVA_JAR}")
            message(WARNING "Error: downloading failed, ${status_string}")
        else()
            message(STATUS "Download ${GUAVA_URL} ok")
        endif()
    else()
        message(STATUS "check guava installed : ok")
    endif()

    # compile-java
    include(UseJava)
    SET(JAVAORG "org/bitcoin")
    SET(JAVA_SRC_FILES
            ${JAVA_SRC_ROOT}/${JAVAORG}/NativeSecp256k1.java
            ${JAVA_SRC_ROOT}/${JAVAORG}/NativeSecp256k1Test.java
            ${JAVA_SRC_ROOT}/${JAVAORG}/NativeSecp256k1Util.java
            ${JAVA_SRC_ROOT}/${JAVAORG}/Secp256k1Context.java
            )
    add_jar(secp256k1_jni_test_jar
            SOURCES ${JAVA_SRC_FILES}
            INCLUDE_JARS ${GUAVA_JAR})
    get_target_property(secp256k1_jni_test_jarFile secp256k1_jni_test_jar JAR_FILE)

#   # Use custom_target to build java source
#    add_custom_target(compile-java)
#    add_custom_command(
#            TARGET compile-java
#            COMMAND ${Java_JAVAC_EXECUTABLE} -classpath ${GUAVA_JAR} ${JAVA_SRC_FILES}
#            DEPENDS ${JAVA_SRC_FILES})

    # the classpath seperator should platform depends
    set(cp_sep ":")
    if(${CMAKE_HOST_SYSTEM} MATCHES ".*Windows.*")
        set(cp_sep "\\;")
    endif()

    set(_java_library_path ${CMAKE_CURRENT_BINARY_DIR})
    if (MSVC)
        # the dll path for windows
        foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
            set(_java_library_path "${_java_library_path}${cp_sep}${CMAKE_CURRENT_BINARY_DIR}/${OUTPUTCONFIG}")
        endforeach()
    endif()

    # check-java
    add_custom_target(check-java
            COMMAND ${Java_JAVA_EXECUTABLE}
            -Djava.library.path=${_java_library_path}
            -cp ${secp256k1_jni_test_jarFile}${cp_sep}${GUAVA_JAR} ${JAVAORG}/NativeSecp256k1Test)
    add_dependencies(check-java secp256k1_jni_test_jar secp256k1)
endif()

if (STATICPRECOMPUTATION)
    add_dependencies(secp256k1 run_gen)
endif()

if(BIGNUM_GMP)
    target_link_libraries(secp256k1 ${LINK_GMP_LIB})
endif()



# =================================
# BENCHMARK : build bench-xxx
# =================================
if(BENCHMARK)

    list(APPEND Bench_XXX "bench_verify" "bench_sign" "bench_internal" "bench_ecmult")
    if(MODULE_ECDH)
        # bench_ecdh only works when MODULE_ECDH is enabled
        list(APPEND Bench_XXX "bench_ecdh")
    endif()
    if(MODULE_RECOVERY)
        list(APPEND Bench_XXX "bench_recover")
    endif()
    foreach(bench_exec IN LISTS Bench_XXX)
        message(STATUS "add benchmark executable : ${bench_exec}")
        add_executable(${bench_exec} src/${bench_exec}.c )
        add_dependencies(${bench_exec} secp256k1)
        target_include_directories(${bench_exec} PRIVATE . ./src ./include)
        target_compile_definitions(${bench_exec} PRIVATE ${DEFAULT})
        target_link_libraries(${bench_exec} secp256k1)
        if(BIGNUM_GMP)
            target_link_libraries(${bench_exec} ${LINK_GMP_LIB})
        endif()
    endforeach()
endif()

# =================================
# Configuration Info
# =================================
message(STATUS "Build Configuration:")
message("   Using static precomputation: ${STATICPRECOMPUTATION}")
message("   Using assembly optimizations: ${ASM}")
message("   Using field implementation: ${FIELD}")
message("   Using bignum implementation: ${BIGNUM}")
message("   Using scalar implementation: ${SCALAR}")
message("   Using endomorphism optimizations: ${ENDOMORPHISM}")
message("   Building benchmarks: ${BENCHMARK}")
message("   Building for coverage analysis: ${COVERAGE}")
message("   Building ECDH module: ${MODULE_ECDH}")
message("   Building ECDSA pubkey recovery module: ${MODULE_RECOVERY}")
message("   Using jni: ${JNI}")

if(DEBUG)
    message(STATUS "Debug the COMPILE FLAGS settings:")
    foreach(var ${DEFAULT})
       message( "   default = ${var}")
    endforeach()
endif()