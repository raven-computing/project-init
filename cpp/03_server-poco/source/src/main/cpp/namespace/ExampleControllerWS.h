${{VAR_COPYRIGHT_HEADER}}

#ifndef ${{VAR_NAMESPACE_INCLUDE_GUARD}}_EXAMPLE_CONTROLLLER_WS_H
#define ${{VAR_NAMESPACE_INCLUDE_GUARD}}_EXAMPLE_CONTROLLLER_WS_H

#include <exception>

#include "raven/net/WebSocketController.h"
#include "raven/net/Session.h"
#include "raven/net/Message.h"


${{VAR_NAMESPACE_DECL_BEGIN}}
/**
 * Example controller for handling Web socket connections.
 */
class ExampleControllerWS : public raven::net::WebSocketController {

public:

    virtual void onConnect(raven::net::Session& session);

    virtual void onDisconnect(raven::net::Session& session);

    virtual void onMessageReceived(
        raven::net::Session& session,
        raven::net::Message& message);

    virtual void onError(raven::net::Session& session, const std::exception& ex);

}; // END CLASS ExampleControllerWS

${{VAR_NAMESPACE_DECL_END}}
#endif // ${{VAR_NAMESPACE_INCLUDE_GUARD}}_EXAMPLE_CONTROLLLER_WS_H
