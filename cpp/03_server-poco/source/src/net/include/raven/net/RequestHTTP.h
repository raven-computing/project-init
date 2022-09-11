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

#ifndef RAVEN_NET_REQUEST_HTTP_H
#define RAVEN_NET_REQUEST_HTTP_H

#include <string>

#include "Poco/Buffer.h"
#include "Poco/Net/NameValueCollection.h"


namespace raven {
namespace net {

//Forward declaration
class ServerRequestProviderHTTP;

/**
 * Represents a network request over HTTP(S). Instances of this class provide
 * access to the data associated with a request, such as payload and meta data.
 */
class RequestHTTP {

    ServerRequestProviderHTTP& _request;

public:

    /**
     * Constructs a new RequestHTTP instance using the specified
     * request provider.
     * 
     * @param request A reference to a ServerRequestProviderHTTP instance to be
     *                used by the new RequestHTTP instance.
     */
    RequestHTTP(ServerRequestProviderHTTP& request);

    /**
     * Gets the URI of this request.
     * 
     * @return The full URI of this request.
     */
    const std::string& getURI();

    /**
     * Gets the path component of this request's URI.
     * 
     * @return The URI path of this request.
     */
    std::string& getURIpath();

    /**
     * Gets the HTTP method (e.g. "GET" or "POST") of this request.
     * 
     * @return The HTTP method used for this request.
     */
    const std::string& getMethod();

    /**
     * Gets the HTTP headers of this request.
     * 
     * @return All HTTP headers of this request, as a NameValueCollection.
     */
    Poco::Net::NameValueCollection& getHeaders();

    /**
     * Gets the query parameters of this request.
     * 
     * @return All query parameters of this request, as a NameValueCollection.
     */
    Poco::Net::NameValueCollection& getQueryParams();

    /**
     * Gets HTTP request body, as a string.
     * 
     * @return The entire HTTP request body. Returns an empty string if
     *         no body was supplied in the request.
     */
    std::string& body();

    /**
     * Gets raw HTTP request body, as a char buffer.
     * 
     * @return The entire HTTP request body. Returns an empty buffer if
     *         no body was supplied in the request.
     */
    Poco::Buffer<char>& bodyRaw();

    /**
     * Indicates whether this HTTP request was established through a
     * secure communication channel, i.e. using HTTPS instead of plain HTTP.
     * 
     * @return True if this request is guaranteed to be secure,
     *         false otherwise.
     */
    bool isSecure();

    ServerRequestProviderHTTP& getProvider();

}; // END CLASS RequestHTTP

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_REQUEST_HTTP_H
