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

#include "Poco/UUID.h"
#include "Poco/Timespan.h"
#include "Poco/UUIDGenerator.h"
#include "Poco/Net/WebSocket.h"

#include "raven/net/WebSocketSessionProvider.h"
#include "raven/net/WebSocketReader.h"
#include "raven/net/WebSocketWriter.h"
#include "raven/net/WebSocketHandler.h"
#include "raven/net/RequestHTTP.h"
#include "raven/net/ServerRequestProviderHTTP.h"
#include "raven/net/ResponseHTTP.h"
#include "raven/net/ServerResponseProviderHTTP.h"


namespace raven {
namespace net {

using std::shared_ptr;
using std::string;
using Poco::UUID;
using Poco::Timespan;
using Poco::Net::HTTPServerRequest;
using Poco::Net::HTTPServerResponse;
using Poco::Net::HTTPResponse;
using Poco::Net::WebSocket;
using raven::net::WebSocketReader;
using raven::net::WebSocketWriter;
using raven::net::Message;

WebSocketSessionProvider::WebSocketSessionProvider(
    UUID id,
    RequestHTTP& request,
    ResponseHTTP& response,
    shared_ptr<WebSocketHandler> handler)
    :_id(id),
     _ws(WebSocket(
        request.getProvider().getServerRequest(),
        response.getProvider().getServerResponse())),
     _wsReader(WebSocketReader(handler)),
     _wsWriter(WebSocketWriter(handler)){

    //Set timeout to infinity
    _ws.setReceiveTimeout(Timespan());
    _isOpen = true;
}

void WebSocketSessionProvider::startThreads(){
    _wsWriter.start();
    _wsReader.start();
}

void WebSocketSessionProvider::stopThreads(){
    _wsWriter.stop();
    _wsReader.stop();
}

string WebSocketSessionProvider::getID(){
    return _id.toString();
}

WebSocket& WebSocketSessionProvider::getWebSocket(){
    return _ws;
}

void WebSocketSessionProvider::close(){
    if(_isOpen){
        _isOpen = false;
        stopThreads();
    }
}

bool WebSocketSessionProvider::isClosed() const{
    return !_isOpen;
}

void WebSocketSessionProvider::send(const string& message){
    _wsWriter.sendText(message);
}

} // END NAMESPACE net
} // END NAMESPACE raven
