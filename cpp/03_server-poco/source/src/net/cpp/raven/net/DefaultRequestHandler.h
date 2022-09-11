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

#ifndef RAVEN_NET_DEFAULT_REQUEST_HANDLER_H
#define RAVEN_NET_DEFAULT_REQUEST_HANDLER_H

#include <memory>

#include "Poco/Net/HTTPRequestHandler.h"
#include "Poco/Net/HTTPServerRequest.h"
#include "Poco/Net/HTTPServerResponse.h"

#include "raven/net/RouterHTTP.h"


namespace raven {
namespace net {

/**
 * Instances of this class are responsible for handling server requests.
 */
class DefaultRequestHandler: public Poco::Net::HTTPRequestHandler {

    std::shared_ptr<RouterHTTP> _router;

public:

    DefaultRequestHandler(std::shared_ptr<RouterHTTP> router);

    /**
     * Handles the specified server request.
     * 
     * @param request The HTTPServerRequest object of the request.
     * @param response The HTTPServerResponse object of the request.
     */
    void handleRequest(
        Poco::Net::HTTPServerRequest& request,
        Poco::Net::HTTPServerResponse& response);


}; // END CLASS DefaultRequestHandler

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_DEFAULT_REQUEST_HANDLER_H
