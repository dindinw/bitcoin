
cmake_minimum_required(VERSION 3.12)

set(CMAKE_C_STANDARD 11)

project(libsecp256k1 LANGUAGES C)

# so that libsecp256k1-config.h can be accessed
include_directories(${CMAKE_CURRENT_BINARY_DIR})

include_directories(../../src/secp256k1)
include_directories(../../src/secp256k1/src)
include_directories(../../src/secp256k1/include)

list(APPEND libsecp256k1_SOURCES
        ../../src/secp256k1/include/secp256k1.h
        ../../src/secp256k1/src/secp256k1.c
        )
# Generate
# (
#echo "/* Generated from config.hin via autoheader for cmake; see bootstrap.sh. */"
#sed -E \
#	-e '1d' \
#	-e '/\bENABLE_/{s:#undef:#define:;s:([^ ]*)$:\1 @\1@:}' \
#	-e 's:#undef:#cmakedefine:' \
#	src/config.hin
#) > src/config.h.cmake
#
include(TestBigEndian)
test_big_endian(WORDS_BIGENDIAN)


# select bignum implementation
# port from ../../src/secp256k1/configure.ac
#
set(ENABLE_MODULE_RECOVERY 1)
set(HAVE_BUILTIN_EXPECT 1)
set(HAVE_DLFCN_H 1)
set(HAVE_INTTYPES_H 1)
set(HAVE_LIBCRYPTO 1)
set(HAVE_MEMORY_H 1)
set(HAVE_STDINT_H 1)
set(HAVE_STDLIB_H 1)
set(HAVE_STRINGS_H 1)
set(HAVE_STRING_H 1)
set(HAVE_SYS_STAT_H 1)
set(HAVE_SYS_TYPES_H 1)
set(HAVE_UNISTD_H 1)
set(HAVE___INT128 1)
set(USE_NUM_NONE 1)
set(USE_FIELD_5X52 1)
set(USE_FIELD_INV_BUILTIN 1)
set(USE_SCALAR_4X64 1)
set(USE_SCALAR_INV_BUILTIN 1)
set(USE_ECMULT_STATIC_PRECOMPUTATION 1)
set(USE_ASM_X86_64 1)
set(STDC_HEADERS 1)

configure_file(libsecp256k1-config.cmake.hin libsecp256k1-config.h)

add_definitions(-DHAVE_CONFIG_H)

#add_definitions(-DHAVE_CONFIG_H)
add_library(secp256k1 ${libsecp256k1_SOURCES})

