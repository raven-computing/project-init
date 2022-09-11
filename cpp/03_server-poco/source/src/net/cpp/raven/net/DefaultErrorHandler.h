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

#ifndef RAVEN_NET_DEFAULT_ERROR_HANDLER_H
#define RAVEN_NET_DEFAULT_ERROR_HANDLER_H

#include <exception>

#include "Poco/ErrorHandler.h"
#include "Poco/Exception.h"


namespace raven {
namespace net {

/**
 * Default error handler used by the ServerTCP class.
 */
class DefaultErrorHandler : public Poco::ErrorHandler {

    virtual void exception(const Poco::Exception& ex);
        
    virtual void exception(const std::exception& ex);

    virtual void exception();

}; // END CLASS DefaultErrorHandler

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_DEFAULT_ERROR_HANDLER_H
