# Copyright (C) 2022 Raven Computing

#==================================[ TARGET ]==================================
# Net core libraries

set(${{VAR_PROJECT_NAME_UPPER}}_TARGET_NET_CORE netcore)

add_library(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_NET_CORE}
    STATIC
    cpp/raven/net/BasicRouterHTTP.cpp
    cpp/raven/net/ControllerHTTP.cpp
    cpp/raven/net/ServerTCP.cpp
    cpp/raven/net/Message.cpp
    cpp/raven/net/Session.cpp
    cpp/raven/net/RequestHTTP.cpp
    cpp/raven/net/ResponseHTTP.cpp
    cpp/raven/net/SessionHandler.cpp
    cpp/raven/net/DefaultErrorHandler.cpp
    cpp/raven/net/DefaultRequestHandlerFactory.cpp
    cpp/raven/net/ServerRequestProviderHTTP.cpp
    cpp/raven/net/ServerResponseProviderHTTP.cpp
    cpp/raven/net/DefaultRequestHandler.cpp
    cpp/raven/net/WebSocketRequestHandler.cpp
    cpp/raven/net/WebSocketDispatcher.cpp
    cpp/raven/net/WebSocketHandler.cpp
    cpp/raven/net/WebSocketController.cpp
    cpp/raven/net/WebSocketSessionProvider.cpp
    cpp/raven/net/WebSocketReader.cpp
    cpp/raven/net/WebSocketWriter.cpp
    cpp/raven/net/WebSocketWriterQueue.cpp
    cpp/raven/util/Log.cpp
)

target_include_directories(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_NET_CORE}
    PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    PRIVATE
    cpp
)

target_link_libraries(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_NET_CORE}
    Poco::XML
    Poco::JSON
    Poco::Net
    Poco::Util
)


#===================================[ TESTS ]==================================
# Net tests

if(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TESTS)
    add_subdirectory(tests)
endif()
