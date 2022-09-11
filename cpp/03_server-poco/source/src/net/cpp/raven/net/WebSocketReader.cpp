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
#include <thread>

#include "Poco/Exception.h"
#include "Poco/Buffer.h"
#include "Poco/Net/WebSocket.h"
#include "Poco/Net/NetException.h"

#include "raven/net/WebSocketReader.h"
#include "raven/net/WebSocketHandler.h"
#include "raven/net/WebSocketSessionProvider.h"
#include "raven/net/Message.h"
#include "raven/net/Session.h"
#include "raven/util/Log.h"


namespace raven {
namespace net {

using std::unique_ptr;
using std::shared_ptr;
using std::make_unique;
using std::make_shared;
using std::string;
using std::thread;
using Poco::format;
using Poco::Exception;
using Poco::Buffer;
using Poco::Net::WebSocket;
using Poco::Net::NetException;
using raven::net::Session;
using raven::util::Log;


void WebSocketReader::_readerLoop(){
    _isRunning = true;
    shared_ptr<Session> session = _handler->getSession();
    WebSocket& ws = session->getSessionProvider()->getWebSocket();
    try{
        Buffer<char> buffer(4096);
        int flags;
        int n;
        do{
            n = ws.receiveFrame(buffer, flags);
            if(Log::debug()){
                Log::debug(
                    format("WebSocketReader: Frame received "
                           "(length=%d, flags=0x%x)",
                           n, unsigned(flags)));
            }
            if(n > 0){
                int type = 1; //text message
                if((flags & WebSocket::FRAME_OP_BITMASK)
                         == WebSocket::FRAME_OP_PING){

                    type = 2;
                }else if((flags & WebSocket::FRAME_OP_BITMASK)
                               == WebSocket::FRAME_OP_PONG){

                    type = 3;
                }
                Message msg(type, string(buffer.begin(), buffer.size()));
                _handler->process(msg);
                buffer.resize(0);
            }
            if(n == 0 && flags == 0){
                Log::debug(
                    "WebSocketReader: Web socket connection closed by peer");
            }
        }while(n > 0
            && (flags & WebSocket::FRAME_OP_BITMASK)
                     != WebSocket::FRAME_OP_CLOSE);

        Log::debug("WebSocketReader: WebSocket connection closed");
    }catch(const NetException& ex){
        _handler->processError(ex);
    }catch(const Exception& ex){
        _handler->processError(ex);
    }catch(...){
        Log::error("WebSocketReader: Connection unknown error");
    }
    try{
        ws.shutdown();
    }catch(const Exception& ex){
        Log::warn("WebSocketReader: WebSocket shutdown has thrown exception");
    }
    _isRunning = false;
    _handler->onDisconnect();
    Log::debug("WebSocketReader: Thread terminating");
}

WebSocketReader::WebSocketReader(shared_ptr<WebSocketHandler> handler){
    _handler = handler;
}

void WebSocketReader::start(){
    _thread = thread(&WebSocketReader::_readerLoop, this);
}

void WebSocketReader::stop(){
    if(_isRunning){
        Log::debug("WebSocketReader: Stop requested");
        _thread.join();
    }
}

} // END NAMESPACE net
} // END NAMESPACE raven
