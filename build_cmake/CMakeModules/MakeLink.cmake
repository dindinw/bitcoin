macro(make_link src dest)
message(STATUS "mklink ${src} -> ${dest}")
execute_process(
            COMMAND ${CMAKE_COMMAND} -E create_symlink ${src} ${dest})
endmacro()
