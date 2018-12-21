if (NOT "${LIBMINUPNPC_ROOT}" STREQUAL "")
    set(LIBMINUPNPC_DIR ${LIBMINUPNPC_ROOT})
endif()
if (NOT "$ENV{LIBMINUPNPC_ROOT}" STREQUAL "")
    set(LIBMINUPNPC_DIR $ENV{LIBMINUPNPC_ROOT})
endif()

set(Libminiupnpc_EXTRA_PREFIXES /usr/local /opt/local "$ENV{HOME}" ${LIBMINUPNPC_DIR})
foreach(prefix ${Libminiupnpc_EXTRA_PREFIXES})
    list(APPEND Libminiupnpc_INCLUDE_PATHS "${prefix}/include")
    list(APPEND Libminiupnpc_LIBRARIES_PATHS "${prefix}/lib")
endforeach()

find_path (LIBMINIUPNPC_INCLUDE_DIR NAMES miniupnpc/miniupnpc.h
        PATHS ${Libminiupnpc_INCLUDE_PATHS})
find_library (LIBMINIUPNPC_LIB
        NAMES miniupnpc libminiupnpc
        PATHS ${Libminiupnpc_LIBRARIES_PATHS})


list (APPEND LIBMINUPNPC_INCLUDE_DIRS ${LIBMINIUPNPC_INCLUDE_DIR})
list (APPEND LIBMINIUPNPC_LIBRARIES   ${LIBMINIUPNPC_LIB})

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (Libminiupnpc DEFAULT_MSG LIBMINUPNPC_INCLUDE_DIRS LIBMINIUPNPC_LIBRARIES)
mark_as_advanced(LIBMINUPNPC_INCLUDE_DIRS LIBMINIUPNPC_LIBRARIES)

message(STATUS "Libminiupnpc ${LIBMINUPNPC_INCLUDE_DIRS} ${LIBMINIUPNPC_LIBRARIES}")
