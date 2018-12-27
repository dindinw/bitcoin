include(CheckIncludeFiles)
include(CheckSymbolExists)

set(PACKAGE_NAME "Bitcoin Core")                    # AC_INIT

set(CLIENT_VERSION_MAJOR 0)
set(CLIENT_VERSION_MINOR 17)
set(CLIENT_VERSION_REVISION 99)
set(CLIENT_VERSION_BUILD 0)
set(CLIENT_VERSION_RC 0)                            # rev version (https://github.com/bitcoin/bitcoin/pull/14612)
set(CLIENT_VERSION_IS_RELEASE false)                # true for release (../doc/release-process.md)
set(COPYRIGHT_YEAR 2018)
set(COPYRIGHT_HOLDERS "The %s developers")
set(COPYRIGHT_HOLDERS_SUBSTITUTION "Bitcoin Core")
string(REPLACE "%s" ${COPYRIGHT_HOLDERS_SUBSTITUTION} COPYRIGHT_HOLDERS_FINAL ${COPYRIGHT_HOLDERS})

# TODO test logic for ENABLE_SHANI/ENABLE_AVX2/ENABLE_SSE41

set(ENABLE_SHANI on CACHE INTERNAL "" )
set(ENABLE_AVX2  on CACHE INTERNAL "" )
set(ENABLE_SSE41 on CACHE INTERNAL "" )

if(WIN32 OR CYGWIN)  # the crypto enhancement code are not supported for windows paltform yet
    set(ENABLE_SHANI off CACHE INTERNAL "" )
    set(ENABLE_AVX2  off CACHE INTERNAL "" )
    set(ENABLE_SSE41 off CACHE INTERNAL "" )
endif()



# BOOST_XXX ...
# Boost is required, HAVE_BOOST_XXX should be set to on directly
set(HAVE_BOOST on)
set(HAVE_BOOST_CHRONO on)
set(HAVE_BOOST_FILESYSTEM on)
set(HAVE_BOOST_SYSTEM on)
set(HAVE_BOOST_THREAD on)
set(HAVE_BOOST_UNIT_TEST_FRAMEWORK on)  # TODO, required if test enable
# Boost >= 1.50 uses sleep_for rather than the now-deprecated sleep, however
# it was broken from 1.50 to 1.52 when backed by nanosleep. Use sleep_for if
# a working version is available, else fall back to sleep. sleep was removed
# after 1.56.
if(Boost_VERSION VERSION_LESS 105200)  #sleep_for broken , use sleep
    set(HAVE_WORKING_BOOST_SLEEP on)
else()                                 # use sleep_for
    set(HAVE_WORKING_BOOST_SLEEP_FOR on)
endif()

# ENDIAN_XXX
CHECK_INCLUDE_FILE("endian.h"     HAVE_ENDIAN_H)
CHECK_INCLUDE_FILE("sys/endian.h" HAVE_SYS_ENDIAN_H)

if(HAVE_ENDIAN_H)
    set(ENDIAN_H "endian.h")
elseif(HAVE_SYS_ENDIAN_H)
    set(ENDIAN_H "sys/endian.h")
else()
endif()

if(ENDIAN_H)
    CHECK_SYMBOL_EXISTS(le16toh ${ENDIAN_H} HAVE_DECL_LE16TOH)
    CHECK_SYMBOL_EXISTS(le32toh ${ENDIAN_H} HAVE_DECL_LE32TOH)
    CHECK_SYMBOL_EXISTS(le64toh ${ENDIAN_H} HAVE_DECL_LE64TOH)
    CHECK_SYMBOL_EXISTS(htole16 ${ENDIAN_H} HAVE_DECL_HTOLE16)
    CHECK_SYMBOL_EXISTS(htole32 ${ENDIAN_H} HAVE_DECL_HTOLE32)
    CHECK_SYMBOL_EXISTS(htole64 ${ENDIAN_H} HAVE_DECL_HTOLE64)
    CHECK_SYMBOL_EXISTS(be16toh ${ENDIAN_H} HAVE_DECL_BE16TOH)
    CHECK_SYMBOL_EXISTS(be32toh ${ENDIAN_H} HAVE_DECL_BE32TOH)
    CHECK_SYMBOL_EXISTS(be64toh ${ENDIAN_H} HAVE_DECL_BE64TOH)
    CHECK_SYMBOL_EXISTS(htobe16 ${ENDIAN_H} HAVE_DECL_HTOBE16)
    CHECK_SYMBOL_EXISTS(htobe32 ${ENDIAN_H} HAVE_DECL_HTOBE32)
    CHECK_SYMBOL_EXISTS(htobe64 ${ENDIAN_H} HAVE_DECL_HTOBE64)
endif()

# HAVE_BYTESWAP_H
CHECK_INCLUDE_FILE("byteswap.h" HAVE_BYTESWAP_H)
CHECK_SYMBOL_EXISTS(bswap_16 "byteswap.h" HAVE_DECL_BSWAP_16)
CHECK_SYMBOL_EXISTS(bswap_32 "byteswap.h" HAVE_DECL_BSWAP_32)
CHECK_SYMBOL_EXISTS(bswap_64 "byteswap.h" HAVE_DECL_BSWAP_64)

# HAVE_DECL_STRNLEN
CHECK_SYMBOL_EXISTS(strnlen "string.h" HAVE_DECL_STRNLEN)

