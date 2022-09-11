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

#include "Poco/Net/HTTPServerRequest.h"
#include "Poco/Net/HTTPServerResponse.h"

#include "raven/net/WebSocketRequestHandler.h"
#include "raven/net/ServerRequestProviderHTTP.h"
#include "raven/net/ServerResponseProviderHTTP.h"


namespace raven {
namespace net {

using std::shared_ptr;
using Poco::Net::HTTPServerRequest;
using Poco::Net::HTTPServerResponse;

WebSocketRequestHandler::WebSocketRequestHandler(
    shared_ptr<RouterHTTP> router){

    _router = router;
}

void WebSocketRequestHandler::handleRequest(
    HTTPServerRequest& request,
    HTTPServerResponse& response){

    ServerRequestProviderHTTP reqProvider(request);
    ServerResponseProviderHTTP resProvider(response);
    RequestHTTP req(reqProvider);
    ResponseHTTP res(resProvider);

    if(_router){
        _router->route(req, res);
    }
}

} // END NAMESPACE net
} // END NAMESPACE raven
