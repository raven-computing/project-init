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

#ifndef RAVEN_NET_SESSION_HANDLER_H
#define RAVEN_NET_SESSION_HANDLER_H

#include <memory>
#include <cstddef>
#include <string>
#include <mutex>
#include <unordered_map>

#include "Poco/UUID.h"
#include "Poco/Net/HTTPServerRequest.h"
#include "Poco/Net/HTTPServerResponse.h"

#include "raven/net/Session.h"
#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"
#include "raven/net/WebSocketHandler.h"


namespace raven {
namespace net {

/**
 * Handles Session instances. This class is a singleton.
 * Use the static SessionHandler::getInstance() method to gain a reference
 * to the SessionHandler instance.
 * 
 * All relevant methods of this class must be thread-safe.
 */
class SessionHandler {

    std::unordered_map<std::string, std::shared_ptr<Session>> _sessions;
    std::mutex _mutex;

    //private constructor
    SessionHandler(){ }

    /**
     * Creates a unique session ID. The uniqueness must be guaranteed
     * within the surrounding system process but not necessarily
     * across process/application boundaries
     * 
     * @return A unique session ID, as a UUID.
     */
    Poco::UUID createSessionID();

public:

    /**
     * Creates a new Session from the specified RequestHTTP
     * and ResponseHTTP objects. The new session will use
     * the provided WebSocketHandler instance.
     * 
     * @param request The RequestHTTP to create a Session for.
     * @param response The ResponseHTTP to create a Session for.
     * @param handler The WebSocketHandler to create a Session for.
     * 
     * @return A new Session.
     */
    std::shared_ptr<Session> createSession(
        RequestHTTP& request,
        ResponseHTTP& response,
        std::shared_ptr<WebSocketHandler> handler);

    SessionHandler(SessionHandler const&) = delete;

    void operator=(SessionHandler const&) = delete;

    /**
     * Returns the Session with the specified ID.
     * 
     * @param sid The ID of the session to get.
     * 
     * @return A shared pointer to the Session with the specified ID,
     *         or null if no Session exists with the specified ID.
     */
    std::shared_ptr<Session> getSessionBy(const std::string& sid);

    /**
     * Removes the specified Session from this handler.
     * 
     * @param session The Session to remove.
     * 
     * @return True if the specified Session was successfully removed,
     *         false otherwise.
     */
    bool clear(std::shared_ptr<Session> session);

    /**
     * Terminates all open session.
     */
    void stopAllSessions();

    /**
     * Returns a reference to a SessionHandler.
     * 
     * @return A reference to a SessionHandler object.
     */
    static SessionHandler& getInstance(){
        static SessionHandler instance;
        return instance;
    }

}; // END CLASS SessionHandler

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_SESSION_HANDLER_H
