${{VAR_COPYRIGHT_HEADER}}

${{VAR_CPP_HEADER_BEGIN}}

#include <memory>

#include "raven/net/ServerTCP.h"
#include "raven/net/RouterHTTP.h"

${{VAR_NAMESPACE_DECL_BEGIN}}
/**
 * Example TCP server usage.
 */
class Server: public raven::net::ServerTCP {

public:

    Server(const unsigned short port);

    virtual std::shared_ptr<raven::net::RouterHTTP> router();

    virtual void onStartRequested();

    virtual void onStart();

    virtual void onStopRequested();

    virtual void onStop();

}; // END CLASS Server

${{VAR_NAMESPACE_DECL_END}}
${{VAR_CPP_HEADER_END}}
