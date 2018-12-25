function(to_static_find_libary_suffixes orig_suffixes)
    set(${orig_suffixes} ${CMAKE_FIND_LIBRARY_SUFFIXES}) # save the orig suffixes
    if(WIN32)
        list(INSERT CMAKE_FIND_LIBRARY_SUFFIXES 0 .lib .a)
    else()
        set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    endif()

    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES} PARENT_SCOPE) # replace the current suffiexes
    set(${orig_suffixes} ${${orig_suffixes}} PARENT_SCOPE) #save the orig suffixes to the parent scope

    message(STATUS "library find suffixes : ${${orig_suffixes}} => ${CMAKE_FIND_LIBRARY_SUFFIXES} ")
endfunction()

function(restore_find_library_suffixes orig_suffixes)
    message(STATUS "library find suffixes : ${CMAKE_FIND_LIBRARY_SUFFIXES} => ${${orig_suffixes}}")
    set(CMAKE_FIND_LIBRARY_SUFFIXES $${orig_suffixes}} PARENT_SCOPE)
endfunction()