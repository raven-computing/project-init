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

#ifndef RAVEN_NET_SERVER_TCP_H
#define RAVEN_NET_SERVER_TCP_H

#include <memory>
#include <string>
#include <vector>

#include "Poco/ErrorHandler.h"
#include "Poco/Net/HTTPRequestHandlerFactory.h"
#include "Poco/Util/ServerApplication.h"

#include "raven/net/RouterHTTP.h"


namespace raven {
namespace net {

/**
 * A simple server implementation for handling TCP-based
 * HTTP/WebSocket connections.
 */
class ServerTCP : public Poco::Util::ServerApplication {

    const unsigned short _port;
    std::shared_ptr<RouterHTTP> _router;

protected:

    void initialize(Application& self);
        
    void uninitialize();

    int main(const std::vector<std::string>& args);

public:

    /**
     * Constructs a new server using the specified port.
     * 
     * @param port The port to be used by the server.
     */
    ServerTCP(const unsigned short port);

    /**
     * Provides a RouterHTTP to be used by the server.
     * This method should be implemented by the user of the ServerTCP class.
     * 
     * @return A RouterHTTP implementation to be used by the server.
     */
    virtual std::shared_ptr<RouterHTTP> router();

    /**
     * Provides an ErrorHandler to be used by the server.
     * This method can be implemented by the user of the ServerTCP class.
     * 
     * @return A Poco::ErrorHandler implementation to be used by the server.
     */
    virtual Poco::ErrorHandler* errorHandler();

    /**
     * Provides an HTTPRequestHandlerFactory to be used by the server.
     * This method can be implemented by the user of the ServerTCP class.
     * 
     * @param router The RouterHTTP implementation used by the server.
     * @return A Poco::Net::HTTPRequestHandlerFactory implementation to
     *          be used by the server.
     */
    virtual Poco::Net::HTTPRequestHandlerFactory* requestHandlerFactory(
        std::shared_ptr<RouterHTTP> router);

    /**
     * This callback method is called when the server has been requested to
     * start its operation but before it has finished the startup operation.
     */
    virtual void onStartRequested();

    /**
     * This callback method is called when the server has finished
     * its startup operation and is ready to receive server requests.
     */
    virtual void onStart();

    /**
     * This callback method is called when the server has been requested to
     * stop its operation but before it has finished the shutdown.
     */
    virtual void onStopRequested();

    /**
     * This callback method is called when the server has finished
     * its shutdown operation and is no longer capable to receive
     * server requests.
     */
    virtual void onStop();

    /**
     * Gets the port used by the server.
     * 
     * @return The port number used by the server.
     */
    unsigned short getPort() const;

}; // END CLASS ServerTCP

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_SERVER_TCP_H
