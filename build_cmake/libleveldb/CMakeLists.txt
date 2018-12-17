#
# Port from ../../src/Makefile.leveldb.include

cmake_minimum_required(VERSION 3.5)

# This project requires C++11.
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(libleveldb LANGUAGES CXX)

# libleveldb SOURCES
list(APPEND libleveldb_SOURCES
        ../../src/leveldb/db/builder.cc
        ../../src/leveldb/db/c.cc
        ../../src/leveldb/db/dbformat.cc
        ../../src/leveldb/db/db_impl.cc
        ../../src/leveldb/db/db_iter.cc
        ../../src/leveldb/db/dumpfile.cc
        ../../src/leveldb/db/filename.cc
        ../../src/leveldb/db/log_reader.cc
        ../../src/leveldb/db/log_writer.cc
        ../../src/leveldb/db/memtable.cc
        ../../src/leveldb/db/repair.cc
        ../../src/leveldb/db/table_cache.cc
        ../../src/leveldb/db/version_edit.cc
        ../../src/leveldb/db/version_set.cc
        ../../src/leveldb/db/write_batch.cc
        ../../src/leveldb/table/block_builder.cc
        ../../src/leveldb/table/block.cc
        ../../src/leveldb/table/filter_block.cc
        ../../src/leveldb/table/format.cc
        ../../src/leveldb/table/iterator.cc
        ../../src/leveldb/table/merger.cc
        ../../src/leveldb/table/table_builder.cc
        ../../src/leveldb/table/table.cc
        ../../src/leveldb/table/two_level_iterator.cc
        ../../src/leveldb/util/arena.cc
        ../../src/leveldb/util/bloom.cc
        ../../src/leveldb/util/cache.cc
        ../../src/leveldb/util/coding.cc
        ../../src/leveldb/util/comparator.cc
        ../../src/leveldb/util/crc32c.cc
        ../../src/leveldb/util/env.cc
        ../../src/leveldb/util/env_posix.cc
        ../../src/leveldb/util/filter_policy.cc
        ../../src/leveldb/util/hash.cc
        ../../src/leveldb/util/histogram.cc
        ../../src/leveldb/util/logging.cc
        ../../src/leveldb/util/options.cc
        ../../src/leveldb/util/status.cc
        )

if (WIN32)
    list(APPEND libleveldb_SOURCES
        ../../src/leveldb/util/env_win.cc
        ../../src/leveldb/port/port_win.cc
        )
    add_definitions(-DLEVELDB_PLATFORM_WINDOWS)
else()
    add_definitions(-DLEVELDB_PLATFORM_POSIX)
    if(APPLE)
        add_definitions(-DOS_MACOSX)
    endif()
    list(APPEND libleveldb_SOURCES
        ../../src/leveldb/port/port_posix.cc
        )
endif()

# libmemenv_SOURCES

list(APPEND libmemenv_SOURCES
        ../../src/leveldb/helpers/memenv/memenv.cc
        ../../src/leveldb/helpers/memenv/memenv.h
    )

# libleveldb_sse42_SOURCES
list(APPEND libleveldb_sse42_SOURCES
        ../../src/leveldb/port/port_posix_sse.cc
    )

add_library(leveldb ${libleveldb_SOURCES})
add_library(memenv STATIC ${libmemenv_SOURCES})
add_library(leveldb_sse42 STATIC ${libleveldb_sse42_SOURCES})

target_include_directories(leveldb PRIVATE
        ../../src/leveldb/include
        ../../src/leveldb/include/leveldb
        ../../src/leveldb
)

target_include_directories(memenv PRIVATE
        ../../src/leveldb/include
        ../../src/leveldb/include/leveldb
        ../../src/leveldb
)

target_include_directories(leveldb_sse42 PRIVATE
        ../../src/leveldb/include
        ../../src/leveldb/include/leveldb
        ../../src/leveldb
        ../../src/leveldb/port
)
