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

#ifndef RAVEN_NET_CONTROLLER_HTTP_H
#define RAVEN_NET_CONTROLLER_HTTP_H

#include <exception>

#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"


namespace raven {
namespace net {

/**
 * Base class for all controllers handling HTTP server requests.
 */
class ControllerHTTP {

public:

    /**
     * This method is called when an uncaught error is encountered
     * during the handling of an HTTP server request.
     * 
     * @param request A reference to the RequestHTTP object
     *                of the server request.
     * @param response A reference to the ResponseHTTP object of
     *                 the server request.
     * @param ex A reference to the exception which occurred.
     */
    virtual void handleError(
        RequestHTTP& request,
        ResponseHTTP& response,
        const std::exception& ex);

}; // END CLASS ControllerHTTP

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_CONTROLLER_HTTP_H
