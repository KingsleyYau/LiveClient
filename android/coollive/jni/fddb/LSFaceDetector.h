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
#include <dlib/image_processing.h>
#include <dlib/image_io.h>

#include <AndroidCommon/JniCommonFunc.h>

namespace coollive {

class LSFaceDetector {
public:
	LSFaceDetector(jobject jniCallback);
	virtual ~LSFaceDetector();

	void DetectFaces(const char *data, int size, int width, int height);

private:
    dlib::frontal_face_detector detector;
    dlib::shape_predictor sp;

    jobject mJniCallback;
    jmethodID mJniOnDetectedFaceMethodID;
    jbyteArray dataByteArray;
};

} /* namespace coollive */

#endif /* OPENCV_LSFaceDetector_H_ */
