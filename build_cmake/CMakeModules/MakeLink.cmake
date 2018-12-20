macro(make_link src dest)
    message(STATUS "mklink ${src} -> ${dest}")

    # <= 3.12 in windows, use python
    if(WIN32 AND CMAKE_VERSION VERSION_LESS_EQUAL 3.12)
        find_package (Python 3 REQUIRED COMPONENTS Interpreter)
        execute_process( COMMAND ${Python_EXECUTABLE} "${CMAKE_MODULE_PATH}/mklink.py" ${src} ${dest}
                RESULT_VARIABLE retcode)
    else() # > 3.12, we can use cmake -E create_symlink
        execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink ${src} ${dest}
                RESULT_VARIABLE retcode)
    endif()
    if(NOT "${retcode}" STREQUAL "0")
        if(WIN32)
            # https://superuser.com/questions/124679/how-do-i-create-a-link-in-windows-7-home-premium-as-a-regular-user
            message(WARNING "For Windows Platform, please make sure has SeCreateSymbolicLinkPrivilege")
        endif()
        message(FATAL_ERROR "Fatal error when make_link")
    endif()
endmacro()