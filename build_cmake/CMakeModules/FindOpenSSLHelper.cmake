if ("${OPENSSL_ROOT_DIR}" STREQUAL "")
    if (NOT "$ENV{OPENSSL_ROOT_DIR}" STREQUAL "")
        set(OPENSSL_ROOT_DIR $ENV{OPENSSL_ROOT_DIR})
    elseif (APPLE)
        set(OPENSSL_ROOT_DIR "/usr/local/opt/openssl")
    elseif(UNIX AND NOT APPLE)
        set(OPENSSL_ROOT_DIR "/usr/include/openssl")
    elseif(WIN32 AND (MINGW OR CYGWIN))
        set(OPENSSL_ROOT_DIR "/usr/include/openssl")
    else()
        message(FATAL_ERROR "openssl not found and don't know where to look, please specify OPENSSL_ROOT_DIR")
    endif()
endif()

find_package(OpenSSL REQUIRED)

# The cmake's default OpenSSL finder get xxx.dll.a results when using OPENSSL_USE_STATIC_LIBS to find static library.
# See more details on why mingw using the xxx.dll.a patterns on:
#   - https://stackoverflow.com/questions/15852677/static-and-dynamic-shared-linking-with-mingw
#   - https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/Using_ld_the_GNU_Linker/win32.html
# Following is a workaround support the mingw static link.
if(MINGW AND OPENSSL_USE_STATIC_LIBS)
    string(REPLACE ".dll" "" OPENSSL_CRYPTO_LIBRARY "${OPENSSL_CRYPTO_LIBRARY}")
endif()

message(STATUS "Found OpenSSL/Crypto ${OPENSSL_INCLUDE_DIR} ${OPENSSL_CRYPTO_LIBRARY}")
