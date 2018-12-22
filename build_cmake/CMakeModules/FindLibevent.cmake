# - Try to find the LibEvent config processing library
# Once done this will define
#
# LIBEVENT_FOUND - System has LibEvent
# LIBEVENT_INCLUDE_DIR - the LibEvent include directory
# LIBEVENT_LIBRARIES 0 The libraries needed to use LibEvent

if (NOT "$ENV{LIBEVENT_ROOT}" STREQUAL "")
    set(LIBEVENT_ROOT_DIR $ENV{LIBEVENT_ROOT})
endif()

set(LibEvent_EXTRA_PREFIXES /usr/local /opt/local "$ENV{HOME}" ${LIBEVENT_ROOT_DIR})
foreach(prefix ${LibEvent_EXTRA_PREFIXES})
    list(APPEND LibEvent_INCLUDE_PATHS "${prefix}/include")
    list(APPEND LibEvent_LIBRARIES_PATHS "${prefix}/lib")
endforeach()

find_path     (LIBEVENT_INCLUDE_DIR NAMES event.h        PATHS ${LibEvent_INCLUDE_PATHS})

set (LIBEVENT_INCLUDE_DIRS ${LIBEVENT_INCLUDE_DIR})

find_library  (LIBEVENT_LIB         NAMES event          PATHS ${LibEvent_LIBRARIES_PATHS})
find_library  (LIBEVENT_CORE_LIB    NAMES event_core     PATHS ${LibEvent_LIBRARIES_PATHS})
find_library  (LIBEVENT_EXTRA_LIB   NAMES event_extra    PATHS ${LibEvent_LIBRARIES_PATHS})
if(NOT WIN32)
find_library  (LIBEVENT_PTHREAD_LIB NAMES event_pthreads PATHS ${LibEvent_LIBRARIES_PATHS})
find_library  (LIBEVENT_SSL_LIB     NAMES event_openssl  PATHS ${LibEvent_LIBRARIES_PATHS})
endif()

list (APPEND LIBEVENT_LIBRARIES
        ${LIBEVENT_LIB}
        ${LIBEVENT_CORE_LIB}
        ${LIBEVENT_EXTRA_LIB})
if(NOT WIN32)
    list (APPEND LIBEVENT_LIBRARIES ${LIBEVENT_PTHREAD_LIB} ${LIBEVENT_SSL_LIB})
endif()

# if debug dir specified try to search the debug library
if(LIBEVENT_DEBUG_DIR)
    find_library(LIBEVENT_LIB_DEBUG NAMES event
        PATHS ${LIBEVENT_DEBUG_DIR} ${LIBEVENT_DEBUG_DIR}/lib )
    find_library(LIBEVENT_CORE_LIB_DEBUG NAMES event_core
        PATHS ${LIBEVENT_DEBUG_DIR} ${LIBEVENT_DEBUG_DIR}/lib )
    find_library(LIBEVENT_EXTRA_LIB_DEBUG NAMES event_extra
        PATHS ${LIBEVENT_DEBUG_DIR} ${LIBEVENT_DEBUG_DIR}/lib )
endif()

set(LIBEVENT_LIBRARIES_RELEASE ${LIBEVENT_LIBRARIES})
if(LIBEVENT_LIBRARIES_RELEASE) # must have release library found at least
    get_property(_isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if(_isMultiConfig OR CMAKE_BUILD_TYPE)
        if(NOT LIBEVENT_LIB_DEBUG)
            set(LIBEVENT_LIB_DEBUG ${LIBEVENT_LIB})
        endif()
        list(APPEND _LIBEVENT_LIBS optimized ${LIBEVENT_LIB} debug ${LIBEVENT_LIB_DEBUG})
        if(NOT LIBEVENT_CORE_LIB_DEBUG)
            set(LIBEVENT_CORE_LIB_DEBUG ${LIBEVENT_CORE_LIB})
        endif()
        list(APPEND _LIBEVENT_LIBS optimized ${LIBEVENT_CORE_LIB} debug ${LIBEVENT_CORE_LIB_DEBUG})
        if(NOT LIBEVENT_EXTRA_LIB_DEBUG)
            set(LIBEVENT_EXTRA_LIB_DEBUG ${LIBEVENT_EXTRA_LIB})
        endif()
        list(APPEND _LIBEVENT_LIBS optimized ${LIBEVENT_EXTRA_LIB} debug ${LIBEVENT_EXTRA_LIB_DEBUG})
        set(LIBEVENT_LIBRARIES ${_LIBEVENT_LIBS})
    else()
        # For single-config generators where CMAKE_BUILD_TYPE has no value,
        # just use the release libraries
        set(LIBEVENT_LIBRARIES ${LIBEVENT_LIBRARIES_RELEASE})
    endif()
endif()

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (LIBEVENT DEFAULT_MSG LIBEVENT_LIBRARIES LIBEVENT_INCLUDE_DIR)
mark_as_advanced(LIBEVENT_INCLUDE_DIRS LIBEVENT_LIBRARIES)

message(STATUS "libevent ${LIBEVENT_INCLUDE_DIRS} ${LIBEVENT_LIBRARIES}")
