/*
 * DrLog.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef _INC_DRLOG_
#define _INC_DRLOG_

#include <string>
using namespace std;

class KLog
{
public:
	typedef enum _tagLogLevel {
		NO_LOG = 0,
		ERR_LOG = 1,
		WARN_LOG = 2,
		INFO_LOG = 3,
		DEBUG_LOG = 4
	} LogLevel;

public:
	static int LogToFile(const char *fileNamePre, LogLevel level, const char *logDir, const char *fmt, ...);

	static void SetLogLevel(LogLevel level);
	static void SetLogDirectory(string directory);
	static void SetLogEnable(bool enable);
};

#if	defined(FILE_JNI_LOG) || defined(PRINT_JNI_LOG) /* file */
	#define FileLog(fileNamePre, format, ...) KLog::LogToFile(fileNamePre, KLog::DEBUG_LOG, NULL, format,  ## __VA_ARGS__)

	#define ELog(tag, format, ...) KLog::LogToFile(tag, KLog::ERR_LOG, NULL, format,  ## __VA_ARGS__)
	#define WLog(tag, format, ...) KLog::LogToFile(tag, KLog::WARN_LOG, NULL, format,  ## __VA_ARGS__)
	#define ILog(tag, format, ...) KLog::LogToFile(tag, KLog::INFO_LOG, NULL, format,  ## __VA_ARGS__)
	#define DLog(tag, format, ...) KLog::LogToFile(tag, KLog::DEBUG_LOG, NULL, format,  ## __VA_ARGS__)
#else /* no log */
	#define FileLog(fileNamePre, format, ...)

	#define ELog FileLog
	#define WLog FileLog
	#define ILog FileLog
	#define DLog FileLog
#endif /* PRINT_JNI_LOG */

// add by samson，把定义放到头文件，给外部知道
#define MAX_LOG_BUFFER 200 * 1024

#endif
