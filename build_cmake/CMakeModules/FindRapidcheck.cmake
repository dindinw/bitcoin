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
find_library (RAPIDCHECK_LIBRARY
        NAMES rapidcheck librapidcheck
        PATHS ${Rapidcheck_LIBRARIES_PATHS})

# if debug dir specified try to search the debug library
if(RAPIDCHECK_DEBUG_DIR)
    find_library(RAPIDCHECK_LIBRARY_DEBUG NAMES rapidcheck librapidcheck
        PATHS ${RAPIDCHECK_DEBUG_DIR} ${RAPIDCHECK_DEBUG_DIR}/lib )
endif()

set(RAPIDCHECK_LIBRARY_RELEASE ${RAPIDCHECK_LIBRARY})
if(RAPIDCHECK_LIBRARY_RELEASE) # must have release library found at least
    get_property(_isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if(_isMultiConfig OR CMAKE_BUILD_TYPE)
        if(NOT RAPIDCHECK_LIBRARY_DEBUG)
            set(RAPIDCHECK_LIBRARY_DEBUG ${RAPIDCHECK_LIBRARY_RELEASE})
        endif()
        set(RAPIDCHECK_LIBRARIES optimized ${RAPIDCHECK_LIBRARY_RELEASE} debug ${RAPIDCHECK_LIBRARY_DEBUG})
    else()
        # For single-config generators where CMAKE_BUILD_TYPE has no value,
        # just use the release libraries
        set(RAPIDCHECK_LIBRARIES ${RAPIDCHECK_LIBRARY_RELEASE} )
    endif()
endif()

list (APPEND RAPIDCHECK_INCLUDE_DIRS ${RAPIDCHECK_INCLUDE_DIR})

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (Rapidcheck DEFAULT_MSG RAPIDCHECK_INCLUDE_DIRS RAPIDCHECK_LIBRARIES)
mark_as_advanced(RAPIDCHECK_INCLUDE_DIRS RAPIDCHECK_LIBRARY RAPIDCHECK_LIBRARIES)

if(Rapidcheck_FOUND)
    message(STATUS "Rapidcheck ${RAPIDCHECK_INCLUDE_DIRS} ${RAPIDCHECK_LIBRARIES}")
else(Rapidcheck_FIND_REQUIRED)
    message(SEND_ERROR "Unable to find Rapidcheck.\nYour might need to specifiy RAPIDCHECK_ROOT")
endif()