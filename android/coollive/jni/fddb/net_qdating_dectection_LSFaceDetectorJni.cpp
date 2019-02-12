#include <net_qdating_dectection_LSFaceDetectorJni.h>

#include <common/KLog.h>

#include <LSFaceDetector.h>

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

JNIEXPORT jlong JNICALL Java_net_qdating_dectection_LSFaceDetectorJni_Create
  (JNIEnv *env, jobject thiz, jobject callback) {
	LSFaceDetector* detector = new LSFaceDetector(callback);

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSFaceDetectorJni::Create( "
			"detector : %p, "
			"callback : %p "
			")",
			detector,
			callback
			);

	return (long long)detector;
}

JNIEXPORT void JNICALL Java_net_qdating_dectection_LSFaceDetectorJni_Destroy
  (JNIEnv *, jobject thiz, jlong jdetector) {
	LSFaceDetector* detector = (LSFaceDetector *)jdetector;

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSFaceDetectorJni::Destroy( "
			"detector : %p "
			")",
			detector
			);

	delete detector;
}

JNIEXPORT void JNICALL Java_net_qdating_dectection_LSFaceDetectorJni_DetectPicture
  (JNIEnv *env, jobject thiz, jlong jdetector, jint width, jint height, jbyteArray dataByteArray) {
    LSFaceDetector* detector = (LSFaceDetector *)jdetector;

    int len = env->GetArrayLength(dataByteArray);
    jbyte* data = env->GetByteArrayElements(dataByteArray, 0);

    detector->FilterPicture(width, height, (const char *)data, len);

}
