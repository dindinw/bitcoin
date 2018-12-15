include(CheckIncludeFiles)
include(CheckSymbolExists)

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

# ENABLE_AVX2/ENABLE_SHANI/ENABLE_SSE41
set(ENABLE_SHANI on) # TODO test logic
set(ENABLE_AVX2 on)  # TODO test logic
set(ENABLE_SSE41 on) # TODO test logic

# HAVE_BOOST_XXX ...
# Boost is required, HAVE_BOOST_XXX should be set to on directly
set(HAVE_BOOST on)
set(HAVE_BOOST_CHRONO on)
set(HAVE_BOOST_FILESYSTEM on)
set(HAVE_BOOST_SYSTEM on)
set(HAVE_BOOST_THREAD on)
set(HAVE_BOOST_UNIT_TEST_FRAMEWORK on)

# AC_CHECK_DECLS([le16toh, le32toh, le64toh, htole16, htole32, htole64, be16toh, be32toh, be64toh, htobe16, htobe32, htobe64],,,
#		[#if HAVE_ENDIAN_H
                 #include <endian.h>
                 #elif HAVE_SYS_ENDIAN_H
                 #include <sys/endian.h>
                 #endif])
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
CHECK_INCLUDE_FILE(byteswap.h HAVE_BYTESWAP_H)
CHECK_SYMBOL_EXISTS(bswap_16 "byteswap.h" HAVE_DECL_BSWAP_16)
CHECK_SYMBOL_EXISTS(bswap_32 "byteswap.h" HAVE_DECL_BSWAP_32)
CHECK_SYMBOL_EXISTS(bswap_64 "byteswap.h" HAVE_DECL_BSWAP_64)


# USE_ASM
# set(USE_ASM on)  see option

CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/bitcoin-config.cmake.h.in ${BITCOIN_ROOT}/src/config/bitcoin-config.cmake.h)
