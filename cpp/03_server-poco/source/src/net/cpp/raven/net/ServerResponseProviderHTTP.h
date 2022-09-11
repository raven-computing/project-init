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

#ifndef RAVEN_NET_SERVER_RESPONSE_PROVIDER_HTTP_H
#define RAVEN_NET_SERVER_RESPONSE_PROVIDER_HTTP_H

#include <string>

#include "Poco/Buffer.h"
#include "Poco/Net/HTTPServerResponse.h"
#include "Poco/Net/HTTPResponse.h"
#include "Poco/Net/HTTPCookie.h"

#include "raven/net/ResponseHTTP.h"


namespace raven {
namespace net {

/**
 * Implementation class for the ResponseHTTP.
 */
class ServerResponseProviderHTTP {

    Poco::Net::HTTPServerResponse& _response;
    Poco::Buffer<char> _body;
    std::string _bodyStr;
    std::string _filePath;
    std::string _fileContentType;
    bool _isSent = false;
    ResponseBodyTypeHTTP _responseBodyType = ResponseBodyTypeHTTP::NO_BODY;

public:

    ServerResponseProviderHTTP(Poco::Net::HTTPServerResponse& response);

    void body(const std::string& text);

    void bodyRaw(Poco::Buffer<char>& data);

    void bodyFromFile(const std::string& path);

    void bodyFromFile(
        const std::string& path,
        const std::string& contentType);

    void setStatus(Poco::Net::HTTPResponse::HTTPStatus status);

    void setHeader(const std::string& name, const std::string& value);

    void setCookie(const Poco::Net::HTTPCookie& cookie);

    void setContentType(const std::string& mediaType);

    void send();

    bool isSent();

    Poco::Net::HTTPServerResponse& getServerResponse();

}; // END CLASS ServerResponseProviderHTTP

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_SERVER_RESPONSE_PROVIDER_HTTP_H
