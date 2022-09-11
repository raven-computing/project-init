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

#ifndef RAVEN_UTIL_LOG_H
#define RAVEN_UTIL_LOG_H

#include <string>


namespace raven {
namespace util {

/**
 * Central logging facilities. All logging functions are provided
 * as static functions.
 */
class Log {

public:

    /**
     * Initializes the logging facilities. This function should be
     * called once at application startup.
     */
    static void initialize();

    /**
     * Shuts down the logging facilities. This function
     * should be called once when the application shuts down.
     */
    static void close();

    /**
     * Logs the specified INFO message.
     * 
     * @param msg The message to log
     */
    static void info(const std::string& msg);

    /**
     * Logs the specified DEBUG message.
     * 
     * @param msg The message to log
     */
    static void debug(const std::string& msg);

    /**
     * Logs the specified WARNING message.
     * 
     * @param msg The message to log
     */
    static void warn(const std::string& msg);

    /**
     * Logs the specified ERROR message.
     * 
     * @param msg The message to log
     */
    static void error(const std::string& msg);

    /**
     * Indicates whether debug logging is currently enabled
     * 
     * @return True if debug logging is enabled,
     *         false if it is disabled
     */
    static bool debug();

}; // END CLASS Log

} // END NAMESPACE util
} // END NAMESPACE raven

#endif // RAVEN_UTIL_LOG_H
