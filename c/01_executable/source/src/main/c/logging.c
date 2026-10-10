${{VAR_COPYRIGHT_HEADER}}

#include <stdio.h>
#include <stdarg.h>

#ifdef _WIN32
#include <windows.h>
#endif

#include "app.h"

LogLevel LOG_LEVEL = LOG_LEVEL_DISABLED;

FILE* LOG_STREAM_OUT = NULL;
FILE* LOG_STREAM_ERR = NULL;
int LOG_IO_ERROR_DETECTED = 0;

void initLogging(FILE* out, FILE* err, LogLevel level) {
    LOG_STREAM_OUT = out;
    LOG_STREAM_ERR = err;
    LOG_LEVEL = level;

#ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
#endif
}

void logStdout(const char* text) {
    if (LOG_LEVEL == LOG_LEVEL_DISABLED) {
        return;
    }
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || printf("%s", text) < 0
    );
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || fflush(stdout) != 0
    );
}

void logE(const char* format, ...) {
    if (LOG_LEVEL < LOG_LEVEL_ERROR || LOG_STREAM_ERR == NULL) {
        return;
    }
    va_list args;
    va_start(args, format);
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || vfprintf(LOG_STREAM_ERR, format, args) < 0
    );
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || fprintf(LOG_STREAM_ERR, "\n") < 0
    );
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || fflush(LOG_STREAM_ERR) != 0
    );
    va_end(args);
}

void logW(const char* format, ...) {
    if (LOG_LEVEL < LOG_LEVEL_WARNING || LOG_STREAM_OUT == NULL) {
        return;
    }
    va_list args;
    va_start(args, format);
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || fprintf(LOG_STREAM_OUT, "Warning: ") < 0
    );
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || vfprintf(LOG_STREAM_OUT, format, args) < 0
    );
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || fprintf(LOG_STREAM_OUT, "\n") < 0
    );
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || fflush(LOG_STREAM_OUT) != 0
    );
    va_end(args);
}

void logI(const char* format, ...) {
    if (LOG_LEVEL < LOG_LEVEL_INFO || LOG_STREAM_OUT == NULL) {
        return;
    }
    va_list args;
    va_start(args, format);
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || vfprintf(LOG_STREAM_OUT, format, args) < 0
    );
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || fprintf(LOG_STREAM_OUT, "\n") < 0
    );
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || fflush(LOG_STREAM_OUT) != 0
    );
    va_end(args);
}

void logV(const char* format, ...) {
    if (LOG_LEVEL < LOG_LEVEL_VERBOSE || LOG_STREAM_OUT == NULL) {
        return;
    }
    va_list args;
    va_start(args, format);
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || vfprintf(LOG_STREAM_OUT, format, args) < 0
    );
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || fprintf(LOG_STREAM_OUT, "\n") < 0
    );
    LOG_IO_ERROR_DETECTED = (
        LOG_IO_ERROR_DETECTED || fflush(LOG_STREAM_OUT) != 0
    );
    va_end(args);
}
