cmake_minimum_required(VERSION 3.12.0 FATAL_ERROR)

project(qamqp LANGUAGES CXX VERSION 0.6.2)

get_filename_component(QAMQP_PATH "${CMAKE_CURRENT_SOURCE_DIR}" ABSOLUTE)
include(${QAMQP_PATH}/cmake/CMakeSettings.cmake)

add_subdirectory(tests/auto)

if (${WITH_TUTORIALS})
    message(STATUS "Adding tutorials...")
    add_subdirectory(tutorials)
else()
    message(STATUS "Not adding tutorials (use -DWITH_TUTORIALS=ON for that)...")
endif()

include(CPack)

# ---- Add dependencies via CPM ----
# see https://github.com/TheLartians/CPM.cmake for more info

include(cmake/CPM.cmake)

# PackageProject.cmake will be used to make our target installable
CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.8.0")

# ---- Add source files ---- 

# Note: globbing sources is considered bad practice as CMake's generators may not detect new files
# automatically. Keep that in mind when changing files, or explicitly mention them here.
file(GLOB_RECURSE headers CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h")
file(GLOB_RECURSE sources CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
file(GLOB_RECURSE private_hdrs CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h")

_add_vcs_info_to_file(src/qamqpclient.cpp)

# ---- Create library ----

# Note: for header-only libraries change all PUBLIC flags to INTERFACE and create an interface
# target: add_library(${PROJECT_NAME} INTERFACE)
add_library(${PROJECT_NAME} ${headers} ${sources} ${private_hdrs})
set_target_properties(${PROJECT_NAME} PROPERTIES CXX_STANDARD 17)

# being a cross-platform target, we enforce standards conformance on MSVC
target_compile_options(${PROJECT_NAME} PUBLIC "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/permissive->")

# Link dependencies
target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Network)

target_include_directories(${PROJECT_NAME}
  PUBLIC   
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include/${PROJECT_NAME}-${PROJECT_VERSION}>
  PRIVATE 
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
)

add_library(${PROJECT_NAME}-coverage ${headers} ${sources} ${private_hdrs})
_enable_compiler_coverage_flags_for(${PROJECT_NAME}-coverage)
set_target_properties(${PROJECT_NAME}-coverage PROPERTIES CXX_STANDARD 17)

# being a cross-platform target, we enforce standards conformance on MSVC
target_compile_options(${PROJECT_NAME}-coverage PUBLIC "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/permissive->")

# Link dependencies
target_link_libraries(${PROJECT_NAME}-coverage PRIVATE Qt6::Core Qt6::Network)

target_include_directories(${PROJECT_NAME}-coverage 
  PUBLIC 
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include/${PROJECT_NAME}-${PROJECT_VERSION}>
  PRIVATE 
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
)

# ---- Create an installable target ----
# this allows users to install and find the library via `find_package()`.

# the location where the project's version header will be placed should match the project's regular
# header paths
string(TOLOWER ${PROJECT_NAME}/version.h VERSION_HEADER_LOCATION)

packageProject(
  NAME ${PROJECT_NAME}
  VERSION ${PROJECT_VERSION}
  NAMESPACE ${PROJECT_NAME}
  BINARY_DIR ${PROJECT_BINARY_DIR}
  INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include
  INCLUDE_DESTINATION include/${PROJECT_NAME}-${PROJECT_VERSION}
  VERSION_HEADER "${VERSION_HEADER_LOCATION}"
  COMPATIBILITY SameMajorVersion
  #DEPENDENCIES "Qt 6.0.0"
)