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

#ifndef RAVEN_NET_RESPONSE_HTTP_H
#define RAVEN_NET_RESPONSE_HTTP_H

#include <string>

#include "Poco/Buffer.h"
#include "Poco/Net/HTTPServerResponse.h"
#include "Poco/Net/HTTPCookie.h"
#include "Poco/Net/NameValueCollection.h"


namespace raven {
namespace net {

//Forward declaration
class ServerResponseProviderHTTP;

/**
 * Enumeration for all supported response types.
 */
enum class ResponseBodyTypeHTTP {
    NO_BODY,
    TEXT,
    BINARY,
    FILE
};

/**
 * Represents a network response over HTTP(S). Instances of this class provide
 * access to the data associated with a response, such as payload and meta data.
 */
class ResponseHTTP {

    ServerResponseProviderHTTP& _response;

public:

    /**
     * Constructs a new ResponseHTTP instance using the specified
     * response provider.
     * 
     * @param response A reference to a ServerResponseProviderHTTP instance to be
     *                 used by the new ResponseHTTP instance.
     */
    ResponseHTTP(ServerResponseProviderHTTP& response);

    /**
     * Sets the body of this response to the specified text.
     * 
     * @param text The text of the response body.
     * 
     * @return This ResponseHTTP instance.
     */
    ResponseHTTP& body(const std::string& text);

    /**
     * Sets the body of this response to the specified raw binary data.
     * 
     * @param data The binary data of the response body.
     * 
     * @return This ResponseHTTP instance.
     */
    ResponseHTTP& bodyRaw(Poco::Buffer<char>& data);

    /**
     * Sets the body of this response to the content of the specified file.
     * The 'Content-Type' header entry of this response will be
     * set to 'text/html'.
     * 
     * @param path The path to the file to return in the response.
     * 
     * @return This ResponseHTTP instance.
     */
    ResponseHTTP& bodyFromFile(const std::string& path);

    /**
     * Sets the body of this response to the content of the specified file.
     * This method also sets the 'Content-Type' header entry of this response
     * to the specified value, e.g. 'text/html'.
     * 
     * @param path The path to the file to return in the response.
     * @param contentType The value of the 'Content-Type' header entry to
     *                    be set for this response.
     * 
     * @return This ResponseHTTP instance.
     */
    ResponseHTTP& bodyFromFile(
        const std::string& path,
        const std::string& contentType);

    /**
     * Sets the HTTP status of the response.
     * 
     * @param status The status of the response.
     * 
     * @return This ResponseHTTP instance.
     */
    ResponseHTTP& setStatus(Poco::Net::HTTPResponse::HTTPStatus status);

    /**
     * Sets the header entry in this response with the specified name and value.
     * 
     * @param name The name of the header to set.
     * @param value The value of the header to set.
     * 
     * @return This ResponseHTTP instance.
     */
    ResponseHTTP& setHeader(const std::string& name, const std::string& value);

    /**
     * Sets the specified cookie within the response.
     * 
     * @param cookie The cookie to set in the response.
     * 
     * @return This ResponseHTTP instance.
     */
    ResponseHTTP& setCookie(const Poco::Net::HTTPCookie& cookie);

    /**
     * Sets the content-type header within the response.
     * 
     * @param mediaType The string representation of the media type to set.
     * 
     * @return This ResponseHTTP instance.
     */
    ResponseHTTP& setContentType(const std::string& mediaType);

    /**
     * Sends the server response to the client.
     * Repeated calls to this method have no effect.
     */
    void send();

    /**
     * Indicates whether this response has already been sent.
     * 
     * @return True if this response has already been sent,
     *         false otherwise.
     */
    bool isSent();

    /**
     * Gets a reference to implementation detail ServerResponseProviderHTTP
     * instance of this ResponseHTTP object.
     * 
     * @return A reference to the ServerResponseProviderHTTP instance
     *         used by this ResponseHTTP object.
     */
    ServerResponseProviderHTTP& getProvider();

}; // END CLASS ResponseHTTP

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_RESPONSE_HTTP_H
