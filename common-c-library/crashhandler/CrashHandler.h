/*
 * CrashHandler.h
 *
 *  Created on: 2015-7-6
 *      Author: biostar
 */

#ifndef CRASHHANDLER_H_
#define CRASHHANDLER_H_

#include <string>
using namespace std;

#include <client/linux/handler/minidump_descriptor.h>
#include <client/linux/handler/exception_handler.h>
using namespace google_breakpad;

class CrashHandler {
public:
	CrashHandler();
	virtual ~CrashHandler();

	static CrashHandler* GetInstance();

	void SetLogDirectory(string directory);

	void SetCrashLogDirectory(string directory);

	void SetUser(string user);

	void SetVersion(string version);

	void SetDeviceId(string deviceId);

	void DumpTxtInfo();
	bool FilterCallback();
	bool MinidumpCallback(const google_breakpad::MinidumpDescriptor& descriptor, bool succeeded);

private:
	string mUser = "";
	string mVersion = "";
	string mDeviceId = "";
	string mCrashDirectory = "";
	ExceptionHandler *eh = NULL;
};

#endif /* CRASHHANDLER_H_ */
