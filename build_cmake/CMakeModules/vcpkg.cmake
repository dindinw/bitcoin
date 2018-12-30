if ("${VCPKG_ROOT}" STREQUAL "")
    if(NOT "$ENV{VCPKG_ROOT}" STREQUAL "")
        set(VCPKG_ROOT $ENV{VCPKG_ROOT})
    endif()
endif()
if ("${VCPKG_TRIPLET}" STREQUAL "")
    if (NOT "$ENV{VCPKG_TRIPLET}" STREQUAL "")
        set(VCPKG_TRIPLET $ENV{VCPKG_TRIPLET})
    elseif(NOT "${VCPKG_ROOT}" STREQUAL "")
        set(VCPKG_TRIPLET ${VCPKG_ROOT}\\installed\\x64-windows-static)
        set(VCPKG_TRIPLET_BYGUESS 1)
    else()
        string(APPEND _vcpkg_error "The vcpkg triplet can not be found, please specify VCPKG_TRIPLET, ")
        string(APPEND _vcpkg_error "ex: <vcpkg>/installed/x64-windows-static")
        message(FATAL_ERROR ${_vcpkg_error})
    endif()
endif()

# make sure the input triplet is an well-formatted file path
file(TO_CMAKE_PATH "${VCPKG_TRIPLET}" VCPKG_TRIPLET)

# check vcpkg triple pattern
# https://github.com/Microsoft/vcpkg/blob/master/docs/users/triplets.md
string(REGEX MATCH "x86|x64|arm|arm64-.*" TRIPLET_NAME_OK "${VCPKG_TRIPLET}")

# if static build need extra check for vcpkg triple
if(STATIC_BUILD)
    string(REGEX MATCH "static" TRIPLET_NAME_OK "${VCPKG_TRIPLET}")
    string(APPEND _triplet_error_reason "${VCPKG_TRIPLET} can't use for static build, you might need to set -DSTATIC_BUILD=off")
else()
    string(REGEX MATCH "static" _should_not_use_static_triple "${VCPKG_TRIPLET}")
    if(_should_not_use_static_triple)
        set(TRIPLET_NAME_OK "") # clear ok flag, force it goto error handling logic
        string(APPEND _triplet_error_reason "${VCPKG_TRIPLET} can only use for static build, you might need to set -DSTATIC_BUILD=on")
    endif()
endif()

if(NOT "${TRIPLET_NAME_OK}" STREQUAL "" AND EXISTS ${VCPKG_TRIPLET})
    set(TRIPLET_OK)
else()
    string(APPEND _triplet_error_reason "${VCPKG_TRIPLET} not exist")
endif()

if(NOT TRIPLET_OK)
    message(FATAL_ERROR "vcpkg triple : ${_triplet_error_reason}, please specify correct VCPKG_TRIPLET")
endif()

if(VCPKG_TRIPLET_BYGUESS)
    string( APPEND _vcpkg_triple_warn "WARNNING : VCPKG_TRIPLET set to ${VCPKG_TRIPLET} by default, ")
    string( APPEND _vcpkg_triple_warn "you might need to change to the suitable triplet for the ")
    string( APPEND _vcpkg_triple_warn "correct depends libraries")
    message(STATUS ${_vcpkg_triple_warn})
endif()

message(STATUS "vcpkg triplet: ${VCPKG_TRIPLET}")
set(BOOST_ROOT    ${VCPKG_TRIPLET})
set(OPENSSL_ROOT_DIR ${VCPKG_TRIPLET})
set(LIBEVENT_ROOT_DIR  ${VCPKG_TRIPLET})
set(LIBDB_CXX_DIR  ${VCPKG_TRIPLET})
set(ZeroMQ_DIR ${VCPKG_TRIPLET}/share/zeromq/)
set(LIBMINIUPNPC_ROOT ${VCPKG_TRIPLET})
set(RAPIDCHECK_ROOT ${VCPKG_TRIPLET})

# if using vcpkg, need to specifiy debug library dir
#  - boost
#  - berkeley-db
#  - libevent
#  - rapidcheck
set(VCPKG_TRIPLET_DEBUG ${VCPKG_TRIPLET}/debug/lib)
if(EXISTS ${VCPKG_TRIPLET_DEBUG})
    set(Boost_LIBRARY_DIR_DEBUG ${VCPKG_TRIPLET_DEBUG})
    set(LIBDB_CXX_DEBUG_DIR ${VCPKG_TRIPLET_DEBUG})
    set(LIBEVENT_DEBUG_DIR ${VCPKG_TRIPLET_DEBUG})
    set(RAPIDCHECK_DEBUG_DIR ${VCPKG_TRIPLET_DEBUG})
    message(STATUS  "Boost_LIBRARY_DIR_DEBUG : ${Boost_LIBRARY_DIR_DEBUG}")
    message(STATUS  "LIBDB_CXX_DEBUG_DIR: ${LIBDB_CXX_DEBUG_DIR}")
    message(STATUS  "RAPIDCHECK_DEBUG_DIR: ${RAPIDCHECK_DEBUG_DIR}")
else()
    message(WARNING "vcpkg debug dir: ${VCPKG_TRIPLET_DEBUG} not exists, the multiple-configuation build might not work properly")
endif()
