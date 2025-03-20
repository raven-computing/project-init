${{VAR_COPYRIGHT_HEADER}}

${{VAR_CPP_HEADER_BEGIN}}

#include "raven/net/RouterHTTP.h"
#include "${{VAR_NAMESPACE_PATH}}/ExampleControllerHTTP.h"
#include "${{VAR_NAMESPACE_PATH}}/ExampleControllerWS.h"


${{VAR_NAMESPACE_DECL_BEGIN}}
/**
 * Example router for routing HTTP requests.
 */
class ExampleRouter : public raven::net::BasicRouterHTTP {

    ExampleControllerHTTP httpController;
    ExampleControllerWS wsController;

public:

    virtual void defineRoutes();

}; // END CLASS ExampleRouter

${{VAR_NAMESPACE_DECL_END}}
${{VAR_CPP_HEADER_END}}
