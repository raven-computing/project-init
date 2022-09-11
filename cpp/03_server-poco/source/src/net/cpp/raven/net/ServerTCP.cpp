/*
 * Copyright (C) 2022 Raven Computing
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <string>
#include <vector>

#include "Poco/Exception.h"
#include "Poco/ErrorHandler.h"
#include "Poco/Net/HTTPServer.h"
#include "Poco/Net/HTTPRequestHandlerFactory.h"
#include "Poco/Net/HTTPServerParams.h"
#include "Poco/Net/ServerSocket.h"
#include "Poco/Util/ServerApplication.h"

#include "raven/net/ServerTCP.h"
#include "raven/net/DefaultErrorHandler.h"
#include "raven/net/DefaultRequestHandlerFactory.h"
#include "raven/net/SessionHandler.h"
#include "raven/util/Log.h"


namespace raven {
namespace net {

using std::string;
using std::vector;
using std::shared_ptr;
using Poco::ErrorHandler;
using Poco::Net::ServerSocket;
using Poco::Net::HTTPRequestHandlerFactory;
using Poco::Net::HTTPServer;
using Poco::Net::HTTPServerParams;
using Poco::Util::ServerApplication;
using Poco::Util::Application;
using raven::util::Log;

ServerTCP::ServerTCP(const unsigned short port):_port(port){ }

void ServerTCP::initialize(Application& self){
    ServerApplication::initialize(self);
    Log::initialize();
}

void ServerTCP::uninitialize(){
    ServerApplication::uninitialize();
    Log::close();
}

shared_ptr<RouterHTTP> ServerTCP::router(){
    return nullptr;
}

ErrorHandler* ServerTCP::errorHandler(){
    return new DefaultErrorHandler();
}

HTTPRequestHandlerFactory* ServerTCP::requestHandlerFactory(
    shared_ptr<RouterHTTP> router){

    return new DefaultRequestHandlerFactory(router);
}

void ServerTCP::onStartRequested(){ }

void ServerTCP::onStart(){ }

void ServerTCP::onStopRequested(){ }

void ServerTCP::onStop(){ }

unsigned short ServerTCP::getPort() const{
    return _port;
}

int ServerTCP::main(const vector<string>& args){
    try{
        if(_port == 0){
            Log::error("Invalid server port specified");
            return Application::EXIT_CONFIG;
        }
        ErrorHandler::set(errorHandler());

        _router = router();
        if(_router){
            _router->initialize();
        }else{
            Log::warn("No router set for TCP server");
        }

        onStartRequested();

        //Create socket
        ServerSocket socket(_port);
        HTTPServer server(
            requestHandlerFactory(_router),
            socket,
            new HTTPServerParams()
        );

        //Start the server
        server.start();
        onStart();

        //Wait for CTRL-C or kill
        waitForTerminationRequest();

        onStopRequested();

        SessionHandler::getInstance().stopAllSessions();

        //Stop the server
        server.stop();
        onStop();
    }catch(const Poco::Exception& ex){
        Log::error("A server error has occurred");
        Log::error(ex.displayText());
        return Application::EXIT_CONFIG;
    }catch(const std::exception& ex){
        const string msg = ex.what();
        Log::error("A server error has occurred");
        if(!msg.empty()){
            Log::error(msg);
        }
        return Application::EXIT_CONFIG;
    }
    return Application::EXIT_OK;
}

} // END NAMESPACE net
} // END NAMESPACE raven
