/*
 * LSFaceDectection.h
 *
 *  Created on: 2019年1月30日
 *      Author: max
 */

#ifndef OPENCV_LSFACEDECTECTION_H_
#define OPENCV_LSFACEDECTECTION_H_

#include <vector>
#include <iostream>

#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_io.h>

namespace coollive {

class LSFaceDectection {
public:
	LSFaceDectection();
	virtual ~LSFaceDectection();

	void FilterPicture(int width, int height, const char *data, int len);

private:
    dlib::frontal_face_detector detector;
//	vector<Rect> DetectFaces(Mat img_gray);
//    void DrawFace(Mat img, Rect face);
//    vector<Rect> DetectEyes(Mat img_gray, Rect face);
//    void DrawEyes(Mat img, Rect face, vector<Rect>);
//
//    void SaveManMat(Mat img, string fileName);
//    void SaveMat(Mat img, string fileName);
};

} /* namespace coollive */

#endif /* OPENCV_LSFACEDECTECTION_H_ */
