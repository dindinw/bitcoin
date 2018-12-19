function(add_boost_test TEST_EXECUTABLE_NAME)
    foreach(f ${ARGN})
        # message(STATUS "f=${f}")
        get_filename_component(TEST_SUITE_NAME ${f} NAME_WE)
        file(READ "${f}" SOURCE_FILE_CONTENTS)
        set(FOUND_TEST_SUITE "")
        string(REGEX MATCH "BOOST_FIXTURE_TEST_SUITE"
                FOUND_TEST_SUITE ${SOURCE_FILE_CONTENTS})
        string(REGEX MATCH "BOOST_AUTO_TEST_SUITE"
                FOUND_TEST_SUITE ${SOURCE_FILE_CONTENTS})
        if(NOT ${FOUND_TEST_SUITE} STREQUAL "")
            # message(STATUS "find on ${TEST_SUITE_NAME}")
            string(REGEX MATCHALL "BOOST_AUTO_TEST_CASE\\( *([A-Za-z_0-9]+) *\\)"
                    FOUND_TESTS ${SOURCE_FILE_CONTENTS})
            foreach(HIT ${FOUND_TESTS})
                string(REGEX REPLACE ".*\\( *([A-Za-z_0-9]+) *\\).*" "\\1" TEST_NAME ${HIT})
                # message(STATUS "add test ${TEST_SUITE_NAME}.${TEST_NAME}")
                add_test(NAME "${TEST_SUITE_NAME}.${TEST_NAME}"
                        COMMAND ${TEST_EXECUTABLE_NAME}
                        --run_test=${TEST_SUITE_NAME}/${TEST_NAME} --catch_system_error=yes)
            endforeach()
        endif()
    endforeach(f)
endfunction()