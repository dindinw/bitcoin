
cmake_minimum_required(VERSION 3.12)

set(CMAKE_C_STANDARD 11)

project(libsecp256k1 LANGUAGES C)

include_directories(../../src/secp256k1)
include_directories(../../src/secp256k1/src)
include_directories(../../src/secp256k1/include)

list(APPEND libsecp256k1_SOURCES
        ../../src/secp256k1/include/secp256k1.h
        ../../src/secp256k1/src/secp256k1.c
        )
add_definitions(-DHAVE_CONFIG_H)
add_library(secp256k1 ${libsecp256k1_SOURCES})

