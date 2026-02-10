${{VAR_COPYRIGHT_HEADER}}

#include "${{VAR_NAMESPACE_PATH}}/ExampleControllerHTTP.h"
#include "raven/net/RequestHTTP.h"
#include "raven/net/ResponseHTTP.h"
#include "raven/util/Log.h"

${{VAR_NAMESPACE_DECL_BEGIN}}
using raven::net::RequestHTTP;
using raven::net::ResponseHTTP;
using raven::util::Log;

void ExampleControllerHTTP::index(
    RequestHTTP& request,
    ResponseHTTP& response
) {
    Log::info("ExampleControllerHTTP: Request received to index()");
    response.body("${{VAR_PROJECT_SLOGAN_STRING}}");
}

${{VAR_NAMESPACE_DECL_END}}
