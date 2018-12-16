if (NOT "$ENV{LIBEVNET_ROOT}" STREQUAL "")
    set(ENV{LIBEVENT_ROOT_DIR} $ENV{LIBEVNET_ROOT})
endif()
find_path(LIBEVENT_INCLUDE_DIR event.h
        /usr/include/ /usr/local/include/ ${LIBEVENT_ROOT_DIR}/indclude/)
find_library(LIBEVENT_LIB NAMES event
        PATHS /usr/lib/ /usr/local/lib/ ${LIBEVENT_ROOT_DIR}/lib/)

find_library(LIBEVENT_PTHREAD_LIB NAMES event_pthreads
        PATHS /usr/lib/ /usr/local/lib/ ${LIBEVENT_ROOT_DIR}/lib/)

mark_as_advanced(LIBEVNET_INCLUDE_DIR LIBEVENT_LIB LIBEVENT_PTHREAD_LIB )

MESSAGE(STATUS "Found Libevent at ${LIBEVENT_INCLUDE_DIR}  ${LIBEVENT_LIB} ${LIBEVENT_PTHREAD_LIB}")