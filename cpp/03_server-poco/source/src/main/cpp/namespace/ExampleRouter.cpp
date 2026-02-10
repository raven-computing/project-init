${{VAR_COPYRIGHT_HEADER}}

#include "${{VAR_NAMESPACE_PATH}}/ExampleRouter.h"
#include "${{VAR_NAMESPACE_PATH}}/ExampleControllerHTTP.h"
#include "${{VAR_NAMESPACE_PATH}}/ExampleControllerWS.h"
#include "raven/util/Log.h"

${{VAR_NAMESPACE_DECL_BEGIN}}
using std::bind;
using std::placeholders::_1;
using std::placeholders::_2;

void ExampleRouter::defineRoutes() {
    staticRoute(
        "/index",
        bind(&ExampleControllerHTTP::index, httpController, _1, _2)
    );

    webSocketRoute(
        "/myws",
        wsController
    );
}

${{VAR_NAMESPACE_DECL_END}}
