#include "com_qpidnetwork_livemodule_utils_CrashHandlerJni.h"

#include <crashhandler/CrashHandler.h>
#include <common/command.h>

/*
 * Class:     com_qpidnetwork_utils_CrashHandlerJni
 * Method:    SetCrashLogDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_utils_CrashHandlerJni_SetCrashLogDirectory
  (JNIEnv *env, jclass cls, jstring directory){
    string strDirectory("");
    if (directory != NULL) {
	    const char *cpDirectory = env->GetStringUTFChars(directory, 0);
	    strDirectory = cpDirectory;
	    env->ReleaseStringUTFChars(directory, cpDirectory);
	}
	CrashHandler::GetInstance()->SetCrashLogDirectory(strDirectory);

}
