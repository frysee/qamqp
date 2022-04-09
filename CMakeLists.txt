cmake_minimum_required(VERSION 3.12.0 FATAL_ERROR)

project(qamqp LANGUAGES CXX VERSION 0.5.0)

get_filename_component(QAMQP_PATH "${CMAKE_CURRENT_SOURCE_DIR}" ABSOLUTE)
include(${QAMQP_PATH}/cmake/CMakeSettings.cmake)

add_subdirectory(src)
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

# ---- Create an installable target ----
# this allows users to install and find the library via `find_package()`.

# the location where the project's version header will be placed should match the project's regular
# header paths
string(TOLOWER ${PROJECT_NAME}/version.h VERSION_HEADER_LOCATION)

packageProject(
  NAME ${PROJECT_NAME}-lib-static
  VERSION ${PROJECT_VERSION}
  NAMESPACE ${PROJECT_NAME}
  BINARY_DIR ${PROJECT_BINARY_DIR}
  INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include
  INCLUDE_DESTINATION include/${PROJECT_NAME}-${PROJECT_VERSION}
  VERSION_HEADER "${VERSION_HEADER_LOCATION}"
  COMPATIBILITY SameMajorVersion
  #DEPENDENCIES "Qt 6.0.0"
)

packageProject(
  NAME ${PROJECT_NAME}-lib
  VERSION ${PROJECT_VERSION}
  NAMESPACE ${PROJECT_NAME}
  BINARY_DIR ${PROJECT_BINARY_DIR}
  INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include
  INCLUDE_DESTINATION include/${PROJECT_NAME}-${PROJECT_VERSION}
  VERSION_HEADER "${VERSION_HEADER_LOCATION}"
  COMPATIBILITY SameMajorVersion
  #DEPENDENCIES "Qt 6.0.0"
)