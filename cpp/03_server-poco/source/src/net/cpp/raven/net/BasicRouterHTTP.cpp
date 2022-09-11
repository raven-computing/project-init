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

#include <vector>
#include <functional>

#include "Poco/Net/HTTPResponse.h"

#include "raven/net/RouterHTTP.h"
#include "raven/net/WebSocketDispatcher.h"
#include "raven/net/WebSocketController.h"


namespace raven {
namespace net {

using std::unique_ptr;
using std::shared_ptr;
using std::make_unique;
using std::bind;
using std::placeholders::_1;
using std::placeholders::_2;
using Poco::Net::HTTPResponse;


BasicRouterHTTP::BasicRouterHTTP(){ }

void BasicRouterHTTP::initialize(){
    defineRoutes();
}

void BasicRouterHTTP::staticRoute(
    const std::string& path,
    std::function<void(RequestHTTP&, ResponseHTTP&)> method){

    routes[path] = method;
}

void BasicRouterHTTP::webSocketRoute(
    const std::string& path,
    WebSocketController& controller){

    wsDispatchers.emplace_back(WebSocketDispatcher(controller));
    WebSocketDispatcher& dispatcher = wsDispatchers.back();
    routes[path] = bind(&WebSocketDispatcher::dispatch, dispatcher, _1, _2);
}

void BasicRouterHTTP::route(RequestHTTP& request, ResponseHTTP& response){
    auto route = routes.find(request.getURIpath());
    if(route == routes.end()){
        onError404(request, response);
        return;
    }
    auto& method = route->second;
    method(request, response);
}

void BasicRouterHTTP::onError404(RequestHTTP& request, ResponseHTTP& response){
    response.setStatus(HTTPResponse::HTTPStatus::HTTP_NOT_FOUND)
            .body("Error 404: Not Found");
}

} // END NAMESPACE net
} // END NAMESPACE raven
