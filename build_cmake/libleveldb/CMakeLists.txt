#
# Port from ../../src/Makefile.leveldb.include

cmake_minimum_required(VERSION 3.12)

# This project can use C11, but will gracefully decay down to C89.
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED OFF)
set(CMAKE_C_EXTENSIONS OFF)

# This project requires C++11.
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(libleveldb LANGUAGES CXX)

include_directories(../../src/leveldb)
include_directories(../../src/leveldb/include)
include_directories(../../src/leveldb/include/leveldb)
include_directories(../../src/leveldb/port)

# libleveldb SOURCES
list(APPEND libleveldb_SOURCES
        ../../src/leveldb/port/atomic_pointer.h
        ../../src/leveldb/port/port_example.h
        ../../src/leveldb/port/port_posix.h
        ../../src/leveldb/port/win/stdint.h
        ../../src/leveldb/port/port.h
        ../../src/leveldb/port/port_win.h
        ../../src/leveldb/port/thread_annotations.h
        ../../src/leveldb/include/leveldb/db.h
        ../../src/leveldb/include/leveldb/options.h
        ../../src/leveldb/include/leveldb/comparator.h
        ../../src/leveldb/include/leveldb/filter_policy.h
        ../../src/leveldb/include/leveldb/slice.h
        ../../src/leveldb/include/leveldb/table_builder.h
        ../../src/leveldb/include/leveldb/env.h
        ../../src/leveldb/include/leveldb/c.h
        ../../src/leveldb/include/leveldb/iterator.h
        ../../src/leveldb/include/leveldb/cache.h
        ../../src/leveldb/include/leveldb/dumpfile.h
        ../../src/leveldb/include/leveldb/table.h
        ../../src/leveldb/include/leveldb/write_batch.h
        ../../src/leveldb/include/leveldb/status.h
        ../../src/leveldb/db/log_format.h
        ../../src/leveldb/db/memtable.h
        ../../src/leveldb/db/version_set.h
        ../../src/leveldb/db/write_batch_internal.h
        ../../src/leveldb/db/filename.h
        ../../src/leveldb/db/version_edit.h
        ../../src/leveldb/db/dbformat.h
        ../../src/leveldb/db/builder.h
        ../../src/leveldb/db/log_writer.h
        ../../src/leveldb/db/db_iter.h
        ../../src/leveldb/db/skiplist.h
        ../../src/leveldb/db/db_impl.h
        ../../src/leveldb/db/table_cache.h
        ../../src/leveldb/db/snapshot.h
        ../../src/leveldb/db/log_reader.h
        ../../src/leveldb/table/filter_block.h
        ../../src/leveldb/table/block_builder.h
        ../../src/leveldb/table/block.h
        ../../src/leveldb/table/two_level_iterator.h
        ../../src/leveldb/table/merger.h
        ../../src/leveldb/table/format.h
        ../../src/leveldb/table/iterator_wrapper.h
        ../../src/leveldb/util/crc32c.h
        ../../src/leveldb/util/env_posix_test_helper.h
        ../../src/leveldb/util/arena.h
        ../../src/leveldb/util/random.h
        ../../src/leveldb/util/posix_logger.h
        ../../src/leveldb/util/hash.h
        ../../src/leveldb/util/histogram.h
        ../../src/leveldb/util/coding.h
        ../../src/leveldb/util/testutil.h
        ../../src/leveldb/util/mutexlock.h
        ../../src/leveldb/util/logging.h
        ../../src/leveldb/util/testharness.h

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

add_library(libleveldb ${libleveldb_SOURCES})
add_library(libmemenv ${libmemenv_SOURCES})
add_library(leveldb_sse4 ${libleveldb_sse42_SOURCES})