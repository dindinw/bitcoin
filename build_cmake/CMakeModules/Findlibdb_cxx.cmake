if (NOT "$ENV{LIBDB_CXX_ROOT}" STREQUAL "")
    set(LIBDB_CXX_DIR $ENV{LIBDB_CXX_ROOT})
endif()
if (NOT "${LIBDB_CXX_ROOT}" STREQUAL "")
    set(LIBDB_CXX_DIR ${LIBDB_CXX_ROOT})
endif()

list(APPEND libdbcxx_EXTRA_PREFIXES /usr/local /opt/local "$ENV{HOME}" ${LIBDB_CXX_DIR})

if(WIN32 AND MINGW)
    list(APPEND libdbcxx_EXTRA_PREFIXES c:/msys64/usr c:/msys64/usr/local)
elseif(APPLE)
    list(APPEND libdbcxx_EXTRA_PREFIXES /usr/local/opt/berkeley-db@4)
endif()

foreach(prefix ${libdbcxx_EXTRA_PREFIXES})
    list(APPEND libdbcxx_INCLUDE_PATHS "${prefix}/include")
    list(APPEND libdbcxx_LIBRARIES_PATHS "${prefix}/lib")
endforeach()

find_path(LIBDB_CXX_INCLUDE_DIR db_cxx.h
        PATHS ${libdbcxx_INCLUDE_PATHS})
find_library(LIBDB_CXX_LIBRARY_RELEASE NAMES db_cxx libdb48
        PATHS ${libdbcxx_LIBRARIES_PATHS})

if(LIBDB_CXX_DEBUG_DIR)
    find_library(LIBDB_CXX_LIBRARY_DEBUG NAMES db_cxx libdb48
        PATHS ${LIBDB_CXX_DEBUG_DIR} ${LIBDB_CXX_DEBUG_DIR}/lib )
endif()

get_property(_isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(_isMultiConfig OR CMAKE_BUILD_TYPE)
    if(NOT LIBDB_CXX_LIBRARY_DEBUG)
        set(LIBDB_CXX_LIBRARY_DEBUG ${LIBDB_CXX_LIBRARY_RELEASE})
    endif()
    set(LIBDB_CXX_LIBRARIES optimized ${LIBDB_CXX_LIBRARY_RELEASE} debug ${LIBDB_CXX_LIBRARY_DEBUG})
else()
    # For single-config generators where CMAKE_BUILD_TYPE has no value,
    # just use the release libraries
    set(LIBDB_CXX_LIBRARIES ${LIBDB_CXX_LIBRARY_RELEASE} )
endif()

mark_as_advanced(LIBDB_CXX_INCLUDE_DIR LIBDB_CXX_LIBRARY_RELEASE LIBDB_CXX_LIBRARIES )

message(STATUS "berkeleydb  ${LIBDB_CXX_INCLUDE_DIR} and ${LIBDB_CXX_LIBRARIES}")
