# - Try to find the LibEvent config processing library
# Once done this will define
#
# LIBEVENT_FOUND - System has LibEvent
# LIBEVENT_INCLUDE_DIR - the LibEvent include directory
# LIBEVENT_LIBRARIES 0 The libraries needed to use LibEvent

set(LIBEVENT_ROOT CACHE PATH "Root directory of libevent installation")
set(LibEvent_EXTRA_PREFIXES /usr/local /opt/local "$ENV{HOME}" ${LIBEVENT_ROOT})
foreach(prefix ${LibEvent_EXTRA_PREFIXES})
    list(APPEND LibEvent_INCLUDE_PATHS "${prefix}/include")
    list(APPEND LibEvent_LIBRARIES_PATHS "${prefix}/lib")
endforeach()

find_path     (LIBEVENT_INCLUDE_DIR NAMES event.h        PATHS ${LibEvent_INCLUDE_PATHS})
find_library  (LIBEVENT_LIB         NAMES event          PATHS ${LibEvent_LIBRARIES_PATHS})
find_library  (LIBEVENT_CORE_LIB    NAMES event_core     PATHS ${LibEvent_LIBRARIES_PATHS})
find_library  (LIBEVENT_EXTRA_LIB   NAMES event_extra    PATHS ${LibEvent_LIBRARIES_PATHS})
find_library  (LIBEVENT_PTHREAD_LIB NAMES event_pthreads PATHS ${LibEvent_LIBRARIES_PATHS})
find_library  (LIBEVENT_SSL_LIB     NAMES event_openssl  PATHS ${LibEvent_LIBRARIES_PATHS})

include (FindPackageHandleStandardArgs)

set (LIBEVENT_INCLUDE_DIRS ${LIBEVENT_INCLUDE_DIR})
set (LIBEVENT_LIBRARIES
        ${LIBEVENT_LIB}
        ${LIBEVENT_SSL_LIB}
        ${LIBEVENT_CORE_LIB}
        ${LIBEVENT_EXTRA_LIB}
        ${LIBEVENT_PTHREAD_LIB}
        ${LIBEVENT_EXTRA_LIB})

find_package_handle_standard_args (LIBEVENT DEFAULT_MSG LIBEVENT_LIBRARIES LIBEVENT_INCLUDE_DIR)
mark_as_advanced(LIBEVENT_INCLUDE_DIRS LIBEVENT_LIBRARIES)