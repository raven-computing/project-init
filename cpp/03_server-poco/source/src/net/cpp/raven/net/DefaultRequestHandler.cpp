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

#include <memory>
#include <string>

#include "Poco/Net/HTTPServerRequest.h"
#include "Poco/Net/HTTPServerResponse.h"
#include "Poco/Net/NetException.h"

#include "raven/net/DefaultRequestHandler.h"
#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"
#include "raven/net/ServerRequestProviderHTTP.h"
#include "raven/net/ServerResponseProviderHTTP.h"
#include "raven/util/Log.h"


namespace raven {
namespace net {

using std::shared_ptr;
using std::string;
using Poco::Net::HTTPServerRequest;
using Poco::Net::HTTPServerResponse;
using Poco::Net::HTTPResponse;
using raven::net::RequestHTTP;
using raven::net::ResponseHTTP;
using raven::util::Log;

DefaultRequestHandler::DefaultRequestHandler(shared_ptr<RouterHTTP> router){
    _router = router;
}

void DefaultRequestHandler::handleRequest(
    HTTPServerRequest& request,
    HTTPServerResponse& response){

    try{
        ServerRequestProviderHTTP reqProvider(request);
        ServerResponseProviderHTTP resProvider(response);
        RequestHTTP req(reqProvider);
        ResponseHTTP res(resProvider);

        if(_router){
            _router->route(req, res);
        }

        res.send();

    }catch(const Poco::Net::ConnectionAbortedException& ex){
        Log::error(ex.displayText());
    }catch(const Poco::Exception& ex){
        Log::error(ex.displayText());
    }catch(const std::exception& ex){
        const string err = ex.what();
        string s = "Exception while handling server request: " + err;
        Log::error(s);
    }catch(...){
        Log::error("Unknown server error");
    }
}

} // END NAMESPACE net
} // END NAMESPACE raven
