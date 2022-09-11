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

#include "Poco/Net/HTTPRequestHandler.h"
#include "Poco/Net/HTTPServerRequest.h"

#include "raven/net/DefaultRequestHandlerFactory.h"
#include "raven/net/WebSocketRequestHandler.h"
#include "raven/net/DefaultRequestHandler.h"
#include "raven/util/Log.h"


namespace raven {
namespace net {

using std::shared_ptr;
using Poco::Net::HTTPRequestHandler;
using Poco::Net::HTTPServerRequest;
using raven::net::RouterHTTP;
using raven::util::Log;


DefaultRequestHandlerFactory::DefaultRequestHandlerFactory(
    shared_ptr<RouterHTTP> router){

    _router = router;
}

HTTPRequestHandler* DefaultRequestHandlerFactory::createRequestHandler(
    const HTTPServerRequest& request){

    Log::info(
        request.clientAddress().toString()
      + " "
      + request.getMethod()
      + " "
      + request.getURI()
      + " "
      + request.getVersion());

    if(request.find("Upgrade") != request.end()
        && Poco::icompare(request["Upgrade"], "websocket") == 0){

        return new WebSocketRequestHandler(_router);
    }else{
        return new DefaultRequestHandler(_router);
    }
}

} // END NAMESPACE net
} // END NAMESPACE raven
