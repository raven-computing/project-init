${{VAR_COPYRIGHT_HEADER}}

#include <string>
#include <exception>

#include "${{VAR_NAMESPACE_PATH}}/ExampleControllerWS.h"
#include "${{VAR_NAMESPACE_PATH}}/StringProcessor.h"
#include "raven/net/Session.h"
#include "raven/net/Message.h"
#include "raven/util/Log.h"


${{VAR_NAMESPACE_DECL_BEGIN}}
using std::string;
using std::exception;
using raven::net::Session;
using raven::net::Message;
using raven::util::Log;

void ExampleControllerWS::onConnect(Session& session){
    Log::info("ExampleControllerWS: Web socket CONNECTED");
}

void ExampleControllerWS::onDisconnect(Session& session){
    Log::info("ExampleControllerWS: Web socket DISCONNECTED");
}

void ExampleControllerWS::onMessageReceived(
    Session& session, Message& message){

    Log::info("ExampleControllerWS: Web socket MESSAGE received");
    //Get the message payload
    const string& text = message.getText();
    //Create the reverse of the text message
    string reverse = StringProcessor(text).reverse();
    //Send the reverse back to the client
    session.send(reverse);
}

void ExampleControllerWS::onError(Session& session, const exception& ex){
    Log::info("ExampleControllerWS: Web socket ERROR");
}

${{VAR_NAMESPACE_DECL_END}}
