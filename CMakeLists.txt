cmake_minimum_required(VERSION 3.12)

# Detect build type, fallback to release and throw a warning if use didn't
# specify any
if(NOT CMAKE_BUILD_TYPE)
    message(WARNING "Build type not set, falling back to Release mode.
        To specify build type use:
        -DCMAKE_BUILD_TYPE=<mode> where <mode> is Debug or Release.")
    set(CMAKE_BUILD_TYPE
        "Release"
        CACHE STRING "Choose the type of build, options are: Debug Release."
        FORCE)
endif(NOT CMAKE_BUILD_TYPE)

project(logic_synthesis)

list(APPEND LOGIC_SYNTHESIS_RS_RECURSIVE_SUBSYTEMS
    abc-rs
    )

list(APPEND LOGIC_SYNTHESIS_RS_NON_RECURSIVE_SUBSYTEMS
    Raptor_Tools
    )

list(APPEND LOGIC_SYNTHESIS_RS_PARTIAL_RECURSIVE_SUBSYTEMS
    Raptor_Tools/OpenLM
    Raptor_Tools/OpenLM/licensecc/extern
    )


find_package(Git QUIET)

function(checkout_subsystems SUBSYSTEM_LIST WORK_DIR RECURSIVE UPDATE PARTIAL)
    set(ORGNL_RECEV ${WORK_DIR})
    message("###########################")
    message(${SUBSYSTEM_LIST})
    message("###########################")
  foreach(GIVEN_SUBMODULE IN LISTS ${SUBSYSTEM_LIST})
    if(PARTIAL)
        set(WORK_DIR ${ORGNL_RECEV})
        get_filename_component(SUBMODULE "${GIVEN_SUBMODULE}" NAME)
        get_filename_component(extract_dir "${GIVEN_SUBMODULE}" DIRECTORY)
        set(WORK_DIR ${WORK_DIR}/${extract_dir})
    else()
        set(SUBMODULE ${GIVEN_SUBMODULE})    
    endif()
    file(GLOB README ${WORK_DIR}/${SUBMODULE}/README*)
    if (NOT EXISTS "${README}" OR ${UPDATE})
      message("Updating ${SUBMODULE} submodule...")
      execute_process(
        COMMAND ${GIT_EXECUTABLE} submodule update --init ${RECURSIVE} ${SUBMODULE}
        WORKING_DIRECTORY ${WORK_DIR}
        RESULT_VARIABLE GIT_SUBMOD_RESULT
        )
      if  (NOT GIT_SUBMOD_RESULT EQUAL "0")
        message(FATAL_ERROR "\"${GIT_EXECUTABLE} submodule update --init ${RECURSIVE} ${SUBMODULE}\" failed with ${GIT_SUBMOD_RESULT}, please checkout submodule manually")
      endif()
    endif()
  endforeach()
endfunction(checkout_subsystems)

if (NOT UPDATE_SUBMODULES)
    set(UPDATE_SUBMODULES OFF)
endif()

checkout_subsystems(LOGIC_SYNTHESIS_RS_RECURSIVE_SUBSYTEMS ${CMAKE_CURRENT_SOURCE_DIR} "--recursive" ${UPDATE_SUBMODULES} OFF)

if (PRODUCTION_BUILD)
    if ((NOT RAPTOR) AND (NOT YOSYS_VERIFIC))
        checkout_subsystems(LOGIC_SYNTHESIS_RS_NON_RECURSIVE_SUBSYTEMS ${CMAKE_CURRENT_SOURCE_DIR} "" ${UPDATE_SUBMODULES} OFF)
        checkout_subsystems(LOGIC_SYNTHESIS_RS_PARTIAL_RECURSIVE_SUBSYTEMS ${CMAKE_CURRENT_SOURCE_DIR} "" ${UPDATE_SUBMODULES} ON)
    endif()
endif()

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

set(ABC ${CMAKE_CURRENT_BINARY_DIR}/bin/abc)
set(DE ${CMAKE_CURRENT_BINARY_DIR}/bin/de)

add_subdirectory(abc-rs)
if(USE_DE_SRC AND NOT RAPTOR)
    add_subdirectory(de)
else()
    execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/bin)
    if(PRODUCTION_BUILD)
       # set(DE_EXE ${CMAKE_CURRENT_SOURCE_DIR}/de/src/production/de)
	set(DE_EXE ${CMAKE_CURRENT_SOURCE_DIR}/de/src/eng/de) # workaround to by pass flexlm EDA-2365
    else()
        set(DE_EXE ${CMAKE_CURRENT_SOURCE_DIR}/de/src/eng/de)
    endif()
    add_custom_target(de
    COMMENT      "      Building DE      "
    DEPENDS ${DE_EXE}
    COMMAND ${CMAKE_COMMAND} -E copy ${DE_EXE} ${CMAKE_BINARY_DIR}/bin
)
	add_custom_target(de_copy ALL
    COMMENT      "      Copy DE      "
)
	if(NOT RAPTOR)
		add_dependencies(de_copy de)
	endif()
endif()

# Add extra compilation flags to suppress warnings from some abc-rs
# Note that target_compile_options() *appends* to the current compilation options of
# the specified target

#Since ABC is an externally developed tool, we suppress all compiler warnings
CHECK_CXX_COMPILER_FLAG("-w" CXX_COMPILER_SUPPORTS_-w)
if(CXX_COMPILER_SUPPORTS_-w)
    target_compile_options(libabc PRIVATE "-w")
    target_compile_options(abc PRIVATE "-w")
endif()

#Some ABC headers generate warnings, treat them as system headers to suppress warnings
get_property(ABC_INCLUDE_DIRS TARGET libabc PROPERTY INCLUDE_DIRECTORIES)
target_include_directories(libabc SYSTEM INTERFACE ${ABC_INCLUDE_DIRS})

# Installation target
install(
    PROGRAMS ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/abc
             ${CMAKE_BINARY_DIR}/bin/de
    DESTINATION bin)
install(
    FILES ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/libabc.a
    DESTINATION lib/abc)

enable_testing()
add_test(
    NAME logic_synthesis-rs-smoke-test
    COMMAND ${ABC} -f ../tests/abc.scr
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/abc-rs
    )
