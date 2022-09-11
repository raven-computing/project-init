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

#include <string>

#include "Poco/Buffer.h"
#include "Poco/Net/NameValueCollection.h"

#include "raven/net/RequestHTTP.h"
#include "raven/net/ServerRequestProviderHTTP.h"


namespace raven {
namespace net {

using std::string;
using Poco::Buffer;
using Poco::Net::NameValueCollection;

RequestHTTP::RequestHTTP(ServerRequestProviderHTTP& request)
    :_request(request){ }

const string& RequestHTTP::getURI(){
    return _request.getURI();
}

string& RequestHTTP::getURIpath(){
    return _request.getURIpath();
}

const string& RequestHTTP::getMethod(){
    return _request.getMethod();
}

NameValueCollection& RequestHTTP::getHeaders(){
    return _request.getHeaders();
}

NameValueCollection& RequestHTTP::getQueryParams(){
    return _request.getQueryParams();
}

string& RequestHTTP::body(){
    return _request.body();
}

Buffer<char>& RequestHTTP::bodyRaw(){
    return _request.bodyRaw();
}

bool RequestHTTP::isSecure(){
    return _request.isSecure();
}

ServerRequestProviderHTTP& RequestHTTP::getProvider(){
    return _request;
}

} // END NAMESPACE net
} // END NAMESPACE raven
