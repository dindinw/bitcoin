# using the MakeLinke.cmake to do the relink of config files
# the arguments can be passed from outside by using cmake -D var=value
include(${CMAKE_CURRENT_BINARY_DIR}/../../CMakeModules/MakeLink.cmake)
make_link(${BITCOIN_CONFIG_CMAKE} ${BITCOIN_CONFIG})
message(STATUS "relink ${BITCOIN_CONFIG_CMAKE} => ${BITCOIN_CONFIG} ok")
