# using the MakeLinke.cmake to do the relink of config files
# the arguments can be passed from outside by using cmake -D var=value
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../CMakeModules")
include(MakeLink)
make_link(${BITCOIN_CONFIG_CMAKE} ${BITCOIN_CONFIG})
message(STATUS "relink ${BITCOIN_CONFIG_CMAKE} => ${BITCOIN_CONFIG} ok")
