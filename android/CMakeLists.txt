cmake_minimum_required(VERSION 3.10)

project(ac_zkp_native)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../cpp/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../cpp/src
)

# Source files
file(GLOB_RECURSE CPP_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/../../cpp/src/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../cpp/src/**/*.cpp"
)

# Create shared library
add_library(ac_zkp_native SHARED
    ${CPP_SOURCES}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../cpp/jni/zkp_jni.cpp
)

# Link libraries
find_library(log-lib log)
find_library(android-lib android)

target_link_libraries(ac_zkp_native
    ${log-lib}
    ${android-lib}
)

# Compiler flags
target_compile_options(ac_zkp_native PRIVATE
    -Wall
    -Wextra
    -O3
    -fPIC
)
