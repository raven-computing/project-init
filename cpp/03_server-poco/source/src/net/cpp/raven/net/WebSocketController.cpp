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

#include "raven/net/WebSocketController.h"
#include "raven/net/Session.h"
#include "raven/net/Message.h"


namespace raven {
namespace net {

using std::exception;

void WebSocketController::onConnect(Session& session){ }

void WebSocketController::onDisconnect(Session& session){ }

void WebSocketController::onMessageReceived(
    Session& session, Message& message){ }

void WebSocketController::onPingReceived(Session& session, Message& message){ }

void WebSocketController::onPongReceived(Session& session, Message& message){ }

void WebSocketController::onError(Session& session, const exception& ex){ }

} // END NAMESPACE net
} // END NAMESPACE raven
