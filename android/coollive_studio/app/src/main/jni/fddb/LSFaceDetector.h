/*
 * LSFaceDetector.h
 *
 *  Created on: 2019年1月30日
 *      Author: max
 */

#ifndef OPENCV_LSFaceDetector_H_
#define OPENCV_LSFaceDetector_H_

#include <vector>
#include <iostream>

#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_io.h>

#include <AndroidCommon/JniCommonFunc.h>

namespace coollive {

class LSFaceDetector {
public:
	LSFaceDetector(jobject jniCallback);
	virtual ~LSFaceDetector();

	void FilterPicture(int width, int height, const char *data, int len);

private:
    dlib::frontal_face_detector detector;

    jobject mJniCallback;
    jmethodID mJniOnDetectedFaceMethodID;
};

} /* namespace coollive */

#endif /* OPENCV_LSFaceDetector_H_ */
