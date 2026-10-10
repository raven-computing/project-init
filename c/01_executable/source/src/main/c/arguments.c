${{VAR_COPYRIGHT_HEADER}}

#include <stddef.h>
#include <string.h>

#include "app.h"

#ifndef APP_VERSION
#define APP_VERSION "unknown"
#endif

AppArgs parseArgs(int argc, char** argv) {
    AppArgs args = {0};
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--verbose") == 0) {
            args.verbose = 1;
        } else if (strcmp(argv[i], "--help") == 0
                || strcmp(argv[i], "-?") == 0) {

            args.help = 1;
        } else if (strcmp(argv[i], "--version") == 0) {
            args.version = 1;
        } else if (strcmp(argv[i], "-#") == 0) {
            args.versionShort = 1;
            args.version = 1;
        }
    }
    return args;
}

void showUsage(void) {
    logI("Usage: ${{VAR_ARTIFACT_BINARY_NAME}} [options]");
}

void showVersion(AppArgs args) {
    if (args.versionShort) {
        logStdout(APP_VERSION);
        logStdout("\n");
        return;
    }
    const char* version = APP_VERSION;
    const char* devHint = "";
    char* hyphen = strrchr(version, '-');
    if (hyphen && !strcmp(hyphen, "-dev")) {
        devHint = " (DEVELOPMENT VERSION)";
    }
    logI("${{VAR_ARTIFACT_BINARY_NAME}} v%s%s", version, devHint);
}

void showHelpText(void) {
    logI("${{VAR_ARTIFACT_BINARY_NAME}}: ${{VAR_PROJECT_DESCRIPTION}}");
    logI(" ");
    showUsage();
    logI(" ");
    logI("Options:");
    logI(" ");
    logI("  [--verbose]    Enable verbose output.");
    logI(" ");
    logI("  [-#|--version] Show program version information.");
    logI(" ");
    logI("  [-?|--help]    Show this help message.");
    logI(" ");
}
