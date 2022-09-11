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

#ifndef RAVEN_NET_WEB_SOCKET_HANDLER_H
#define RAVEN_NET_WEB_SOCKET_HANDLER_H

#include <memory>
#include <exception>

#include "raven/net/WebSocketController.h"
#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"
#include "raven/net/Session.h"


namespace raven {
namespace net {

// Forward declaration
class WebSocketSessionProvider;

/**
 * Instances of this class are responsible for handling
 * web socket connections.
 */
class WebSocketHandler {

    WebSocketController& _controller;
    std::shared_ptr<Session> _session;

public:

    WebSocketHandler(WebSocketController& controller);

    /**
     * Handles the specified web socket handshake request.
     * 
     * @param request The RequestHTTP object of the request.
     * @param response The ResponseHTTP object of the request.
     */
    void handle(RequestHTTP& request, ResponseHTTP& response);

    void onConnect();

    void onDisconnect();

    void process(Message& message);

    void processError(const std::exception& ex);

    std::shared_ptr<Session> getSession();

    void setSession(std::shared_ptr<Session> session);

}; // END CLASS WebSocketHandler

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_WEB_SOCKET_HANDLER_H
