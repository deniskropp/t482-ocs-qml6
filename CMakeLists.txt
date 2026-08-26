cmake_minimum_required(VERSION 3.16)
project(ocs_qml6_engine VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Always available: run the QML6 surface through the system qml6 runtime.
add_custom_target(run
    COMMAND qml6 "${CMAKE_SOURCE_DIR}/qml/Main.qml"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    USES_TERMINAL
    COMMENT "Launch OCS/Display QML6 surface via qml6"
)

add_custom_target(parse-smoke
    COMMAND qml6 "${CMAKE_SOURCE_DIR}/tests/parse_smoke.qml"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    USES_TERMINAL
    COMMENT "Headless OCS sigil parser smoke test"
)

add_custom_target(parse-extensions
    COMMAND qml6 "${CMAKE_SOURCE_DIR}/tests/parse_extensions.qml"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    USES_TERMINAL
    COMMENT "Headless OCS parser extension-slot test"
)

add_custom_target(theme-extensions
    COMMAND qml6 "${CMAKE_SOURCE_DIR}/tests/theme_extensions.qml"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    USES_TERMINAL
    COMMENT "Headless Theme/DisplayCard extension-slot test"
)

find_package(Qt6 QUIET COMPONENTS Qml Quick QuickControls2)

if(TARGET Qt6::Quick)
    set_source_files_properties(qml/components/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
endif()

if(NOT TARGET Qt6::Quick)
    message(STATUS "Qt6 Quick CMake package not found (install qt6-declarative-dev).")
    message(STATUS "Runtime path: cmake --build build --target run")
    message(STATUS "Or:  qml6 ${CMAKE_SOURCE_DIR}/qml/Main.qml")
    return()
endif()

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(ocs_qml6_engine
    src/main.cpp
)

qt_add_qml_module(ocs_qml6_engine
    URI OcsDisplay
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/components/Theme.qml
        qml/components/DisplayCard.qml
        qml/components/SigilBadge.qml
        qml/components/HeaderBar.qml
        qml/parser/OcsParser.js
)

target_link_libraries(ocs_qml6_engine PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
)

set_target_properties(ocs_qml6_engine PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
