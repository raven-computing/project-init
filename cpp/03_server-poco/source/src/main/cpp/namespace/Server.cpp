${{VAR_COPYRIGHT_HEADER}}

#include <memory>
#include <string>

#include "${{VAR_NAMESPACE_PATH}}/Server.h"
#include "${{VAR_NAMESPACE_PATH}}/ExampleRouter.h"
#include "raven/net/RouterHTTP.h"
#include "raven/util/Log.h"


${{VAR_NAMESPACE_DECL_BEGIN}}
using std::shared_ptr;
using std::make_shared;
using raven::net::RouterHTTP;
using raven::util::Log;


Server::Server(const unsigned short port)
    :ServerTCP(port){ }

shared_ptr<RouterHTTP> Server::router(){
    return make_shared<ExampleRouter>();
}

void Server::onStartRequested(){
    Log::info("Starting server...");
}

void Server::onStart(){
    Log::info(
        "Server started. Listening on port " + std::to_string(getPort()));
}

void Server::onStopRequested(){
    Log::info("Stopping server...");
}

void Server::onStop(){
    Log::info("Server stopped");
}

${{VAR_NAMESPACE_DECL_END}}
