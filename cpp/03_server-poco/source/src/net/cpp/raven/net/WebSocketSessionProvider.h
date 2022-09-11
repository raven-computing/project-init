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

#ifndef RAVEN_NET_WEB_SOCKET_SESSION_PROVIDER_H
#define RAVEN_NET_WEB_SOCKET_SESSION_PROVIDER_H

#include <memory>
#include <string>

#include "Poco/UUID.h"
#include "Poco/Net/WebSocket.h"

#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"
#include "raven/net/WebSocketReader.h"
#include "raven/net/WebSocketWriter.h"


namespace raven {
namespace net {

//Forward declaration
class WebSocketHandler;

/**
 * Implementation class for the Session type.
 */
class WebSocketSessionProvider {

    Poco::UUID _id;
    Poco::Net::WebSocket _ws;
    WebSocketReader _wsReader;
    WebSocketWriter _wsWriter;
    bool _isOpen = false;

public:

    WebSocketSessionProvider(
        Poco::UUID id,
        RequestHTTP& request,
        ResponseHTTP& response,
        std::shared_ptr<WebSocketHandler> handler);

    std::string getID();

    void close();

    bool isClosed() const;

    void send(const std::string& message);

    void startThreads();

    void stopThreads();

    Poco::Net::WebSocket& getWebSocket();

}; // END CLASS WebSocketSessionProvider

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_WEB_SOCKET_SESSION_PROVIDER_H
