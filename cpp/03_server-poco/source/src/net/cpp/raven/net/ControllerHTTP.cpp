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

#include <exception>

#include "raven/net/ControllerHTTP.h"
#include "raven/util/Log.h"


namespace raven {
namespace net {

using std::exception;
using raven::util::Log;

void ControllerHTTP::handleError(
    RequestHTTP& request,
    ResponseHTTP& response,
    const exception& ex){

    Log::error(
        "Unhandled exception occurred while processing HTTP server request."
    );
}

} // END NAMESPACE net
} // END NAMESPACE raven
