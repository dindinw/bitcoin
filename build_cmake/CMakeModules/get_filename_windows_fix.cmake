# A workaround for the issue 17206, get_filename_component REALPATH not resolving symlinks in Windows.
# The code copied from https://gitlab.kitware.com/cmake/cmake/issues/17206#note_4298056, which can be
# removed after the issue has been resolved.
# see https://gitlab.kitware.com/cmake/cmake/issues/17206 for details
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows" AND
(CMAKE_VERSION VERSION_LESS "3.11.0" OR CMAKE_VERSION VERSION_GREATER "3.11.2"))
    # This works around
    # https://gitlab.kitware.com/cmake/cmake/issues/17206 until the fix
    # is released: resolving windows symlinks with
    # get_filename_component(REALPATH).
    function(get_filename_component VAR filename COMP) # ARGN: ?CACHE
        if(COMP STREQUAL "REALPATH" AND IS_SYMLINK "${filename}")
            # Quote file name, otherwise PowerShell will error out on file names with spaces
            execute_process(COMMAND powershell.exe -noprofile -command
                    "Get-Item \"${filename}\" | %{If ($_.LinkType) { echo $_.Target } Else { echo $_.Fullname }}"
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                    RESULT_VARIABLE powershell_result
                    OUTPUT_VARIABLE "${VAR}"
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
            file(TO_CMAKE_PATH "${${VAR}}" ${VAR})
            if(NOT powershell_result EQUAL 0)
                here_message(FATAL_ERROR "Cannot invoke powershell.exe to resolve symlink positions")
            endif()

            if(NOT IS_ABSOLUTE "${${VAR}}")
                _get_filename_component(parent "${filename}" DIRECTORY)
                _get_filename_component(parent "${parent}" ABSOLUTE)
                set("${VAR}" "${parent}/${${VAR}}")
            endif()
        else()
            _get_filename_component(${ARGV} ${ARGN})
        endif()
        set(${VAR} "${${VAR}}" PARENT_SCOPE)
    endfunction(get_filename_component)
endif()
