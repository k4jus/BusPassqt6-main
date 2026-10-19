cmake_minimum_required(VERSION 3.21)
project(BusPaszt VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


find_package(Qt6 REQUIRED COMPONENTS Quick Sensors)
qt_standard_project_setup(REQUIRES 6.5)
qt_add_executable(BusPaszt main.cpp)

# qt_add_resources(BusPaszt "images"
#     PREFIX "/assets/images"
#     FILES
#         "/assets/images/close.svg"
# 	"/assets/images/qr-code.png"
# )
# qt_add_resources(BusPaszt "fonts"
#     PREFIX "/assets/fonts"
#     FILES
# 	"/assets/fonts/Google-Sans-Bold.ttf"
# 	"/assets/fonts/Google-Sans-Medium.ttf"
# 	"/assets/fonts/Google-Sans.ttf"
# 	"/assets/fonts/StageCoach-Regular.otf"
# )

# Files with relative paths
file(GLOB_RECURSE PROJ_IMAGES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "assets/images/*")
file(GLOB_RECURSE PROJ_FONTS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "assets/fonts/*")

qt_add_qml_module(
    BusPaszt
    URI BusPaszt
    VERSION 1.0
    QML_FILES Main.qml
    RESOURCES
        "${PROJ_IMAGES}"
        "${PROJ_FONTS}"
	"sample.json"
)

target_link_libraries(BusPaszt PRIVATE Qt6::Quick Qt6::Sensors)

set_target_properties(BusPaszt PROPERTIES
    QT_ANDROID_APP_NAME "BusPasqt"
    QT_ANDROID_PACKAGE_NAME "com.example.buspasqt"
    QT_ANDROID_VERSION_NAME "0.9"
    QT_ANDROID_TARGET_SDK_VERSION 34
    QT_ANDROID_MIN_SDK_VERSION 28
    QT_ANDROID_VERSION_CODE 10
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    QT_ANDROID_APP_ICON "@drawable/ic_launcher"
)

# set_property(TARGET BusPaszt PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")

# if(ANDROID)
#     qt_finalize_target(BusPaszt)
# endif()
