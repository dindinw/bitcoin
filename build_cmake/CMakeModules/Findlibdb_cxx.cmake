if (NOT "$ENV{LIBDB_CXX_ROOT}" STREQUAL "")
    set(LIBDB_CXX_DIR $ENV{LIBDB_CXX_ROOT})
endif()
find_path(LIBDB_CXX_INCLUDE_DIR db_cxx.h
        ${LIBDB_CXX_DIR}/include
        /usr/include/
        /usr/local/include/
        /usr/local/opt/berkeley-db@4/include/
        )
find_library(LIBDB_CXX_LIBRARIES NAMES db_cxx libdb48
        PATHS ${LIBDB_CXX_DIR}/lib /usr/lib/ /usr/local/lib/ /usr/local/opt/berkeley-db@4/lib)

mark_as_advanced(LIBDB_CXX_INCLUDE_DIR LIBDB_CXX_LIBRARIES )

message(STATUS "berkeleydb  ${LIBDB_CXX_INCLUDE_DIR} and ${LIBDB_CXX_LIBRARIES}")
