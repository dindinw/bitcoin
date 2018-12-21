
list(APPEND libbitcoin_zmq_a_SOURCES
  ../../src/zmq/zmqabstractnotifier.cpp
  ../../src/zmq/zmqnotificationinterface.cpp
  ../../src/zmq/zmqpublishnotifier.cpp
  ../../src/zmq/zmqrpc.cpp)

add_library(bitcoin_zmq STATIC ${libbitcoin_zmq_a_SOURCES})
target_compile_definitions(bitcoin_zmq PRIVATE -DENABLE_ZMQ)
if(WIN32)
    target_compile_definitions(bitcoin_zmq PUBLIC NOMINMAX)
    target_compile_definitions(bitcoin_zmq PUBLIC ZMQ_STATIC)
endif()
target_include_directories(bitcoin_zmq PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/zmq
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
        ${ZMQ_INCLUDE_DIRS})
