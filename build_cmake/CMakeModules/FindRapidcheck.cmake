if (NOT "${RAPIDCHECK_ROOT}" STREQUAL "")
    set(RAPIDCHECK_DIR ${RAPIDCHECK_ROOT})
endif()
if (NOT "$ENV{RAPIDCHECK_ROOT}" STREQUAL "")
    set(RAPIDCHECK_DIR $ENV{RAPIDCHECK_ROOT})
endif()

set(Rapidcheck_EXTRA_PREFIXES /usr/local /opt/local "$ENV{HOME}" ${RAPIDCHECK_DIR})
foreach(prefix ${Rapidcheck_EXTRA_PREFIXES})
    list(APPEND Rapidcheck_INCLUDE_PATHS "${prefix}/include")
    list(APPEND Rapidcheck_LIBRARIES_PATHS "${prefix}/lib")
endforeach()

find_path (RAPIDCHECK_INCLUDE_DIR NAMES rapidcheck.h
        PATHS ${Rapidcheck_INCLUDE_PATHS})
find_library (RAPIDCHECK_LIB
        NAMES rapidcheck librapidcheck
        PATHS ${Rapidcheck_LIBRARIES_PATHS})


list (APPEND RAPIDCHECK_INCLUDE_DIRS ${RAPIDCHECK_INCLUDE_DIR})
list (APPEND RAPIDCHECK_LIBRARIES    ${RAPIDCHECK_LIB})

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (Rapidcheck DEFAULT_MSG RAPIDCHECK_INCLUDE_DIRS RAPIDCHECK_LIBRARIES)
mark_as_advanced(RAPIDCHECK_INCLUDE_DIRS RAPIDCHECK_LIBRARIES)

if(Rapidcheck_FOUND)
    message(STATUS "Rapidcheck ${RAPIDCHECK_INCLUDE_DIRS} ${RAPIDCHECK_LIBRARIES}")
else(Rapidcheck_FIND_REQUIRED)
    message(SEND_ERROR "Unable to find Rapidcheck.\nYour might need to specifiy RAPIDCHECK_ROOT")
endif()