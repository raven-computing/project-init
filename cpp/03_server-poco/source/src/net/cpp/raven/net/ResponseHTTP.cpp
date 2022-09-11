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
#include "Poco/Net/HTTPServerResponse.h"
#include "Poco/Net/HTTPCookie.h"
#include "Poco/Net/NameValueCollection.h"

#include "raven/net/ResponseHTTP.h"
#include "raven/net/ServerResponseProviderHTTP.h"


namespace raven {
namespace net {

using std::string;
using Poco::Buffer;
using Poco::Net::HTTPResponse;
using Poco::Net::HTTPCookie;

ResponseHTTP::ResponseHTTP(ServerResponseProviderHTTP& response)
    :_response(response){ }

ResponseHTTP& ResponseHTTP::body(const string& text){
    _response.body(text);
    return *this;
}

ResponseHTTP& ResponseHTTP::bodyRaw(Buffer<char>& data){
    _response.bodyRaw(data);
    return *this;
}

ResponseHTTP& ResponseHTTP::bodyFromFile(const string& path){
    _response.bodyFromFile(path);
    return *this;
}

ResponseHTTP& ResponseHTTP::bodyFromFile(
    const string& path,
    const string& contentType){

    _response.bodyFromFile(path, contentType);
    return *this;
}

ResponseHTTP& ResponseHTTP::setStatus(HTTPResponse::HTTPStatus status){
    _response.setStatus(status);
    return *this;
}

ResponseHTTP& ResponseHTTP::setHeader(const string& name, const string& value){
    _response.setHeader(name, value);
    return *this;
}

ResponseHTTP& ResponseHTTP::setCookie(const HTTPCookie& cookie){
    _response.setCookie(cookie);
    return *this;
}

ResponseHTTP& ResponseHTTP::setContentType(const string& mediaType){
    _response.setContentType(mediaType);
    return *this;
}

void ResponseHTTP::send(){
    _response.send();
}

bool ResponseHTTP::isSent(){
    return _response.isSent();
}

ServerResponseProviderHTTP& ResponseHTTP::getProvider(){
    return _response;
}

} // END NAMESPACE net
} // END NAMESPACE raven
