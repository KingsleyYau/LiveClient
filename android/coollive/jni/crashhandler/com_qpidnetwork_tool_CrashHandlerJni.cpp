#include "com_qpidnetwork_tool_CrashHandlerJni.h"

#include <crashhandler/CrashHandler.h>

#include <common/command.h>
#include <common/CommonFunc.h>
#include <common/KLog.h>

#include <AndroidCommon/JniCommonFunc.h>

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
	FileLog("crashhandler", "JNI_OnLoad( crashhandler )");
	gJavaVM = vm;

	// Get JNI
	JNIEnv* env;
	if (JNI_OK != vm->GetEnv(reinterpret_cast<void**> (&env),
                           JNI_VERSION_1_4)) {
		FileLevelLog("crashhandler", KLog::LOG_ERR_SYS, "JNI_OnLoad( Could not get JNI env )");
		return -1;
	}

	return JNI_VERSION_1_4;
}

JNIEXPORT void JNICALL Java_com_qpidnetwork_tool_CrashHandlerJni_SetCrashLogDirectory
 (JNIEnv *env, jclass cls, jstring jfilePath) {
	string path = JString2String(env, jfilePath);
	MakeDir(path);
	CrashHandler::GetInstance()->SetCrashLogDirectory(path);
}

