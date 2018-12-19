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

endif()

set ( ZMQ_LIBRARIES ${ZMQ_LIBRARY} )
set ( ZMQ_INCLUDE_DIRS ${ZMQ_INCLUDE_DIR} )
include ( FindPackageHandleStandardArgs )
find_package_handle_standard_args ( ZMQ DEFAULT_MSG ZMQ_LIBRARY ZMQ_INCLUDE_DIR )

mark_as_advanced(ZMQ_INCLUDE_DIRS ZMQ_LIBRARIES )

message(STATUS "Found libzmq at ${ZMQ_INCLUDE_DIRS} ${ZMQ_LIBRARIES}")