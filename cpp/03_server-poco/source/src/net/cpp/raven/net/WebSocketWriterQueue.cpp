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

#include <mutex>
#include <condition_variable>
#include <deque>

#include "raven/net/WebSocketWriter.h"


namespace raven {
namespace net {

using std::unique_lock;
using std::mutex;

WebSocketWriterQueue::WebSocketWriterQueue(){ }

void WebSocketWriterQueue::add(WSWQ_Item const& msg){
    {
        unique_lock<mutex> lock(this->_mutex);
        _queue.push_front(msg);
    }
    this->_condition.notify_one();
}

WSWQ_Item WebSocketWriterQueue::get(){
    unique_lock<mutex> lock(this->_mutex);
    this->_condition.wait(lock, [=]{ return !this->_queue.empty(); });
    WSWQ_Item rc(std::move(this->_queue.back()));
    this->_queue.pop_back();
    return rc;
}

} // END NAMESPACE net
} // END NAMESPACE raven
