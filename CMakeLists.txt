cmake_minimum_required(VERSION 3.16)
project(yt_bot CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CPR_USE_SYSTEM_CURL ON CACHE BOOL "" FORCE)

include(FetchContent)

FetchContent_Declare(
    tgbotxx
    GIT_REPOSITORY https://github.com/baderouaich/tgbotxx.git
    GIT_TAG        main
)
FetchContent_MakeAvailable(tgbotxx)

add_executable(yt_bot main.cpp)

target_link_libraries(yt_bot PRIVATE 
    tgbotxx
)