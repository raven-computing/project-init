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

#ifndef RAVEN_NET_WEB_SOCKET_WRITER_H
#define RAVEN_NET_WEB_SOCKET_WRITER_H

#include <memory>
#include <string>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <atomic>
#include <deque>

#include "raven/net/Message.h"


namespace raven {
namespace net {

//Forward declaration
class WebSocketHandler;

/**
 * Represents a text message to be stored in the internal queue
 * of a WebSocketWriter instance.
 */
struct WSWQ_Item {

    //Flag indicating whether the item marks a cancellation signal
    bool cancel;
    //The message item
    std::shared_ptr<Message> msg;

}; // END STRUCT WSWQ_Item

/**
 * A synchronized Queue implementation for storing WSWQ_Item objects.
 */
class WebSocketWriterQueue {

    std::mutex _mutex;
    std::condition_variable _condition;
    std::deque<WSWQ_Item> _queue;

public:

    /**
     * Constructs a new WebSocketWriterQueue instance.
     */
    WebSocketWriterQueue();

    /**
     * Adds the provided queue message to this WebSocketWriterQueue.
     * 
     * @param msg The reference to the message to be added.
     */
    void add(WSWQ_Item const& msg);

    /**
     * Gets the next available message and removes it
     * from this WebSocketWriterQueue.
     * 
     * @return The next WSWQ_Item object in this WebSocketWriterQueue
     */
    WSWQ_Item get();

}; // END CLASS WebSocketWriterQueue

/**
 * A writer thread for a web socket connection.
 */
class WebSocketWriter {

    std::shared_ptr<WebSocketHandler> _handler;
    std::thread _thread;
    WebSocketWriterQueue _queue;
    std::atomic<bool> _isRunning;

public:

    /**
     * Constructs a WebSocketWriter for the specified WebSocketHandler.
     * The underlying thread is not started until the start() method
     * is explicitly called.
     * 
     * @param handler The WebSocketHandler to be used by the WebSocketWriter.
     */
    WebSocketWriter(std::shared_ptr<WebSocketHandler> handler);

    /**
     * Starts the writer thread.
     */
    void start();

    /**
     * Stops the writer thread and disposes the underlying std::thread.
     * This method blocks until the thread has finished its
     * internal loop operation.
     */
    void stop();

    /**
     * Returns the WebSocketWriterQueue of this WebSocketWriter object.
     * 
     * @return The internally used WebSocketWriterQueue.
     */
    WebSocketWriterQueue& getQueue();

    /**
     * Sends the specified message to the remote endpoint of
     * the underlying web socket. This method is asynchronous.
     * 
     * @param msg The message to send.
     */
    void send(std::shared_ptr<Message> msg);

    /**
     * Sends the specified text message to the remote endpoint of
     * the underlying web socket. This method is asynchronous.
     * 
     * @param text The text message to send.
     */
    void sendText(const std::string& text);

private:

    /**
     * Writer thread loop implementation.
     */
    void _writerLoop();

    /**
     * Create a finalization item to be added to
     * the writer thread WebSocketWriterQueue.
     * 
     * @return A WSWQ_Item representing a finalization item.
     */
    WSWQ_Item _finalizationItem();

}; // END CLASS WebSocketWriter

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_WEB_SOCKET_WRITER_H
