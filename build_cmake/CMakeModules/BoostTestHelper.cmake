function(add_boost_test TEST_EXECUTABLE_NAME)
    foreach(f ${ARGN})
        # message(STATUS "f=${f}")
        get_filename_component(TEST_FILE_NAME ${f} NAME_WE)
        file(READ "${f}" SOURCE_FILE_CONTENTS)
        set(FOUND_TEST_SUITE "")
        string(REGEX MATCH "BOOST_FIXTURE_TEST_SUITE\\( *([A-Za-z_0-9]+), *([A-Za-z_0-9]+) *\\)"
                FOUND_TEST_SUITE ${SOURCE_FILE_CONTENTS})
        if(FOUND_TEST_SUITE)
            string(REGEX REPLACE ".*\\( *([A-Za-z_0-9]+).* *\\).*" "\\1" TEST_SUITE_NAME ${FOUND_TEST_SUITE})
        endif()
        string(REGEX MATCH "BOOST_AUTO_TEST_SUITE\\( *([A-Za-z_0-9]+) *\\)"
                FOUND_TEST_SUITE ${SOURCE_FILE_CONTENTS})
        if(FOUND_TEST_SUITE)
            string(REGEX REPLACE ".*\\( *([A-Za-z_0-9]+) *\\).*" "\\1" TEST_SUITE_NAME ${FOUND_TEST_SUITE})
        endif()
        if(NOT ${TEST_SUITE_NAME} STREQUAL "")
            if (NOT "${TEST_FILE_NAME}" STREQUAL "${TEST_SUITE_NAME}")
                # message(STATUS "WARNNING: Test file name : ${TEST_FILE_NAME} != Test suite name : ${TEST_SUITE_NAME}")
            endif()
            # message(STATUS "try to find match on test suite : ${TEST_SUITE_NAME}")
            string(REGEX MATCHALL "BOOST_AUTO_TEST_CASE\\( *([A-Za-z_0-9]+) *\\)"
                    FOUND_TESTS ${SOURCE_FILE_CONTENTS})
            foreach(HIT ${FOUND_TESTS})
                string(REGEX REPLACE ".*\\( *([A-Za-z_0-9]+) *\\).*" "\\1" TEST_NAME ${HIT})
                # message(STATUS "add test ${TEST_SUITE_NAME}.${TEST_NAME}")
                add_test(NAME "${TEST_SUITE_NAME}.${TEST_NAME}"
                        COMMAND ${TEST_EXECUTABLE_NAME}
                        --run_test=${TEST_SUITE_NAME}/${TEST_NAME} --catch_system_error=yes)
            endforeach()
            # also need to match BOOST_FIXTURE_TEST_CASE
            set(FOUND_TESTS "")
            string(REGEX MATCHALL "BOOST_FIXTURE_TEST_CASE\\( *([A-Za-z_0-9]+), *([A-Za-z_0-9]+) *\\)"
                    FOUND_TESTS ${SOURCE_FILE_CONTENTS})
            foreach(HIT ${FOUND_TESTS})
                string(REGEX REPLACE ".*\\( *([A-Za-z_0-9]+).* *\\).*" "\\1" TEST_NAME ${HIT})
                # message(STATUS "add test ${TEST_SUITE_NAME}.${TEST_NAME}")
                add_test(NAME "${TEST_SUITE_NAME}.${TEST_NAME}"
                        COMMAND ${TEST_EXECUTABLE_NAME}
                        --run_test=${TEST_SUITE_NAME}/${TEST_NAME} --catch_system_error=yes)
            endforeach()
            # also need to match RC_BOOST_PROP (the rapidcheck tests)
            set(FOUND_TESTS "")
            string(REGEX MATCHALL "RC_BOOST_PROP\\( *([A-Za-z_0-9]+), *\\([^\n\r]*\\) *\\)"
                    FOUND_TESTS ${SOURCE_FILE_CONTENTS})
            foreach(HIT ${FOUND_TESTS})
                #message(STATUS "HIT=${HIT}")
                string(REGEX REPLACE ".*\\( *([A-Za-z_0-9]+), *\\([^\n\r]*\\) *\\).*" "\\1" TEST_NAME ${HIT})
                #message(STATUS "add test ${TEST_SUITE_NAME}.${TEST_NAME}")
                add_test(NAME "${TEST_SUITE_NAME}.${TEST_NAME}"
                        COMMAND ${TEST_EXECUTABLE_NAME}
                        --run_test=${TEST_SUITE_NAME}/${TEST_NAME} --catch_system_error=yes)
            endforeach()
            set(TEST_SUITE_NAME "")
        endif()
    endforeach(f)
endfunction()