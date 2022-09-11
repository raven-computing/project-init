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
#include <iostream>

#include "Poco/Timestamp.h"
#include "Poco/DateTimeFormat.h"
#include "Poco/DateTimeFormatter.h"

#include "raven/util/Log.h"


namespace raven {
namespace util {

using std::string;
using Poco::Timestamp;
using Poco::DateTimeFormat;
using Poco::DateTimeFormatter;

static string now(){
    return DateTimeFormatter::format(
        Timestamp(),
        "%Y-%m-%dT%H:%M:%S"
    );
}

void Log::initialize(){ }

void Log::close(){ }

void Log::info(const string& msg){
    std::cout << "[INFO] " << now() << " " << msg << std::endl;
}

void Log::warn(const string& msg){
    std::cout << "[WARN] " << now() << " " << msg << std::endl;
}

void Log::error(const string& msg){
    std::cout << "[ERROR] " << now() << " " << msg << std::endl;
}

void Log::debug(const string& msg){
    if(debug()){
        std::cout << "[DEBUG] " << now() << " " << msg << std::endl;
    }
}

bool Log::debug(){
    return false;
}

} // END NAMESPACE util
} // END NAMESPACE raven
