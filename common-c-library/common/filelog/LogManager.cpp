/*
 * LogManager.cpp
 *
 *  Created on: 2015-1-13
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LogManager.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <string.h>

#include <common/Buffer.h>

#define MAX_LOG_BUFFER_LEN 8192

/* log thread */
class LogRunnable : public KRunnable {
public:
	LogRunnable(LogManager *container) {
		mContainer = container;
	}
	virtual ~LogRunnable() {
		mContainer = NULL;
	}
protected:
	void onRun() {
		int iCount = 0;
		while( mContainer->IsRunning() ) {
			if ( iCount < 5 ) {
				iCount++;
			} else {
				iCount = 0;
				mContainer->LogFlushMem2File();
			}
			sleep(1);
		}
	}

private:
	LogManager *mContainer;
};

static LogManager *gLogManager = NULL;
LogManager *LogManager::GetLogManager() {
	if( gLogManager == NULL ) {
		gLogManager = new LogManager();
	}
	return gLogManager;
}

LogManager::LogManager() {
	// TODO Auto-generated constructor stub
	mIsRunning = false;
	mpFileCtrl = NULL;
	mLogLevel = 5;
	mpFileCtrlDebug = NULL;
	mDebugMode = false;
	mpLogRunnable = new LogRunnable(this);
}

LogManager::~LogManager() {
	// TODO Auto-generated destructor stub
	Stop();
	if( mpLogRunnable ) {
		delete mpLogRunnable;
	}
}

bool LogManager::Log(LOG_LEVEL nLevel, const char *format, ...) {
	bool bFlag = false;
	if( !mIsRunning ) {
		return false;
	}

	mMutex.lock();

	bool bNeedLog = false;
	if( mDebugMode ) {
		bNeedLog = true;
	} else if( mLogLevel >= nLevel ) {
		bNeedLog = true;
	}

    if( bNeedLog ) {
        char logBuffer[MAX_LOG_BUFFER_LEN];
		char bitBuffer[64];

	    //get current time
	    time_t stm = time(NULL);
        struct tm tTime;
        localtime_r(&stm,&tTime);
        snprintf(bitBuffer, 64, "[ %d-%02d-%02d %02d:%02d:%02d tid:%-6d ] ",
        		tTime.tm_year+1900, tTime.tm_mon+1, tTime.tm_mday, tTime.tm_hour, tTime.tm_min, tTime.tm_sec,
				(int)syscall(SYS_gettid)
				);

        //get va_list
        va_list	agList;
        va_start(agList, format);
        vsnprintf(logBuffer, MAX_LOG_BUFFER_LEN - 1, format, agList);
        va_end(agList);

        strcat(logBuffer, "\n");

        if( mLogLevel >= nLevel ) {
        	mpFileCtrl->LogMsg(logBuffer, (int)strlen(logBuffer), bitBuffer);
        }

        if( mDebugMode ) {
        	mpFileCtrlDebug->LogMsg(logBuffer, (int)strlen(logBuffer), bitBuffer);
        }

        bFlag = true;
    }

    mMutex.unlock();

	return bFlag;
}

bool LogManager::Start(LOG_LEVEL nLevel, const string& dir) {
	if( mIsRunning ) {
		return false;
	}

	printf("# LogManager starting... \n");

	mLogLevel = nLevel;
    mLogDir = dir;

	// Nornal Log Config
    string infoLogDir = mLogDir + "/info";
    MkDir(infoLogDir.c_str());
    mpFileCtrl = new CFileCtrl();
    if( !mpFileCtrl ) {
        return false;
    }
    mpFileCtrl->Initialize(infoLogDir.c_str(), "Log", 30);
    mpFileCtrl->OpenLogFile();

    // Debug Log Config
    string debugLogDir = mLogDir + "/debug";
    MkDir(debugLogDir.c_str());
    mpFileCtrlDebug = new CFileCtrl();
    if( !mpFileCtrlDebug ) {
        return false;
    }
    mpFileCtrlDebug->Initialize(debugLogDir.c_str(), "Log", 30);
    mpFileCtrlDebug->OpenLogFile();

    mIsRunning = true;

	/* start log thread */
	if( mLogThread.Start(mpLogRunnable) != 0 ) {

	}

	printf("# LogManager start OK. \n");
	return true;
}

bool LogManager::Stop() {
	if( mIsRunning ) {
		mIsRunning = false;
	} else {
		return false;
	}

	printf("# LogManager stopping... \n");

	/* stop log thread */
	mLogThread.Stop();

	if( mpFileCtrl ) {
		delete mpFileCtrl;
		mpFileCtrl = NULL;
	}

	if( mpFileCtrlDebug ) {
		delete mpFileCtrlDebug;
		mpFileCtrlDebug = NULL;
	}

	printf("# LogManager stop OK. \n");

	return true;
}

bool LogManager::IsRunning() {
	return mIsRunning;
}

int LogManager::MkDir(const char* pDir) {
    int ret = 0;
    struct stat dirBuf;
    char cDir[BUFFER_SIZE_1K] = {0};
    char cTempDir[BUFFER_SIZE_1K] = {0};

    strcpy(cDir, pDir);
    if (pDir[strlen(pDir)-1] != '/') {
        cDir[strlen(pDir)] = '/';
    }
    int iLen = strlen(cDir);
    for (int i = 0; i < iLen; i++) {
        if ('/' == cDir[i]) {
            if (0 == i) {
                strncpy(cTempDir, cDir, i+1);
                cTempDir[i+1] = '\0';
            } else {
                strncpy(cTempDir, cDir, i);
                cTempDir[i] = '\0';
            }
            ret = stat(cTempDir, &dirBuf);
            if (-1 == ret &&  ENOENT == errno) {
                ret = mkdir(cTempDir, S_IRWXU | S_IRWXG | S_IRWXO);
                if (-1 == ret) {
                    return 0;
                }
                chmod(cTempDir, S_IRWXU | S_IRWXG | S_IRWXO);
            } else if (-1 == ret) {
                return 0;
            }
            if (!(S_IFDIR & dirBuf.st_mode)) {
                return 0;
            }
        }
    }
    return 1;
}

void LogManager::SetLogLevel(LOG_LEVEL nLevel) {
	mLogLevel = nLevel;
}

void LogManager::LogSetFlushBuffer(unsigned int iLen) {
	if( mIsRunning ) {
		mpFileCtrl->SetFlushBuffer(iLen);
		if( mDebugMode ) {
			mpFileCtrlDebug->SetFlushBuffer(iLen);
		}
	}
}

void LogManager::LogFlushMem2File() {
	if( mIsRunning ) {
		mpFileCtrl->FlushMem2File();
		if( mDebugMode ) {
			mpFileCtrlDebug->FlushMem2File();
		}
	}
}

void LogManager::SetDebugMode(bool debugMode) {
	mDebugMode = debugMode;
}
