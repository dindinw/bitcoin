MESSAGE(STATUS "Using FindQt5.cmake...")

SET(ENV{PKG_CONFIG_PATH} "/usr/local/opt/qt/lib/pkgconfig:" $ENV{PKG_CONFIG_PATH})

find_package(PkgConfig REQUIRED)

pkg_search_module(PKG_QT5 REQUIRED Qt5Core)

MESSAGE(STATUS "find QT ${PKG_QT5_VERSION}")
MESSAGE(STATUS "find QT ${PKG_QT5_PREFIX}")
MESSAGE(STATUS "find QT ${PKG_QT5_INCLUDEDIR}")
MESSAGE(STATUS "find QT ${PKG_QT5_LIBDIR}")


