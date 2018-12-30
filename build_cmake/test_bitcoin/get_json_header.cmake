# The FindPython is more powerful but only avaible on the latest versions
if(CMAKE_VERSION VERSION_GREATER 3.11)
    find_package (Python REQUIRED COMPONENTS Interpreter)
else()
    find_program(Python_EXECUTABLE python)
endif()

function(gen_json_header NAME)
    set(HEADERS "")
    foreach(f ${ARGN})
        # Get the proper name for the test variable.
        get_filename_component(TEST_NAME ${f} NAME_WE)
        get_filename_component(FULL_NAME ${f} ABSOLUTE)
        set(h "${FULL_NAME}.h")
        # message(STATUS "${CMAKE_CURRENT_SOURCE_DIR}/${f} > ${h}")
        add_custom_command(OUTPUT ${h}
                COMMAND ${Python_EXECUTABLE}
                ARGS
                "${CMAKE_CURRENT_SOURCE_DIR}/gen_json_h.py"
                "${TEST_NAME}"
                "${CMAKE_CURRENT_SOURCE_DIR}/${f}" > ${h}
                MAIN_DEPENDENCY ${f}
                DEPENDS
                "gen_json_h.py"
                VERBATIM
                )
        list(APPEND HEADERS ${h})
    endforeach(f)
    set(${NAME} "${HEADERS}" PARENT_SCOPE)
endfunction()