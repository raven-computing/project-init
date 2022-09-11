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

#include <iostream>
#include <string>

#include "Poco/Buffer.h"
#include "Poco/Net/HTTPServerResponse.h"
#include "Poco/Net/HTTPResponse.h"
#include "Poco/Net/HTTPCookie.h"

#include "raven/net/ServerResponseProviderHTTP.h"


namespace raven {
namespace net {

using std::string;
using std::ostream;
using Poco::Buffer;
using Poco::Net::HTTPServerResponse;
using Poco::Net::HTTPResponse;
using Poco::Net::HTTPCookie;

static const size_t PAYLOAD_TMP_BUFFER_SIZE = 8192;

static void _sendText(HTTPServerResponse& response, const string& text){
    ostream& os = response.send();
    os << text;
}

static void _sendBinary(HTTPServerResponse& response, Buffer<char>& buffer){
    ostream& os = response.send();
    os.write(buffer.begin(), buffer.size());
}

static void _sendFile(
    HTTPServerResponse& response,
    const string& filePath,
    const string& contentType){

    response.sendFile(
        filePath,
        contentType.empty() ? "text/html" : contentType
    );
}

ServerResponseProviderHTTP::ServerResponseProviderHTTP(
    HTTPServerResponse& response)
     :_response(response),
      _body(Buffer<char>(0)){ }

void ServerResponseProviderHTTP::body(const string& text){
    _bodyStr = text;
    _responseBodyType = ResponseBodyTypeHTTP::TEXT;
}

void ServerResponseProviderHTTP::bodyRaw(Buffer<char>& data){
    _body = data;
    _responseBodyType = ResponseBodyTypeHTTP::BINARY;
}

void ServerResponseProviderHTTP::bodyFromFile(const string& path){
    _filePath = path;
    _fileContentType = "";
    _responseBodyType = ResponseBodyTypeHTTP::FILE;
}

void ServerResponseProviderHTTP::bodyFromFile(
    const string& path,
    const string& contentType){

    _filePath = path;
    _fileContentType = contentType;
    _responseBodyType = ResponseBodyTypeHTTP::FILE;
}

void ServerResponseProviderHTTP::setStatus(HTTPResponse::HTTPStatus status){
    _response.setStatus(status);
    _response.setReason(_response.getReasonForStatus(status));
}

void ServerResponseProviderHTTP::setHeader(
    const string& name,
    const string& value){

    _response.add(name, value);
}

void ServerResponseProviderHTTP::setCookie(const HTTPCookie& cookie){
    _response.addCookie(cookie);
}

void ServerResponseProviderHTTP::setContentType(const string& mediaType){
    _response.setContentType(mediaType);
}

void ServerResponseProviderHTTP::send(){
    if(!_isSent){
        switch(_responseBodyType){
        case ResponseBodyTypeHTTP::TEXT:
            _sendText(_response, _bodyStr);
            break;
        case ResponseBodyTypeHTTP::BINARY:
            _sendBinary(_response, _body);
            break;
        case ResponseBodyTypeHTTP::FILE:
            _sendFile(_response, _filePath, _fileContentType);
            break;
        default:
            break; //Ignore NO_BODY
        }
        _isSent = true;
    }
}

bool ServerResponseProviderHTTP::isSent(){
    return _isSent;
}

HTTPServerResponse& ServerResponseProviderHTTP::getServerResponse(){
    return _response;
}

} // END NAMESPACE net
} // END NAMESPACE raven
