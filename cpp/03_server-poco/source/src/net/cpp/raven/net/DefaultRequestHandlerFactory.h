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

#ifndef RAVEN_NET_DEFAULT_REQUEST_HANDLER_FACTORY_H
#define RAVEN_NET_DEFAULT_REQUEST_HANDLER_FACTORY_H

#include <memory>

#include "Poco/Net/HTTPRequestHandler.h"
#include "Poco/Net/HTTPRequestHandlerFactory.h"
#include "Poco/Net/HTTPServerRequest.h"

#include "raven/net/RouterHTTP.h"


namespace raven {
namespace net {

/**
 * Instances of this class are responsible for creating HTTPRequestHandler
 * objects for correctly processing the corresponding requests.
 */
class DefaultRequestHandlerFactory
        : public Poco::Net::HTTPRequestHandlerFactory {

    std::shared_ptr<RouterHTTP> _router;

public:

    DefaultRequestHandlerFactory(std::shared_ptr<RouterHTTP> router);

    /**
     * Create a new HTTPRequestHandler instance for handling
     * the specified HTTPServerRequest
     * 
     * @param request The HTTPServerRequest to handle
     * 
     * @return A HTTPRequestHandler for handling
     *         the specified HTTPServerRequest
     */
    Poco::Net::HTTPRequestHandler* createRequestHandler(
        const Poco::Net::HTTPServerRequest& request);

}; // END CLASS DefaultRequestHandlerFactory

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_DEFAULT_REQUEST_HANDLER_FACTORY_H
