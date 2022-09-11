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

#include "raven/net/WebSocketDispatcher.h"
#include "raven/net/WebSocketHandler.h"
#include "raven/net/WebSocketController.h"
#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"
#include "raven/net/SessionHandler.h"
#include "raven/util/Log.h"


namespace raven {
namespace net {

using std::shared_ptr;
using std::make_shared;
using raven::util::Log;

WebSocketDispatcher::WebSocketDispatcher(WebSocketController& controller)
    :_controller(controller){ }

void WebSocketDispatcher::dispatch(RequestHTTP& request, ResponseHTTP& response){
    try{
        shared_ptr<WebSocketHandler> handler = 
            make_shared<WebSocketHandler>(_controller);

        handler->setSession(
            SessionHandler::getInstance()
                .createSession(request, response, handler)
            );

        handler->handle(request, response);
    }catch(const std::exception& ex){
        Log::error(
            "WebSocketDispatcher: Failed to dispatch web socket request"
        );
    }
}

} // END NAMESPACE net
} // END NAMESPACE raven
