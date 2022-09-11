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

#include <istream>
#include <unordered_map>

#include "Poco/Buffer.h"
#include "Poco/StringTokenizer.h"
#include "Poco/Net/HTTPServerRequest.h"
#include "Poco/Net/NameValueCollection.h"

#include "raven/net/ServerRequestProviderHTTP.h"
#include "raven/net/RequestHTTP.h"


namespace raven {
namespace net {

using std::istream;
using std::size_t;
using std::string;
using Poco::Buffer;
using Poco::StringTokenizer;
using Poco::Net::HTTPServerRequest;
using Poco::Net::NameValueCollection;

static const size_t PAYLOAD_TMP_BUFFER_SIZE = 8192;

ServerRequestProviderHTTP::ServerRequestProviderHTTP(
    HTTPServerRequest& request)
     :_request(request),
      _body(Buffer<char>(0)){ }


void ServerRequestProviderHTTP::_readPayload(){
    istream& is = _request.stream();

    if(_body.capacity() == 0){
        _body.setCapacity(PAYLOAD_TMP_BUFFER_SIZE);
    }
    Buffer<char> buffer(0);
    buffer.setCapacity(PAYLOAD_TMP_BUFFER_SIZE);
    std::streamsize len = 0;
    is.read(buffer.begin(), PAYLOAD_TMP_BUFFER_SIZE);
    std::streamsize n = is.gcount();
    while(n > 0){
        buffer.resize(n);
        len += n;
        _body.append(buffer);
        if(is){
            is.read(buffer.begin(), PAYLOAD_TMP_BUFFER_SIZE);
            n = is.gcount();
        }else{
            n = 0;
        }
    }
    _body.resize(len);
    _bodyReady = true;
}

const string& ServerRequestProviderHTTP::getURI(){
    return _request.getURI();
}

string& ServerRequestProviderHTTP::getURIpath(){
    if(!_uriPathReady){
        const string& uri = _request.getURI();
        string path = uri;
        auto pos = path.find("?");
        if(pos != string::npos){
            path = path.substr(0, pos);
        }
        pos = path.find("#");
        if(pos != string::npos){
            path = path.substr(0, pos);
        }
        _uriPath = path;
        _uriPathReady = true;
    }
    return _uriPath;
}

const string& ServerRequestProviderHTTP::getMethod(){
    return _request.getMethod();
}

NameValueCollection& ServerRequestProviderHTTP::getHeaders(){
    return _request;
}

NameValueCollection& ServerRequestProviderHTTP::getQueryParams(){
    if(!_queryParamsReady){
        const string& uri = _request.getURI();
        string query = uri;
        auto pos = query.find("#");
        if(pos != string::npos){
            query = query.substr(0, pos);
        }
        pos = query.find("?");
        NameValueCollection params;
        if((pos != string::npos) && (query.size() > (pos + 1))){
            query = query.substr(pos + 1);

            StringTokenizer tokens(query, "&",
                StringTokenizer::TOK_TRIM | StringTokenizer::TOK_IGNORE_EMPTY);

            for(const string& token : tokens){
                auto index = token.find("=");
                if(index != string::npos && (token.size() > (index + 1))){
                    string key = token.substr(0, index);
                    string val = token.substr(index + 1);
                    params.add(key, val);
                }
            }
        }
        _queryParams = params;
        _queryParamsReady = true;
    }
    return _queryParams;
}

string& ServerRequestProviderHTTP::body(){
    if(!_bodyReady){
        _readPayload();
    }
    if(_body.empty()){
        return _bodyStr;
    }
    if(_bodyStr.empty()){
        //With C++17: Use std::string_view to avoid copy?
        _bodyStr = string(_body.begin(), _body.size());
    }
    return _bodyStr;
}

Buffer<char>& ServerRequestProviderHTTP::bodyRaw(){
    if(!_bodyReady){
        _readPayload();
    }
    return _body;
}

bool ServerRequestProviderHTTP::isSecure(){
    return _request.secure();
}

HTTPServerRequest& ServerRequestProviderHTTP::getServerRequest(){
    return _request;
}

} // END NAMESPACE net
} // END NAMESPACE raven
