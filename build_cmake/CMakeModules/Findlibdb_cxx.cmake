MESSAGE(STATUS "Using Findlibdb_cxx.cmake...")
if (NOT "$ENV{LIBDB_CXX_ROOT}" STREQUAL "")
    set(ENV{LIBDB_CXX_DIR} $ENV{LIBDB_CXX_ROOT})
    set(LIBDB_CXX_INCLUDE_DIR $ENV{LIBDB_CXX_ROOT}/include)
    set(LIBDB_CXX_LIBRARIES $ENV{LIBDB_CXX_ROOT}/lib )
endif()
find_path(LIBDB_CXX_INCLUDE_DIR db_cxx.h
        /usr/include/
        /usr/local/include/
        /usr/local/opt/berkeley-db@4/include/
)
find_library(LIBDB_CXX_LIBRARIES NAMES db_cxx
        PATHS /usr/lib/ /usr/local/lib/ /usr/local/opt/berkeley-db@4/lib)

mark_as_advanced(LIBDB_CXX_INCLUDE_DIR LIBDB_CXX_LIBRARIES )

MESSAGE(STATUS "Found libdb at ${LIBDB_CXX_INCLUDE_DIR} and ${LIBDB_CXX_LIBRARIES}")
