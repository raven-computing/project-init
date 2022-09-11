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

#include "raven/net/Message.h"


namespace raven {
namespace net {

using std::string;

Message::Message(int type)
    :_type(type){ }

Message::Message(const string& text)
    :_text(text),
     _type(1){ }

Message::Message(int type, const string& text)
    :_type(type),
     _text(text){ }

const string& Message::getText(){
    return _text;
}

bool Message::isText(){
    return _type == 1;
}

bool Message::isPing(){
    return _type == 2;
}

bool Message::isPong(){
    return _type == 3;
}

} // END NAMESPACE net
} // END NAMESPACE raven
