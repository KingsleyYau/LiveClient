/*
 * LogManager.h
 *
 *  Created on: 2015-1-13
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LOGMANAGER_H_
#define LOGMANAGER_H_

#include <common/KMutex.h>
#include <common/KThread.h>

#include <filelog/LogFile.hpp>

#include <string>
using namespace std;

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <sys/syscall.h>

#define DiffGetTickCount(start, end)    ((start) <= (end) ? (end) - (start) : ((unsigned int)(-1)) - (start) + (end))

class LogRunnable;
class LogManager {
public:

	static LogManager *GetLogManager();

	LogManager();
	virtual ~LogManager();

	bool Start(LOG_LEVEL nLevel = LOG_STAT, const string& dir = "log");
	bool Stop();
	bool IsRunning();
	bool Log(LOG_LEVEL nLevel, const char *format, ...);
	int MkDir(const char* pDir);
	void SetLogLevel(LOG_LEVEL nLevel = LOG_STAT);

	void LogSetFlushBuffer(unsigned int iLen);
	void LogFlushMem2File();
	void SetDebugMode(bool debugMode);

private:
	KThread mLogThread;
	LogRunnable *mpLogRunnable;
	bool mIsRunning;

	string mLogDir;

	KMutex mMutex;
	CFileCtrl *mpFileCtrl;
	LOG_LEVEL mLogLevel;

	CFileCtrl *mpFileCtrlDebug;
	bool mDebugMode;
};

#endif /* LOGMANAGER_H_ */
