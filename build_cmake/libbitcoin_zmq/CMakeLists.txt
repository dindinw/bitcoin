find_package (ZMQ REQUIRED)

list(APPEND libbitcoin_zmq_a_SOURCES
  ${BITCOIN_ROOT}/src/zmq/zmqabstractnotifier.cpp
  ${BITCOIN_ROOT}/src/zmq/zmqnotificationinterface.cpp
  ${BITCOIN_ROOT}/src/zmq/zmqpublishnotifier.cpp
  ${BITCOIN_ROOT}/src/zmq/zmqrpc.cpp)

add_library(libbitcoin_zmq STATIC ${libbitcoin_zmq_a_SOURCES})
target_compile_definitions(libbitcoin_zmq PRIVATE -DENABLE_ZMQ)
target_include_directories(libbitcoin_zmq PRIVATE ${BITCOIN_ROOT}
        ${BITCOIN_ROOT}/src
        ${BITCOIN_ROOT}/src/zmq
        ${BITCOIN_ROOT}/src/univalue
        ${BITCOIN_ROOT}/src/univalue/include
        ${ZMQ_INCLUDE_DIRS})
