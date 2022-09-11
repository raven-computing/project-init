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
#include <exception>

#include "Poco/Exception.h"

#include "raven/net/DefaultErrorHandler.h"
#include "raven/util/Log.h"


namespace raven {
namespace net {

using std::string;
using raven::util::Log;

void DefaultErrorHandler::exception(const Poco::Exception& ex){
    Log::debug("Server thread exception handled: " + ex.message());
}

void DefaultErrorHandler::exception(const std::exception& ex){
    const string msg = ex.what();
    Log::debug("Server thread exception handled: " + msg);
}

void DefaultErrorHandler::exception(){
    Log::debug("Server thread unknown exception handled");
}

} // END NAMESPACE net
} // END NAMESPACE raven
