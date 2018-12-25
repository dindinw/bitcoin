if(ZeroMQ_DIR)
    find_package(ZeroMQ)
    if (ZeroMQ_FOUND)
        #message(STATUS "ZeroMQ_INCLUDE_DIR= ${ZeroMQ_INCLUDE_DIR} ")
        #message(STATUS "ZeroMQ_LIBRARY= ${ZeroMQ_LIBRARY}")
        #message(STATUS "ZeroMQ_STATIC_LIBRARY= ${ZeroMQ_STATIC_LIBRARY}")
        set ( ZMQ_LIBRARY ${ZeroMQ_STATIC_LIBRARY} )
        set ( ZMQ_INCLUDE_DIR ${ZeroMQ_INCLUDE_DIR} )
    endif()
else()
    include(Common)
    # Support preference of static libs by adjusting CMAKE_FIND_LIBRARY_SUFFIXES
    if( ZMQ_USE_STATIC_LIBS )
        to_static_find_libary_suffixes(_orig_CMAKE_FIND_LIBRARY_SUFFIXES)
    endif()

    if (NOT "$ENV{ZMQ_ROOT_DIR}" STREQUAL "")
        set(ENV{ZMQ_DIR} $ENV{ZMQ_ROOT_DIR})
    endif()

    find_path ( ZMQ_INCLUDE_DIR zmq.h
            ${ZMQ_DIR}/include/
            /usr/include/
            /usr/local/include/
            )
    find_library ( ZMQ_LIBRARY NAMES zmq libzmq
            PATHS ${ZMQ_DIR}/lib/ /usr/lib/ /usr/local/lib/
            )

    # Restore the original find library ordering
    if( ZMQ_USE_STATIC_LIBS )
        restore_find_library_suffixes(_orig_CMAKE_FIND_LIBRARY_SUFFIXES)
    endif()
endif()

set ( ZMQ_LIBRARIES ${ZMQ_LIBRARY} )
set ( ZMQ_INCLUDE_DIRS ${ZMQ_INCLUDE_DIR} )
include ( FindPackageHandleStandardArgs )
find_package_handle_standard_args ( ZMQ DEFAULT_MSG ZMQ_LIBRARY ZMQ_INCLUDE_DIR )

mark_as_advanced(ZMQ_INCLUDE_DIRS ZMQ_LIBRARIES )

message(STATUS "libzmq ${ZMQ_INCLUDE_DIRS} ${ZMQ_LIBRARIES}")