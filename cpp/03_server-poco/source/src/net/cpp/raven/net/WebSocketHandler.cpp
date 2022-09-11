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

#include <memory>
#include <string>

#include "raven/net/WebSocketHandler.h"
#include "raven/net/WebSocketController.h"
#include "raven/net/WebSocketSessionProvider.h"
#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"
#include "raven/net/Session.h"
#include "raven/net/SessionHandler.h"
#include "raven/util/Log.h"


namespace raven {
namespace net {

using std::shared_ptr;
using std::make_shared;
using std::string;
using raven::util::Log;

WebSocketHandler::WebSocketHandler(WebSocketController& controller)
    :_controller(controller){

    _session = nullptr;
}

void WebSocketHandler::handle(RequestHTTP& request, ResponseHTTP& response){
    try{
        if(_session){
            _session->getSessionProvider()->startThreads();
            onConnect();
        }
    }catch(const std::exception& ex){
        processError(ex);
    }catch(...){
        Log::error("WebSocketHandler: Unknown error");
    }
}

shared_ptr<Session> WebSocketHandler::getSession(){
    return _session;
}

void WebSocketHandler::setSession(shared_ptr<Session> session){
    _session = session;
}

void WebSocketHandler::onConnect(){
    try{
        if(_session){
            _controller.onConnect(*_session.get());
        }
    }catch(const std::exception& ex){
        Log::error(
            "WebSocketController.onConnect() has thrown uncaught exception"
        );
    }
}

void WebSocketHandler::onDisconnect(){
    try{
        if(_session){
            _session->close();
            SessionHandler::getInstance().clear(_session);
            _controller.onDisconnect(*_session.get());
        }
    }catch(const std::exception& ex){
        Log::error(
            "WebSocketController.onDisconnect() has thrown uncaught exception"
        );
        string str = ex.what();
        Log::error(str);
    }
}

void WebSocketHandler::process(Message& message){
    try{
        if(_session){
            if(message.isPing()){
                _controller.onPingReceived(*_session.get(), message);
            }else if(message.isPong()){
                _controller.onPongReceived(*_session.get(), message);
            }else{
                _controller.onMessageReceived(*_session.get(), message);
            }
        }
    }catch(const std::exception& ex){
        Log::error(
            "WebSocketController method has thrown uncaught exception"
        );
    }
}

void WebSocketHandler::processError(const std::exception& ex){
    try{
        if(_session){
            _controller.onError(*_session.get(), ex);
        }
    }catch(const std::exception& ex){
        Log::error(
            "WebSocketController.onError() method has "
            "thrown uncaught exception"
        );
    }
}

} // END NAMESPACE net
} // END NAMESPACE raven
