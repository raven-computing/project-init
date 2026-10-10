${{VAR_COPYRIGHT_HEADER}}

${{VAR_C_HEADER_BEGIN}}

#include <stddef.h>
#include <stdio.h>

#if defined(__clang__)
#define ATTR_LOG_FORMAT __attribute__((format(printf, 1, 2)))
#elif defined(__GNUC__)
#define ATTR_LOG_FORMAT __attribute__((format(gnu_printf, 1, 2)))
#else
#define ATTR_LOG_FORMAT
#endif

/**
 * Enumeration of all exit status codes of scount.
 */
typedef enum ExitStatus {
    APP_EXIT_SUCCESS = 0,
    APP_EXIT_FAILURE = 1,
    APP_EXIT_INVALID_ARGUMENT = 2,
    APP_EXIT_PROG_IO_ERROR = 3,
} ExitStatus;

/**
 * Structure holding all parsed application arguments.
 */
typedef struct AppArgs {
    char* errorMessage; // Error message in case of invalid input
    int indexUnknown;   // Index into `argv` when unknown arg found, or zero
    int verbose;        // Option: `--verbose`
    int version;        // Option: `-#|--version`
    int versionShort;   // Option: `-#`
    int help;           // Option: `-?`|`--help`
} AppArgs;

/**
 * Enumeration of all log levels.
 */
typedef enum LogLevel {
    LOG_LEVEL_DISABLED,
    LOG_LEVEL_ERROR,
    LOG_LEVEL_WARNING,
    LOG_LEVEL_INFO,
    LOG_LEVEL_VERBOSE,
} LogLevel;

/**
 * Current log level for the application.
 */
extern LogLevel LOG_LEVEL;

/**
 * Output stream for non-error message logging.
 */
extern FILE* LOG_STREAM_OUT;

/**
 * Output stream for error message logging.
 */
extern FILE* LOG_STREAM_ERR;

/**
 * Whether an error was detected during logging.
 */
extern int LOG_IO_ERROR_DETECTED;

/**
 * Parses command line arguments.
 *
 * @param argc The argument count given to the application.
 * @param argv The argument vector given to the application.
 * @return An `AppArgs` struct containing the parsed arguments.
 */
AppArgs parseArgs(int argc, char** argv);

/**
 * Initializes the logging system to use the given streams and log level.
 *
 * @param out The output stream for non-error messages.
 * @param err The output stream for error messages.
 * @param level The initial log level.
 */
void initLogging(FILE* out, FILE* err, LogLevel level);

/**
 * Displays usage information for the application on stdout.
 */
void showUsage(void);

/**
 * Displays version information for the application on stdout.
 */
void showVersion(AppArgs args);

/**
 * Displays help text for the application on stdout.
 */
void showHelpText(void);

/**
 * Gets the number 42.
 *
 * @return The number 42 as an int.
 */
int getFortyTwo(void);

/**
 * Prints a text string to stdout.
 */
ExitStatus printText(void);

/**
 * Logs a message to stdout.
 * The string is not further formatted and dumped to stdout as is.
 *
 * @param text The string to log.
 */
void logStdout(const char* text);

/**
 * Logs a formatted message with ERROR level.
 *
 * @param format The format string.
 * @param ... The values to format.
 */
void logE(const char* format, ...) ATTR_LOG_FORMAT;

/**
 * Logs a formatted message with WARNING level.
 *
 * @param format The format string.
 * @param ... The values to format.
 */
void logW(const char* format, ...) ATTR_LOG_FORMAT;

/**
 * Logs a formatted message with INFO level.
 *
 * @param format The format string.
 * @param ... The values to format.
 */
void logI(const char* format, ...) ATTR_LOG_FORMAT;

/**
 * Logs a formatted message with VERBOSE level.
 *
 * @param format The format string.
 * @param ... The values to format.
 */
void logV(const char* format, ...) ATTR_LOG_FORMAT;

${{VAR_C_HEADER_END}}
