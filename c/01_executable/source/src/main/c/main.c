${{VAR_COPYRIGHT_HEADER}}

#include <stdio.h>

#include "app.h"

int main(int argc, char** argv) {
    AppArgs args = parseArgs(argc, argv);
    initLogging(
        stdout,
        stderr,
        args.verbose ? LOG_LEVEL_VERBOSE : LOG_LEVEL_INFO
    );
    if (args.help) {
        showHelpText();
        return APP_EXIT_SUCCESS;
    }
    if (args.version) {
        showVersion(args);
        return APP_EXIT_SUCCESS;
    }
    if (args.indexUnknown) {
        logE("Unknown option: '%s'", argv[args.indexUnknown]);
        return APP_EXIT_INVALID_ARGUMENT;
    }
    ExitStatus status = printText();
    if (LOG_IO_ERROR_DETECTED) {
        status = APP_EXIT_PROG_IO_ERROR;
    }
    return status;
}