# USE_ASM
# set(USE_ASM on)  see option

# USE_UPNP
if(USE_UPNP)
    set(UPNP_DEFAULT 1) #TODO hardcoding
endif()

# HAVE_CONSENSUS_LIB
set(HAVE_CONSENSUS_LIB 1)
# HAVE_CXX11
set(HAVE_CXX11 1)


# BITCOIN_CONFIG is the full `bitcoin-config.h` file path,
# it's will be a symlink to the cmake generated config file finllay
set(BITCOIN_CONFIG ${BITCOIN_ROOT}/src/config/bitcoin-config.h)

# BITCOIN_CONFIG_CMAKE_IN is the static cmake config file template
set(BITCOIN_CONFIG_CMAKE_IN ${CMAKE_CURRENT_SOURCE_DIR}/bitcoin-config.cmake.h.in)

# BITCOIN_CONFIG_CMAKE is the cmake generated config file
#
# Notice for creating BITCOIN_CONFIG_CMAKE file name by using the ${CMAKE_CURRENT_BINARY_DIR} varible
#    1.) in the multiple configuration enviroment, like VisualStudio or XCode
#    2.) different cmake_build_type are used in a singel-configruation environment, like CLion, CodeBlock.
#    3.) the bitcoin-config.cmake.xxx.h need to be generated everytime when cmake is running. you can't point
#        to the same file, the configure_file() will failed when mutiple cmake running simultaneously.
#    4.) the bitcion-config.h should be keep same for mutiple-config (debug/release) ,but might diffrent for
#        diffrent tool-chain.
# When different configuration settings work in parallel, the shared `bitcoin-config.cmake.h` file
# might led to the confilict settings, so we need to create the uniquity of BITCOIN_CONFIG_CMAKE.
# Due to the different way bwtween the single/multiple-config of cmake, we have to Hack the
# CMAKE_CURRENT_BINARY_DIR, which is the full path to to the build directory that is currently being
# processed by cmake. (see https://cmake.org/cmake/help/v3.0/variable/CMAKE_CURRENT_BINARY_DIR.html)
# we use the BITCOIN_CONFIG_CMAKE name pattern as :
#  bitcoin-config.h -> bitcoin-config.cmake.<toolchain>.h -> bitcoin-config.cmake.<toolchain>.<build-folder>.h

get_filename_component(_real_path ${CMAKE_CURRENT_BINARY_DIR}/.. REALPATH)
get_filename_component(_gen_from ${_real_path} NAME_WE)
set(BITCOIN_CONFIG_CMAKE         ${BITCOIN_ROOT}/src/config/bitcoin-config.cmake.${CMAKE_CXX_COMPILER_ID}.${_gen_from}.h)

# generate bitcoin-config.cmake.xxx.h
get_filename_component(BITCOIN_CONFIG          ${BITCOIN_CONFIG} ABSOLUTE)
get_filename_component(BITCOIN_CONFIG_CMAKE    ${BITCOIN_CONFIG_CMAKE} ABSOLUTE)
message(STATUS "gen config file ${BITCOIN_CONFIG_CMAKE_IN} => ${BITCOIN_CONFIG_CMAKE}")
configure_file(${BITCOIN_CONFIG_CMAKE_IN} ${BITCOIN_CONFIG_CMAKE})

# if bitcoin-config.h file exist, do a backup
if(EXISTS ${BITCOIN_CONFIG})
    if(NOT IS_SYMLINK ${BITCOIN_CONFIG})
        message(STATUS "${BITCOIN_CONFIG} existed, rename to ${BITCOIN_CONFIG}.old" )
        file(RENAME ${BITCOIN_CONFIG} ${BITCOIN_CONFIG}.old)
    else()
        # if symlink find, don't try to do update here, because in the multiple-config or
        # muliple-build-type enviorment IDE such as Clion, if mutilple cmake processes
        # try to update the symlink in pararal, might cause the cmake fails
        # only show a status message here
        get_filename_component(_already_point_to  ${BITCOIN_CONFIG} REALPATH)
        message(STATUS "bitcoin-config already symlinked to ${_already_point_to}")
    endif()
endif()

if(NOT EXISTS ${BITCOIN_CONFIG})
    include(MakeLink)
    make_link(${BITCOIN_CONFIG_CMAKE} ${BITCOIN_CONFIG})
endif()


# The custom target try to to relink the correct config.cmake.xxx.h to bitcoin-config.h
# the config.cmake.xxx.h files are diffrent for the multiple configuration enviroment
# sepcially if developer use different toolchains under the same enviroment.
# The target mark sure the bitcoin-config.h point to the correct config file which
# generated by the current build
add_custom_target(relink
        COMMAND ${CMAKE_COMMAND} -DBITCOIN_CONFIG_CMAKE=${BITCOIN_CONFIG_CMAKE} -DBITCOIN_CONFIG=${BITCOIN_CONFIG}
                                 -P ${CMAKE_CURRENT_SOURCE_DIR}/relink.cmake
        COMMENT "relink: ${BITCOIN_CONFIG_CMAKE} => ${BITCOIN_CONFIG}")

set(BITCOIN_CONFIG          ${BITCOIN_CONFIG} PARENT_SCOPE)
set(BITCOIN_CONFIG_CMAKE    ${BITCOIN_CONFIG_CMAKE} PARENT_SCOPE)
