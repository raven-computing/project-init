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

#ifndef RAVEN_NET_ROUTER_HTTP_H
#define RAVEN_NET_ROUTER_HTTP_H

#include <string>
#include <vector>
#include <unordered_map>
#include <functional>

#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"
#include "raven/net/WebSocketController.h"
#include "raven/net/WebSocketDispatcher.h"


namespace raven {
namespace net {

/**
 * Instances of this class route server requests to the
 * corresponding controller instances. When a request to a server is made,
 * a router looks at the URI path of the request and determines what
 * controller is responsible to handle that request and then forwards
 * it to that controller. Users of the ServerTCP class should mostly provide
 * an implementation inheriting from the BasicRouterHTTP class.
 */
class RouterHTTP {

protected:

    std::unordered_map<std::string,
                       std::function<void(RequestHTTP&, ResponseHTTP&)>>
                       routes;

    std::vector<WebSocketDispatcher> wsDispatchers;

public:

    /**
     * Called by a server implementation to initialize
     * the router internal state.
     */
    virtual void initialize() = 0;

    /**
     * Routes the server request to the responsible controller.
     * 
     * @param request A reference to the RequestHTTP object to route
     *                to the controller.
     * @param response A reference to the ResponseHTTP object to route
     *                 to the controller.
     */
    virtual void route(RequestHTTP& request, ResponseHTTP& response) = 0;

    /**
     * This method should be called when no route exists for
     * a given server request.
     * 
     * @param request A reference to the RequestHTTP object of
     *                the unrouteable request.
     * @param response A reference to the ResponseHTTP object of
     *                the unrouteable request.
     */
    virtual void onError404(RequestHTTP& request, ResponseHTTP& response) = 0;

}; // END CLASS RouterHTTP

/**
 * Basic implementation of the RouterHTTP class providing
 * convenience methods to set up server routes.
 * Users of the ServerTCP class should provide an implementation inheriting
 * from this class and implement the defineRoutes() method.
 */
class BasicRouterHTTP : public RouterHTTP {

public:

    BasicRouterHTTP();

    /**
     * This method has to be implemented by subclasses.
     */
    virtual void defineRoutes() = 0;

    /**
     * Called by a server implementation to initialize
     * the router internal state.
     */
    virtual void initialize();

    /**
     * Routes the server request to the responsible controller.
     * 
     * @param request A reference to the RequestHTTP object to route
     *                to the controller.
     * @param response A reference to the ResponseHTTP object to route
     *                 to the controller.
     */
    virtual void route(RequestHTTP& request, ResponseHTTP& response);

    /**
     * This method is called when no route exists for
     * a given server request.
     * 
     * @param request A reference to the RequestHTTP object of
     *                the unrouteable request.
     * @param response A reference to the ResponseHTTP object of
     *                the unrouteable request.
     */
    virtual void onError404(RequestHTTP& request, ResponseHTTP& response);

    /**
     * Defines a static route for the router implementation.
     * 
     * @param path The URI path for which the specified controller
     *             method should be called.
     * @param method The controller method responsible for the handling
     *               HTTP requests for the specified URI path.
     */
    void staticRoute(
        const std::string& path,
        std::function<void(RequestHTTP&, ResponseHTTP&)> method);

    /**
     * Defines a static route for initiating web socket connections.
     * 
     * @param path The URI path for which the specified WebSocketController
     *             should be used to handle the connection.
     * @param controller A reference to the WebSocketController instance
     *                   responsible for handling web socket connections
     *                   initially established by a client request to the
     *                   specified URI path.
     */
    void webSocketRoute(
        const std::string& path,
        WebSocketController& controller);

}; // END CLASS BasicRouterHTTP

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_ROUTER_HTTP_H
