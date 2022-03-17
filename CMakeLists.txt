cmake_minimum_required(VERSION 3.10)
project(logic_synthesis)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_compile_options(-D_REENTRANT -O2)
add_link_options(-lpthread)

add_executable(de ${PROJECT_SOURCE_DIR}/de/src/de.cc)
