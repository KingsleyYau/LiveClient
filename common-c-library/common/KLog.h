/*
 * KLog.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef _INC_KLOG_
#define _INC_KLOG_

#include <string>
using namespace std;

#ifdef LINUX /* Linux */
#include <common/filelog/LogManager.h>
#endif

class KLog
{
public:
	typedef enum _tagLogLevel {
		LOG_OFF = 0,
		LOG_ERR_SYS,
		LOG_ERR_USER,
		LOG_WARNING,
		LOG_MSG,
		LOG_STAT
	} LogLevel;

public:
	static int LogToFile(const char *fileNamePre, LogLevel level, const char *logDir, const char *fmt, ...);

	static void SetLogLevel(LogLevel level);
	static void SetLogDirectory(string directory);
	static void SetLogEnable(bool enable);
};

#if	defined(FILE_JNI_LOG) || defined(PRINT_JNI_LOG) /* file */
	#ifdef LINUX /* Linux */
		#define FileLog(fileNamePre, format, ...) FileLevelLog(fileNamePre, KLog::LOG_STAT, format, ## __VA_ARGS__)
		#define FileLevelLog(fileNamePre, level, format, ...) LogManager::GetLogManager()->Log(level, format, ## __VA_ARGS__)

	#else
		#define FileLog(fileNamePre, format, ...) FileLevelLog(fileNamePre, KLog::LOG_STAT, format,  ## __VA_ARGS__)
		#define FileLevelLog(fileNamePre, level, format, ...) KLog::LogToFile(fileNamePre, level, NULL, format,  ## __VA_ARGS__)
	#endif
#else /* no log */
	#define FileLog(fileNamePre, format, ...)
	#define FileLevelLog(fileNamePre, level, format, ...)

	#define ELog FileLog
	#define WLog FileLog
	#define ILog FileLog
	#define DLog FileLog
#endif /* PRINT_JNI_LOG */

// add by samson，把定义放到头文件，给外部知道
#define MAX_LOG_BUFFER 200 * 1024

#endif
