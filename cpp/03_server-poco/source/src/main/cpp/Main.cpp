${{VAR_COPYRIGHT_HEADER}}

#include "${{VAR_NAMESPACE_PATH}}/Server.h"

using ${{VAR_NAMESPACE_COLON}}::Server;

int main(int argc, char** argv) {

    const unsigned short port = 8080;
    Server server(port);

    return server.run(argc, argv);
}
