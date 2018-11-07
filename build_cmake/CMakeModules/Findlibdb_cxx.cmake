MESSAGE(STATUS "Using Findlibdb_cxx.cmake...")

find_path(LIBDB_CXX_INCLUDE_DIR db_cxx.h
        /usr/include/
        /usr/local/include/
        /usr/local/opt/berkeley-db@4/include/
)
find_library(LIBDB_CXX_LIBRARIES NAMES db_cxx
        PATHS /usr/lib/ /usr/local/lib/ /usr/local/opt/berkeley-db@4/lib)

mark_as_advanced(LIBDB_CXX_INCLUDE_DIR LIBDB_CXX_LIBRARIES )

