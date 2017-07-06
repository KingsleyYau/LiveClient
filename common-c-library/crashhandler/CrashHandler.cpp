/*
 * CrashHandler.h
 *
 *  Created on: 2015-7-6
 *      Author: biostar
 */

#include "CrashHandler.h"
#include <common/command.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

namespace {
static bool filterCallback(void* context) {
	FileLog("crashhandler", "filterCallback()");
	bool bFlag = true;
	CrashHandler* crashHandler = (CrashHandler*)context;
	if( crashHandler != NULL ) {
		bFlag = crashHandler->FilterCallback();
	}
	return bFlag;
}

static bool miniDumpCallback(const google_breakpad::MinidumpDescriptor& descriptor,
                         void* context,
                         bool succeeded) {
	FileLog("crashhandler", "miniDumpCallback( "
			"path : %s"
			" )",
			descriptor.path()
			);

	bool bFlag = succeeded;
	CrashHandler* crashHandler = (CrashHandler*)context;
	if( crashHandler != NULL ) {
		bFlag = crashHandler->MinidumpCallback(descriptor, succeeded);
	}
	return bFlag;
}
}

static CrashHandler* gCrashHandler = NULL;
CrashHandler* CrashHandler::GetInstance() {
	if( gCrashHandler == NULL ) {
		gCrashHandler = new CrashHandler();
	}
	return gCrashHandler;
}

CrashHandler::CrashHandler() {
	GetPhoneInfo();
}

CrashHandler::~CrashHandler() {

}

void CrashHandler::DumpTxtInfo() {
	// print momory leak log
	OutputMemoryLeakInfo(mCrashDirectory.c_str());

	string fileName = eh->minidump_descriptor().path();//descriptor.path();
	string::size_type index = fileName.find_last_of("/", fileName.length() - 1);
	if( index != string::npos ) {
		fileName = fileName.substr(index + 1, fileName.length() - (index + 1));
	}

	FileLog("crashhandler", "DumpTxtInfo( fileName : %s )", fileName.c_str());

	if( fileName.length() > 0 ) {
		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "CPU ABI : %s ", GetPhoneCpuAbi().c_str());
		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "Model : %s ", GetPhoneModel().c_str());
		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "Manufacturer : %s ", GetPhoneManufacturer().c_str());
		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "Brand : %s ", GetPhoneBrand().c_str());
		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "Build Version : %s ", GetPhoneBuildVersion().c_str());
		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "Build SDK Version : %s ", GetPhoneBuildSDKVersion().c_str());
		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "Density DPI : %s ", GetPhoneDensityDPI().c_str());
		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "Local Language : %s ", GetPhoneLocalLanguage().c_str());
		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "Local Region : %s ", GetPhoneLocalRegion().c_str());

		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "User : %s ", mUser.c_str());
		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "Version : %s ", mVersion.c_str());
		KLog::LogToFile(fileName.c_str(), KLog::LOG_OFF, mCrashDirectory.c_str(), "DeviceId : %s ", mDeviceId.c_str());
	}
}

bool CrashHandler::FilterCallback() {
	FileLog("crashhandler", "FilterCallback()");
	DumpTxtInfo();
	return true;
}

bool CrashHandler::MinidumpCallback(const google_breakpad::MinidumpDescriptor& descriptor, bool succeeded) {
	FileLog("crashhandler", "MinidumpCallback()");
	DumpTxtInfo();
	return succeeded;
}

void CrashHandler::SetLogDirectory(string directory) {
	KLog::SetLogDirectory(directory);
	FileLog("crashhandler", "SetLogDirectory ( directory : %s ) ", directory.c_str());
}

void CrashHandler::SetCrashLogDirectory(string directory) {
	FileLog("crashhandler", "SetCrashLogDirectory ( directory : %s ) ", directory.c_str());
	mCrashDirectory = directory;

	google_breakpad::MinidumpDescriptor descriptor(directory);
	if( eh == NULL ) {
		eh = new google_breakpad::ExceptionHandler(descriptor, NULL, miniDumpCallback, this, true, -1);
	} else {
		eh->set_minidump_descriptor(descriptor);
	}
}

void CrashHandler::SetUser(string user) {
	FileLog("crashhandler", "SetUser ( user : %s ) ", user.c_str());
	mUser = user;
}

void CrashHandler::SetVersion(string version) {
	FileLog("crashhandler", "SetVersion ( version : %s ) ", version.c_str());
	mVersion = version;
}

void CrashHandler::SetDeviceId(string deviceId) {
	FileLog("crashhandler", "SetDeviceId ( deviceId : %s ) ", deviceId.c_str());
	mDeviceId = deviceId;
}
