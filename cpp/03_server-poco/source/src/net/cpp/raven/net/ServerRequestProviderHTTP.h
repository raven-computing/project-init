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

#ifndef RAVEN_NET_SERVER_REQUEST_PROVIDER_HTTP_H
#define RAVEN_NET_SERVER_REQUEST_PROVIDER_HTTP_H

#include <string>

#include "Poco/Buffer.h"
#include "Poco/Net/HTTPServerRequest.h"
#include "Poco/Net/NameValueCollection.h"


namespace raven {
namespace net {

/**
 * Implementation class for the RequestHTTP type.
 */
class ServerRequestProviderHTTP {

    Poco::Net::HTTPServerRequest& _request;
    Poco::Buffer<char> _body;
    Poco::Net::NameValueCollection _queryParams;
    std::string _bodyStr;
    std::string _uriPath;
    bool _bodyReady = false;
    bool _uriPathReady = false;
    bool _queryParamsReady = false;

public:

    ServerRequestProviderHTTP(Poco::Net::HTTPServerRequest& request);

    const std::string& getURI();

    std::string& getURIpath();

    const std::string& getMethod();

    Poco::Net::NameValueCollection& getHeaders();

    Poco::Net::NameValueCollection& getQueryParams();

    std::string& body();

    Poco::Buffer<char>& bodyRaw();

    bool isSecure();

    Poco::Net::HTTPServerRequest& getServerRequest();

private:

    void _readPayload();

}; // END CLASS ServerRequestProviderHTTP

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_SERVER_REQUEST_PROVIDER_HTTP_H
