/*
 * DrLog.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */
#include "KLog.h"

#ifdef _WIN32  /* _WIN32 */
	#include <windows.h>
#else
	#include <dirent.h>
	#include <sys/stat.h>
	#include <sys/syscall.h>
    #include <unistd.h>
	#ifdef IOS  /* IOS */
		#include <sys/time.h>
		#define GET_TID SYS_gettid
		#define Log(tag, format, ...) printf(format, ## __VA_ARGS__)
	#else  /* Android */
		#include <android/log.h>
		#define Log(tag, format, ...) __android_log_print(ANDROID_LOG_DEBUG, tag, format, ## __VA_ARGS__)
 		#define GET_TID __NR_gettid
	#endif  /* IOS */
#endif  /* _WIN32 */

static bool gLogEnable = true;
void KLog::SetLogEnable(bool enable) {
	gLogEnable = enable;
}

static string gLogDirectory = "/";
void KLog::SetLogDirectory(string directory) {
	gLogDirectory = directory;
}

static KLog::LogLevel gLogLevel = KLog::DEBUG_LOG;
void KLog::SetLogLevel(KLog::LogLevel level)
{
    gLogLevel = level;
}

#ifndef _WIN32
int KLog::LogToFile(const char *fileNamePre, KLog::LogLevel level, const char *logDir, const char *fmt, ...)
{
	if( !gLogEnable ) {
		return 0;
	}
    
    if ( level > gLogLevel ) {
        return 0;
    }

	char pTimeBuffer[1024] = {'\0'}, pDataBuffer[MAX_LOG_BUFFER] = {'\0'};

	timeval tNow;
	gettimeofday(&tNow, NULL);
	time_t stm = time(NULL);
	struct tm tTime;
	localtime_r(&stm, &tTime);
	int tid = (int)syscall(GET_TID);
	snprintf(pTimeBuffer, 64, "[ tid: %d, %d-%02d-%02d %02d:%02d:%02d.%03d ]",
			tid, tTime.tm_year + 1900, tTime.tm_mon + 1, tTime.tm_mday, tTime.tm_hour, tTime.tm_min, tTime.tm_sec, tNow.tv_usec/1000);

    va_list	agList;
    va_start(agList, fmt);
    vsnprintf(pDataBuffer, sizeof(pDataBuffer)-1, fmt, agList);
    va_end(agList);

    strcat(pDataBuffer, "\n");

#ifdef PRINT_JNI_LOG
	Log(fileNamePre, "%s%s", pTimeBuffer, pDataBuffer);
#endif  /* PRINT_JNI_LOG */

#ifdef FILE_JNI_LOG
    string sLogFileDir = gLogDirectory;
    if( logDir != NULL ) {
        sLogFileDir = logDir;
    }
    string sLogFileName = fileNamePre;
    
    DIR* dir = opendir(sLogFileDir.c_str());
    if (dir == NULL) {
        int mod = S_IRWXU | S_IRWXG | S_IRWXO;
        if( 0 == mkdir(sLogFileDir.c_str(), mod) ) {
            
        }
    } else {
        closedir(dir);
    }
    char pLogFilePath[1024] = {'\0'};
    
    snprintf(pLogFilePath, sizeof(pLogFilePath), "%s/%s-%d-%02d-%02d.log", \
    		sLogFileDir.c_str(), sLogFileName.c_str(), tTime.tm_year + 1900, tTime.tm_mon + 1, \
    		tTime.tm_mday/*, tTime.tm_hour, tTime.tm_min, tTime.tm_sec*/);

    FILE* file = fopen(pLogFilePath, "a+b");
    if(file != NULL) {

    	int iLen = -1;
    	fseek(file, 0L, SEEK_END);

    	if(strlen(pTimeBuffer) > 0) {
    		iLen = fwrite(pTimeBuffer, 1, strlen(pTimeBuffer), file);
    		if(iLen != -1 ) {

    		}
    	}
    	if(strlen(pDataBuffer) > 0) {
    		iLen = fwrite(pDataBuffer, 1, strlen(pDataBuffer), file);
    		if(iLen != -1 ) {

    		}
    	}
    	fclose(file);
    }
#endif  /* FILE_JNI_LOG */

	return 1;
}
#else

int KLog::LogToFile(const char *fileNamePre, KLog::LogLevel level, const char *logDir, const char *fmt, ...) 
{
	if( !gLogEnable ) {
		return 0;
	}

	char pTimeBuffer[1024] = {'\0'}, pDataBuffer[MAX_LOG_BUFFER] = {'\0'};

    SYSTEMTIME wtm;
	GetLocalTime(&wtm);
	DWORD tid = GetCurrentThreadId();
	sprintf_s(pTimeBuffer, sizeof(pTimeBuffer), "[ tid: %d, %d-%02d-%02d %02d:%02d:%02d.%03d ]",
		tid, wtm.wYear, wtm.wMonth, wtm.wDay, wtm.wHour, wtm.wMinute, wtm.wSecond, wtm.wMilliseconds);

    va_list	agList;
    va_start(agList, fmt);
    vsnprintf(pDataBuffer, sizeof(pDataBuffer)-1, fmt, agList);
    va_end(agList);

    strcat(pDataBuffer, "\n");

	// set color
	HANDLE hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
	CONSOLE_SCREEN_BUFFER_INFO csbi;
	GetConsoleScreenBufferInfo(hStdOut, &csbi);
	WORD color = csbi.wAttributes;
	switch(level) {
		case INFO_LOG:
			color = FOREGROUND_GREEN;
			break;
		case WARN_LOG:
			color = FOREGROUND_INTENSITY|BACKGROUND_BLUE;
			break;
		case ERR_LOG:
			color = FOREGROUND_INTENSITY|BACKGROUND_RED;
			break;
	}
	SetConsoleTextAttribute(hStdOut, color);

	printf("%s %s", pTimeBuffer, pDataBuffer);
	SetConsoleTextAttribute(hStdOut, csbi.wAttributes);

	return 1;
}
#endif
