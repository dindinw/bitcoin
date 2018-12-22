if (NOT "$ENV{LIBDB_CXX_ROOT}" STREQUAL "")
    set(LIBDB_CXX_DIR $ENV{LIBDB_CXX_ROOT})
endif()
find_path(LIBDB_CXX_INCLUDE_DIR db_cxx.h
        ${LIBDB_CXX_DIR}/include
        /usr/include/
        /usr/local/include/
        /usr/local/opt/berkeley-db@4/include/
        )
find_library(LIBDB_CXX_LIBRARY_RELEASE NAMES db_cxx libdb48
        PATHS ${LIBDB_CXX_DIR}/lib /usr/lib/ /usr/local/lib/ /usr/local/opt/berkeley-db@4/lib)

if(LIBDB_CXX_DEBUG_DIR)
    find_library(LIBDB_CXX_LIBARY_DEBUG NAMES db_cxx libdb48
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
