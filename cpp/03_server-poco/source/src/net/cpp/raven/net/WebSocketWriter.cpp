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
#include <thread>
#include <string>

#include "Poco/Net/WebSocket.h"

#include "raven/net/WebSocketWriter.h"
#include "raven/net/WebSocketHandler.h"
#include "raven/net/Session.h"
#include "raven/net/WebSocketSessionProvider.h"
#include "raven/util/Log.h"


namespace raven {
namespace net {

using std::shared_ptr;
using std::make_shared;
using std::string;
using std::thread;
using Poco::Net::WebSocket;
using raven::net::Session;
using raven::util::Log;

void WebSocketWriter::_writerLoop(){
    _isRunning = true;
    shared_ptr<Session> session = _handler->getSession();
    WebSocket& ws = session->getSessionProvider()->getWebSocket();

    bool terminate = false;
    while(!terminate){
        WSWQ_Item item = _queue.get();
        terminate = item.cancel;
        if(terminate){
            break;
        }
        if(!item.msg){
            continue;
        }
        try{
            shared_ptr<Message> msg = item.msg;
            const string& str = msg->getText();
            const char* buffer = str.data();
            ws.sendFrame(buffer, (int)str.length());
        }catch(const std::exception& ex){
            _handler->processError(ex);
        }
    }
    _isRunning = false;
    Log::debug("WebSocketWriter: Thread terminating");
}

WSWQ_Item WebSocketWriter::_finalizationItem(){
    return WSWQ_Item{true, nullptr};
}

WebSocketWriter::WebSocketWriter(shared_ptr<WebSocketHandler> handler)
    :_queue(WebSocketWriterQueue()){

    _handler = handler;
    _isRunning = false;
}

void WebSocketWriter::start(){
    _thread = thread(&WebSocketWriter::_writerLoop, this);
}

WebSocketWriterQueue& WebSocketWriter::getQueue(){
    return _queue;
}

void WebSocketWriter::send(shared_ptr<Message> msg){
    if(_isRunning){
        _queue.add(WSWQ_Item{false, msg});
    }
}

void WebSocketWriter::sendText(const string& text){
    send(make_shared<Message>(text));
}

void WebSocketWriter::stop(){
    if(_isRunning){
        Log::debug("WebSocketWriter: Stop requested");
        _queue.add(_finalizationItem());
        _thread.join();
        _isRunning = false;
    }
}

} // END NAMESPACE net
} // END NAMESPACE raven
