#include <net_qdating_utils_LSUtilTesterJni.h>

#include <AndroidCommon/JniCommonFunc.h>

#include <common/KLog.h>

#include "HttpTester.h"

using namespace coollive;
JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
	gJavaVM = vm;

	// Get JNI
	JNIEnv* env;
	if (JNI_OK != vm->GetEnv(reinterpret_cast<void**> (&env),
                           JNI_VERSION_1_4)) {
		FileLevelLog("rtmpdump", KLog::LOG_ERR_SYS, "JNI_OnLoad( Could not get JNI env )");
		return -1;
	}

	KLog::SetLogLevel(KLog::LOG_MSG);

	return JNI_VERSION_1_4;
}

JNIEXPORT void JNICALL Java_net_qdating_utils_LSUtilTesterJni_Test
  (JNIEnv *env, jobject obj) {
    HttpTester tester;
    tester.Test();
  }