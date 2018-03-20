#include <net_qdating_filter_LSImageUtilJni.h>

#include <GLES2/gl2.h>
//#include <GLES3/gl3.h>

JNIEXPORT void JNICALL Java_net_qdating_filter_LSImageUtilJni_GLReadPixels
  (JNIEnv *env, jclass cls, jint x, jint y, jint width, jint height, jint format, jint type) {
	glReadPixels(x, y, width, height, format, type, NULL);
 }
