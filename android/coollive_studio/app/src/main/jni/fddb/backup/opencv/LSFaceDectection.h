/*
 * LSFaceDectection.h
 *
 *  Created on: 2019年1月30日
 *      Author: max
 */

#ifndef OPENCV_LSFACEDECTECTION_H_
#define OPENCV_LSFACEDECTECTION_H_

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/objdetect/objdetect.hpp>

#include <vector>

namespace coollive {

class LSFaceDectection {
public:
	LSFaceDectection();
	virtual ~LSFaceDectection();

	void FilterPicture(int width, int height, const char *data, int len);

private:
	std::vector<cv::Rect> DetectFaces(cv::Mat img_gray);
    void DrawFace(cv::Mat img, cv::Rect face);
    std::vector<cv::Rect> DetectEyes(cv::Mat img_gray, cv::Rect face);
    void DrawEyes(cv::Mat img, cv::Rect face, std::vector<cv::Rect>);

    void SaveManMat(cv::Mat img, std::string fileName);
    void SaveMat(cv::Mat img, std::string fileName);
};

} /* namespace coollive */

#endif /* OPENCV_LSFACEDECTECTION_H_ */
