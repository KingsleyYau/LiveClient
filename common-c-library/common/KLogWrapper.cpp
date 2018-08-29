/*
 * DrLog.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */
#include "KLogWrapper.h"
#include "KLog.h"
#define PRINTLOG(fileNamePre, format, ...)  FileLevelLog(fileNamePre, KLog::LOG_WARNING, format,  ## __VA_ARGS__)
#ifdef __cplusplus
extern "C" {

#endif
void PrintLog(const char* func, const char *fmt, ...) {
    char pDataBuffer[MAX_LOG_BUFFER] = {'\0'};

    snprintf(pDataBuffer, 50, "%-20s", func);
    int len = strlen(pDataBuffer);
    char *temp = pDataBuffer + len;
    va_list    agList;
    va_start(agList, fmt);
    vsnprintf(temp, sizeof(pDataBuffer) -len - 1, fmt, agList);
    va_end(agList);

    strcat(pDataBuffer, "\n");
    PRINTLOG("ImClient", pDataBuffer);
}
#ifdef __cplusplus
};
#endif
