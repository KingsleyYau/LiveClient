#include "com_qpidnetwork_tool_CrashHandlerJni.h"

#include <JniGobalFunc.h>

#include <crashhandler/CrashHandler.h>

#include <common/command.h>
#include <common/CommonFunc.h>

/*
 * Class:     com_qpidnetwork_tool_CrashHandlerJni
 * Method:    SetCrashLogDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_tool_CrashHandlerJni_SetCrashLogDirectory
 (JNIEnv *env, jclass cls, jstring jfilePath) {
	string path = JString2String(env, jfilePath);
	MakeDir(path);
	CrashHandler::GetInstance()->SetCrashLogDirectory(path);
}

