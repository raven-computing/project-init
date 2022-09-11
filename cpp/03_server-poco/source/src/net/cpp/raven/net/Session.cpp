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
#include <exception>

#include "raven/net/Session.h"
#include "raven/net/WebSocketSessionProvider.h"


namespace raven {
namespace net {

using std::shared_ptr;
using std::string;
using std::runtime_error;

Session::Session(shared_ptr<WebSocketSessionProvider> session){
    if(!session){
        throw runtime_error(
            "Argument WebSocketSessionProvider must not be null"
        );
    }
    _session = session;
}

string Session::getID() const{
    if(_session){
        return _session->getID();
    }
    throw runtime_error("Invalid session state");
}

void Session::close(){
    if(_session){
        _session->close();
    }
}

bool Session::isClosed() const{
    if(_session){
        return _session->isClosed();
    }
    throw runtime_error("Invalid session state");
}

void Session::send(const string& message){
    if(_session){
        _session->send(message);
    }
}

shared_ptr<WebSocketSessionProvider> Session::getSessionProvider(){
    return _session;
}

} // END NAMESPACE net
} // END NAMESPACE raven
