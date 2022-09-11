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

#ifndef RAVEN_NET_WEB_SOCKET_DISPATCHER_H
#define RAVEN_NET_WEB_SOCKET_DISPATCHER_H

#include "raven/net/WebSocketController.h"
#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"


namespace raven {
namespace net {

/**
 * Responsible to dispatch requests to establish a web socket connection.
 */
class WebSocketDispatcher {

    WebSocketController& _controller;

public:

    WebSocketDispatcher(WebSocketController& controller);

    /**
     * Dispatches the a web socket handshake request and starts
     * the corresponding session.
     * 
     * @param request The RequestHTTP object of the request.
     * @param response The ResponseHTTP object of the request.
     */
    void dispatch(RequestHTTP& request, ResponseHTTP& response);

}; // END CLASS WebSocketDispatcher

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_WEB_SOCKET_DISPATCHER_H
