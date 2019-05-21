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

#include <iostream>
#include <sstream>
#include <string>

using namespace std;
using namespace cv;
using namespace dlib;

namespace coollive {

LSFaceDetector::LSFaceDetector(jobject jniCallback) {
	// TODO Auto-generated constructor stub
	detector = get_frontal_face_detector();
    //deserialize("/sdcard/input/shape_predictor_68_face_landmarks.dat") >> sp;

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	mJniCallback = NULL;
	if( jniCallback ) {
		mJniCallback = env->NewGlobalRef(jniCallback);

		jclass jniCallbackCls = env->GetObjectClass(mJniCallback);
		// 反射方法
		string signure = "([BIIIII)V";
		jmethodID jMethodID = env->GetMethodID(
				jniCallbackCls,
				"onDetectedFace",
				signure.c_str()
				);
		mJniOnDetectedFaceMethodID = jMethodID;
	}

	dataByteArray = NULL;

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

	if( dataByteArray != NULL ) {
		env->DeleteGlobalRef(dataByteArray);
		dataByteArray = NULL;
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void LSFaceDetector::DetectFaces(const char *data, int size, int width, int height) {
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "LSFaceDetector::DetectFaces( "
            "size : %d, "
    		"width : %d, "
    		"height : %d "
    		")",
    		width,
    		height,
    		size
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
            FileLevelLog("rtmpdump", KLog::LOG_STAT, "LSFaceDetector::DetectFaces( [Face Dectected], size : %d )", faces.size());

            for(int i = 0; i < faces.size(); i++) {
                FileLevelLog("rtmpdump", KLog::LOG_STAT,
                		"LSFaceDetector::DetectFaces( [Face %d], x : %d, y : %d, width : %d, height : %d )",
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
                // 创建新Buffer
                if( dataByteArray != NULL ) {
                    int oldLen = env->GetArrayLength(dataByteArray);
                    if( oldLen < size) {
                        env->DeleteGlobalRef(dataByteArray);
                        dataByteArray = NULL;
                    }
                }

                if( dataByteArray == NULL ) {
                    jbyteArray localDataByteArray = env->NewByteArray(size);
                    dataByteArray = (jbyteArray)env->NewGlobalRef(localDataByteArray);
                    env->DeleteLocalRef(localDataByteArray);
                }

                if( dataByteArray != NULL ) {
                    env->SetByteArrayRegion(dataByteArray, 0, size, (const jbyte *)data);
                }

                env->CallVoidMethod(mJniCallback, mJniOnDetectedFaceMethodID, dataByteArray, size, face.left(), face.top(), face.width(), face.height());
            }
        }

        if( bFlag ) {
            ReleaseEnv(isAttachThread);
        }
    }

    FileLevelLog("rtmpdump", KLog::LOG_STAT, "LSFaceDetector::DetectFaces( [Finish] )");
}

} /* namespace coollive */
