# [Function Usage]
# Installs configuration files to specified destination directory
# Parameters:
#     DESTINATION - (Required) Target installation directory path
#     ...         - List of source files to install
# Example:
#     install_config_file(
#         file1.cfg
#         file2.cfg
#         DESTINATION ${CMAKE_INSTALL_PREFIX}/config
#     )
# Note:
#     - Before use thie command, you need to add the following line to your CMakeLists.txt:
#         include(<path to>/utils.cmake)
#     - Automatically creates destination directory structure
#     - Not supports wildcard patterns in file paths, if you want to match files with wildcards, use file(GLOB ...) to convert to a list of files
#     - Fails if DESTINATION is not specified
function(install_config_file)
    set(options)
    set(oneValueArgs DESTINATION)
    set(multiValueArgs)
    cmake_parse_arguments(
        PARSE_ARGV 0  
        ARG           
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
    )

    if(NOT ARG_DESTINATION)
        message(FATAL_ERROR "DESTINATION is required!")
    endif()

    set(files ${ARG_UNPARSED_ARGUMENTS})
    set(destination ${ARG_DESTINATION})
    file(MAKE_DIRECTORY ${destination})

    foreach(file IN LISTS files)
        file(COPY ${file} DESTINATION ${destination})
    endforeach()
endfunction()
