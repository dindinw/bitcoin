function(make_link src dest)
    # message(STATUS "mklink ${src} -> ${dest}")
    if(WIN32 AND CMAKE_VERSION VERSION_LESS 3.13)
        # cmake <= 3.12 and in windows, use python
        # use find_program instead of find_package since cmake <= 3.12
        find_program(Python_EXECUTABLE python)
        execute_process( COMMAND ${Python_EXECUTABLE} "${CMAKE_MODULE_PATH}/mklink.py" ${src} ${dest}
                RESULT_VARIABLE retcode)
        if(NOT "${retcode}" STREQUAL "0")
            # https://superuser.com/questions/124679/how-do-i-create-a-link-in-windows-7-home-premium-as-a-regular-user
            # https://blogs.windows.com/buildingapps/2016/12/02/symlinks-windows-10/
            message(WARNING "For Windows Platform, please make sure has SeCreateSymbolicLinkPrivilege, For Windows 10, please open the developer mode")
            message(FATAL_ERROR "Fatal error when make_link")
        endif()
    else()
        # > 3.12 or not windows, we can use cmake -E create_symlink
        execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink ${src} ${dest}
                RESULT_VARIABLE result OUTPUT_QUIET ERROR_QUIET)
    endif()
endfunction()
