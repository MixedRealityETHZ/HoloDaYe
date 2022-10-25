# This is the main CMake build file used to compile HoloDaye
cmake_minimum_required (VERSION 3.15)
project("HoloDaye" LANGUAGES CXX VERSION 0.0.1)

# This file included below takes care of compiling dependencies
# and setting compiler flags on different platforms
include("CMakeConfig.txt")

include_directories(ext)
include_directories(include)

# The following lines build the main executable. If you add a source
# code file to HoloDaye, be sure to include it in this list.
add_executable(holodaye
    # Header files
    # include/holodaye/elevation.h

    # Source code files
    src/dataset.cpp
    src/main.cpp
)

# All codes below are in the purpose of testing.
# Test with catch2
add_subdirectory(ext/Catch2)

# These tests can use the Catch2-provided main
# Unit test for ElevationQuery
add_executable(DummyElevationTest 
    test/dummy_elevation_test.cpp
    src/dataset.cpp
)
target_link_libraries(DummyElevationTest PRIVATE Catch2::Catch2WithMain)

# These tests need their own main
# add_executable(custom-main-tests test.cpp test-main.cpp)
# target_link_libraries(custom-main-tests PRIVATE Catch2::Catch2)

include(CTest)
include(Catch)
catch_discover_tests(DummyElevationTest)
