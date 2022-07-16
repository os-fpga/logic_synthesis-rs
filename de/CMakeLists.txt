cmake_minimum_required(VERSION 3.12)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(de ${CMAKE_CURRENT_SOURCE_DIR}/src/de.cc)

if (PRODUCTION_BUILD)
    get_filename_component(FLEX_LM_SRC_DIR "../../../Tools/Flex_LM"
        REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

    if ((NOT RAPTOR) AND (NOT YOSYS_VERIFIC))
        add_subdirectory(${FLEX_LM_SRC_DIR} Flex_LM)
    endif()
    set(CXX_DEFINES "-DPRODUCTION_BUILD=1")
endif()

if (SANITIZE)
    list(APPEND MEM_SANITIZER_FLAGS 
    -fsanitize=address -fno-omit-frame-pointer)
endif()

list(APPEND DE_CXX_FLAGS_DEBUG
    -Werror -Wall -O0 -D_REENTRANT -g ${MEM_SANITIZER_FLAGS} ${CXX_DEFINES}
)
list(APPEND DE_CXX_FLAGS_RELEASE
    -Werror -Wall -O2 -D_REENTRANT -DNDEBUG ${CXX_DEFINES}
)
target_compile_options(de PUBLIC $<$<CONFIG:DEBUG>:${DE_CXX_FLAGS_DEBUG}>)
target_compile_options(de PUBLIC $<$<CONFIG:RELEASE>:${DE_CXX_FLAGS_RELEASE}>)
target_link_libraries(de PRIVATE pthread)
if (PRODUCTION_BUILD)
    add_dependencies(de rs_licenseManager)
    target_include_directories(de PUBLIC ${FLEX_LM_SRC_DIR})
    target_link_libraries(de PUBLIC rs_licenseManager)
endif()
