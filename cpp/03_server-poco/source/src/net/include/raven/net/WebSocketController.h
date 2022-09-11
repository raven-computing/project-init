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

#ifndef RAVEN_NET_WEB_SOCKET_CONTROLLER_H
#define RAVEN_NET_WEB_SOCKET_CONTROLLER_H

#include <string>

#include "raven/net/Session.h"
#include "raven/net/Message.h"


namespace raven {
namespace net {

/**
 * Controller interface for handling web socket connections.
 * Users should inherit from this class and implement the needed methods.
 */
class WebSocketController {

public:

    /**
     * This method is called when a web socket connection is first opened,
     * after a successful HTTP handshake has occurred.
     * 
     * @param session A reference to the web socket Session.
     */
    virtual void onConnect(Session& session);

    /**
     * This method is called when a web socket connection is closed,
     * either by the client or the server.
     * 
     * @param session A reference to the web socket Session.
     */
    virtual void onDisconnect(Session& session);

    /**
     * This method is called when a regular data message is
     * received from the client.
     * 
     * @param session A reference to the web socket Session.
     * @param message A reference to the received web socket Message.
     */
    virtual void onMessageReceived(Session& session, Message& message);

    /**
     * This method is called when a Ping message is received from the client.
     * 
     * @param session A reference to the web socket Session.
     * @param message A reference to the received web socket Ping Message.
     */
    virtual void onPingReceived(Session& session, Message& message);

    /**
     * This method is called when a Pong message is received from the client.
     * 
     * @param session A reference to the web socket Session.
     * @param message A reference to the received web socket Pong Message.
     */
    virtual void onPongReceived(Session& session, Message& message);

    /**
     * This method is called when an error is encountered within a web socket connection
     * that cannot be handled automatically.
     * 
     * @param session A reference to the web socket Session.
     * @param ex A reference to std::exception encountered.
     */
    virtual void onError(Session& session, const std::exception& ex);

}; // END CLASS WebSocketController

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_WEB_SOCKET_CONTROLLER_H
