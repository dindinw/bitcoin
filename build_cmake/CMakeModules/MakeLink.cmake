macro(make_link src dest target)
   add_custom_target(${target}
           COMMAND ${CMAKE_COMMAND} -E create_symlink ${src} ${dest}
           DEPENDS  ${dest}
           COMMENT "mklink ${src} -> ${dest}")
   # add_custom_command(TARGET ${target} PRE_BUILD
   #         COMMAND ${CMAKE_COMMAND} -E create_symlink ${src} ${dest} DEPENDS  ${dest} COMMENT "mklink ${src} -> ${dest}")
endmacro()