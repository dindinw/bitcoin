if (NOT "${LIBMINIUPNPC_ROOT}" STREQUAL "")
    set(LIBMINIUPNPC_DIR ${LIBMINIUPNPC_ROOT})
endif()
if (NOT "$ENV{LIBMINIUPNPC_ROOT}" STREQUAL "")
    set(LIBMINIUPNPC_DIR $ENV{LIBMINIUPNPC_ROOT})
endif()

set(Libminiupnpc_EXTRA_PREFIXES /usr/local /opt/local "$ENV{HOME}" ${LIBMINIUPNPC_DIR})
foreach(prefix ${Libminiupnpc_EXTRA_PREFIXES})
    list(APPEND Libminiupnpc_INCLUDE_PATHS "${prefix}/include")
    list(APPEND Libminiupnpc_LIBRARIES_PATHS "${prefix}/lib")
endforeach()

find_path (LIBMINIUPNPC_INCLUDE_DIR NAMES miniupnpc/miniupnpc.h
        PATHS ${Libminiupnpc_INCLUDE_PATHS})
find_library (LIBMINIUPNPC_LIB
        NAMES miniupnpc libminiupnpc
        PATHS ${Libminiupnpc_LIBRARIES_PATHS})


list (APPEND LIBMINIUPNPC_INCLUDE_DIRS ${LIBMINIUPNPC_INCLUDE_DIR})
list (APPEND LIBMINIUPNPC_LIBRARIES    ${LIBMINIUPNPC_LIB})

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (Libminiupnpc DEFAULT_MSG LIBMINIUPNPC_INCLUDE_DIRS LIBMINIUPNPC_LIBRARIES)
mark_as_advanced(LIBMINIUPNPC_INCLUDE_DIRS LIBMINIUPNPC_LIBRARIES)

if(Libminiupnpc_FOUND)
    message(STATUS "Libminiupnpc ${LIBMINIUPNPC_INCLUDE_DIRS} ${LIBMINIUPNPC_LIBRARIES}")
else(libminiupnc_FIND_REQUIRED)
    message(SEND_ERROR "Unable to find libminiupnpc.\nYour might need to specifiy LIBMINIUPNPC_ROOT")
endif()
