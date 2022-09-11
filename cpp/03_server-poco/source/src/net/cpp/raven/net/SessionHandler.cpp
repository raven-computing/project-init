/*
 * Copyright (C) 2021 confovis
 *
 * This code is proprietary software. It is not allowed to redistribute it
 * and/or modify it without prior explicit permission by confovis.
 * Unless otherwise explicitly stated by the company and/or its affiliates,
 * this code is for private use only. The usage and generation of copies
 * of this code, in any form, requires formal consent by the creator.
 */

#include <string>
#include <mutex>

#include "Poco/UUID.h"
#include "Poco/UUIDGenerator.h"

#include "raven/net/SessionHandler.h"
#include "raven/net/Session.h"
#include "raven/net/WebSocketSessionProvider.h"
#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"
#include "raven/net/WebSocketHandler.h"
#include "raven/util/Log.h"


namespace raven {
namespace net {

using std::shared_ptr;
using std::make_shared;
using std::string;
using std::lock_guard;
using std::mutex;
using Poco::UUID;
using Poco::UUIDGenerator;
using raven::util::Log;

UUID SessionHandler::createSessionID(){
    return UUIDGenerator::defaultGenerator().createOne();
}

shared_ptr<Session> SessionHandler::createSession(
    RequestHTTP& request,
    ResponseHTTP& response,
    shared_ptr<WebSocketHandler> handler){

    const lock_guard<mutex> lock(_mutex);
    UUID uuid = createSessionID();
    shared_ptr<WebSocketSessionProvider> sp = 
        make_shared<WebSocketSessionProvider>(
            uuid, request, response, handler
        );

    shared_ptr<Session> session = make_shared<Session>(sp);

    string sid = uuid.toString();
    _sessions[sid] = session;
    Log::debug("Session with ID '" + session->getID() + "' created");
    return _sessions[sid];
}

shared_ptr<Session> SessionHandler::getSessionBy(const std::string& sid){
    const lock_guard<mutex> lock(_mutex);
    try{
        return _sessions.at(sid);
    }catch(const std::out_of_range&){
        return nullptr;
    }
}

bool SessionHandler::clear(shared_ptr<Session> session){
    const lock_guard<mutex> lock(_mutex);
    if(session){
        string sid = session->getID();
        if(_sessions.find(sid) == _sessions.end()){
            //Session does not exist in map
            return false;
        }
        _sessions.erase(sid);
        Log::debug("Session with ID '" + sid + "' cleared");
        return true;
    }
    return false;
}

void SessionHandler::stopAllSessions(){
    const lock_guard<mutex> lock(_mutex);
    for(auto item : _sessions){
        item.second->close();
    }
}

} // END NAMESPACE net
} // END NAMESPACE raven
