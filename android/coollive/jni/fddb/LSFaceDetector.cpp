/*
 * LSFaceDetector.cpp
 *
 *  Created on: 2019年1月30日
 *      Author: max
 */

#include "LSFaceDetector.h"

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/objdetect/objdetect.hpp>

#include <opencv2/opencv.hpp>
#include <dlib/opencv.h>

#include <common/KLog.h>

#include <sstream>
#include <string>

using namespace std;
using namespace cv;
using namespace dlib;

namespace coollive {

LSFaceDetector::LSFaceDetector(jobject jniCallback) {
	// TODO Auto-generated constructor stub
	detector = get_frontal_face_detector();

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	mJniCallback = NULL;
	if( jniCallback ) {
		mJniCallback = env->NewGlobalRef(jniCallback);

		jclass jniCallbackCls = env->GetObjectClass(mJniCallback);
		// 反射方法
		string signure = "(IIII)V";
		jmethodID jMethodID = env->GetMethodID(
				jniCallbackCls,
				"onDetectedFace",
				signure.c_str()
				);
		mJniOnDetectedFaceMethodID = jMethodID;
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

LSFaceDetector::~LSFaceDetector() {
	// TODO Auto-generated destructor stub

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	if( mJniCallback ) {
		env->DeleteGlobalRef(mJniCallback);
		mJniCallback = NULL;
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void LSFaceDetector::FilterPicture(int width, int height, const char *data, int len) {
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "LSFaceDetector::FilterPicture( "
    		"width : %d, "
    		"height : %d, "
    		"len : %d "
    		")",
    		width,
    		height,
    		len
    		);

    cv::Mat imgCV(cv::Size(width, height), CV_8UC4, (void *)data);
    cv::Mat imgGrayCV;
    cvtColor(imgCV, imgGrayCV, COLOR_BGR2GRAY);
    equalizeHist(imgGrayCV, imgGrayCV);

    dlib::cv_image<unsigned char> imgDLibRgb(imgGrayCV);
    dlib::array2d<unsigned char> img;
    assign_image(img, imgDLibRgb);

    if( img.size() > 0 ) {
    	std::vector<dlib::rectangle> faces = detector(img);

        // 播放视频
        JNIEnv* env;
        bool isAttachThread;
        bool bFlag = GetEnv(&env, &isAttachThread);
        dlib::rectangle face;

        if( faces.size() > 0 ) {
            FileLevelLog("rtmpdump", KLog::LOG_MSG, "LSFaceDetector::FilterPicture( [Face Dectected], %d )", faces.size());

            for(int i = 0; i < faces.size(); i++) {
                FileLevelLog("rtmpdump", KLog::LOG_MSG,
                		"LSFaceDetector::FilterPicture( [Face %d], x : %d, y : %d, width : %d, height : %d )",
						i, faces[i].left(), faces[i].top(), faces[i].width(), faces[i].height()
						);
                face = faces[i];
                break;
            }
        }

        // 回调图像
        if( mJniCallback != NULL ) {
            // 回调
            if( mJniOnDetectedFaceMethodID ) {
                env->CallVoidMethod(mJniCallback, mJniOnDetectedFaceMethodID, face.left(), face.top(), face.width(), face.height());
            }
        }

        if( bFlag ) {
            ReleaseEnv(isAttachThread);
        }
    }

    FileLevelLog("rtmpdump", KLog::LOG_STAT, "LSFaceDetector::FilterPicture( [Finish] )");
}

} /* namespace coollive */
