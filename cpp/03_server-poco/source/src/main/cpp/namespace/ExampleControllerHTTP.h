${{VAR_COPYRIGHT_HEADER}}

${{VAR_CPP_HEADER_BEGIN}}

#include "raven/net/ControllerHTTP.h"
#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"

${{VAR_NAMESPACE_DECL_BEGIN}}
/**
 * Example controller for handling HTTP requests to specific paths.
 */
class ExampleControllerHTTP : public raven::net::ControllerHTTP {

public:

    void index(
        raven::net::RequestHTTP& request,
        raven::net::ResponseHTTP& response
    );

}; // END CLASS ExampleControllerHTTP

${{VAR_NAMESPACE_DECL_END}}
${{VAR_CPP_HEADER_END}}
