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

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

option(BUILD_LSORACLE "Enable build of LSOracle" OFF)
if(BUILD_LSORACLE)
    list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/LSOracle-rs/lib/boost/cmake)
    add_subdirectory(LSOracle-rs/lib/boost)
    option(LOCAL_BOOST "use boost from submodules" OFF)
    add_subdirectory(LSOracle-rs)
endif()
add_subdirectory(abc-rs)
add_subdirectory(de)

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
             ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/de
    DESTINATION bin)
install(
    FILES ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/libabc.a
    DESTINATION lib/abc)
