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

#ifndef RAVEN_NET_SESSION_H
#define RAVEN_NET_SESSION_H

#include <memory>
#include <string>


namespace raven {
namespace net {

// Forward declaration
class WebSocketSessionProvider;

/**
 * Represents a session for a web socket connection.
 */
class Session {

    std::shared_ptr<WebSocketSessionProvider> _session;

public:

    /**
     * Constructs a new Session using the given implementation provider.
     * 
     * @param session The implementation provider for the Session.
     *                Must not be null.
     */
    Session(std::shared_ptr<WebSocketSessionProvider> session);

    /**
     * Returns the unique ID of this Session
     * 
     * @return The ID of this Session.
     */
    std::string getID() const;

    /**
     * Closes this web socket Session. This causes the underlying web socket
     * connection to be closed and all associated resources to be freed.
     * Repeated calls have no effect.
     */
    void close();

    /**
     * Indicates whether this Session has been closed.
     * 
     * @return True if this session is closed,
     *         false if this session is still open.
     */
    bool isClosed() const;

    /**
     * Sends the specified string message to the client of
     * this web socket session.
     * 
     * @param message The string message to send.
     */
    void send(const std::string& message);

    std::shared_ptr<WebSocketSessionProvider> getSessionProvider();

}; // END CLASS Session

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_SESSION_H
