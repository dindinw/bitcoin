MESSAGE(STATUS "Using FindQt5.cmake...")

SET(ENV{PKG_CONFIG_PATH} "/usr/local/opt/qt/lib/pkgconfig:" $ENV{PKG_CONFIG_PATH})

find_package(PkgConfig REQUIRED)

pkg_search_module(PKG_QT5 REQUIRED Qt5Core)

MESSAGE(STATUS "find QT ${PKG_QT5_VERSION}")
MESSAGE(STATUS "find QT ${PKG_QT5_PREFIX}")
MESSAGE(STATUS "find QT ${PKG_QT5_INCLUDEDIR}")
MESSAGE(STATUS "find QT ${PKG_QT5_LIBDIR}")

# TODO refactor
if(ENABLE_QT)
    # Qt5
    MESSAGE(STATUS "try Found qt5 libraries")
    list(APPEND CMAKE_PREFIX_PATH "/usr/local/opt/qt/")

    FIND_PACKAGE(Qt5Core CONFIG REQUIRED)
    IF (Qt5Core_FOUND)
        MESSAGE(STATUS "add qt5 include dir ${Qt5Core_INCLUDE_DIRS}")
        include_directories(${Qt5Core_INCLUDE_DIRS})
    ENDIF(Qt5Core_FOUND)

    FIND_PACKAGE(Qt5Test CONFIG REQUIRED)
    IF (Qt5Test_FOUND)
        MESSAGE(STATUS "add qt5 include dir ${Qt5Test_INCLUDE_DIRS}")
        include_directories(${Qt5Test_INCLUDE_DIRS})
    ENDIF(Qt5Test_FOUND)
endif()


