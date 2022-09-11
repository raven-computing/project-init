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

#ifndef RAVEN_NET_MESSAGE_H
#define RAVEN_NET_MESSAGE_H

#include <string>


namespace raven {
namespace net {

/**
 * Represents all messages which can be exchanged via
 * web socket connections. Currently, only text
 * messages are supported.
 */
class Message {

    std::string _text;
    int _type;

public:

    /**
     * Constructs a new empty Message of the given type.
     * 
     * @param type The type of the Message.
     *             1 = text, 2 = ping, 3 = pong.
     */
    Message(int type);

    /**
     * Constructs a new text Message with the given text content.
     * 
     * @param text The text content of the Message.
     */
    Message(const std::string& text);

    /**
     * Constructs a new text Message with the given text content
     * and the specified type.
     * 
     * @param type The type of the Message.
     *             1 = text, 2 = ping, 3 = pong.
     * @param text The text content of the Message.
     */
    Message(int type, const std::string& text);

    /**
     * Gets the text content of this Message.
     * 
     * @return The text content of this Message.
     */
    const std::string& getText();

    /**
     * Indicates whether this Message is a text message.
     * 
     * @return True if this Message represents a regular web socket
     *         text message, false otherwise.
     */
    bool isText();

    /**
     * Indicates whether this Message is a Ping message.
     * 
     * @return True if this Message represents a Ping web socket message,
     *         false otherwise.
     */
    bool isPing();

    /**
     * Indicates whether this Message is a Pong message.
     * 
     * @return True if this Message represents a Pong web socket message,
     *         false otherwise.
     */
    bool isPong();

}; // END CLASS Message

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_MESSAGE_H
