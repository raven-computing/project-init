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

#ifndef RAVEN_NET_WEB_SOCKET_READER_H
#define RAVEN_NET_WEB_SOCKET_READER_H

#include <memory>
#include <thread>
#include <atomic>


namespace raven {
namespace net {

//Forward declaration
class WebSocketHandler;

/**
 * A reader thread for a web socket connection.
 */
class WebSocketReader {

    std::shared_ptr<WebSocketHandler> _handler;
    std::thread _thread;
    std::atomic<bool> _isRunning;

public:

    /**
     * Constructs a WebSocketReader for the specified WebSocketHandler.
     * The underlying thread is not started until the start() method
     * is explicitly called
     * 
     * @param handler The WebSocketHandler to be used by the WebSocketReader.
     */
    WebSocketReader(std::shared_ptr<WebSocketHandler> handler);

    /**
     * Starts the reader thread.
     */
    void start();

    /**
     * Stops the reader thread and disposes the underlying std::thread.
     * This method blocks until the thread has finished its
     * internal loop operation
     */
    void stop();

private:

    /**
     * Reader thread loop implementation.
     */
    void _readerLoop();

}; // END CLASS WebSocketReader

} // END NAMESPACE net
} // END NAMESPACE raven

#endif // RAVEN_NET_WEB_SOCKET_READER_H
