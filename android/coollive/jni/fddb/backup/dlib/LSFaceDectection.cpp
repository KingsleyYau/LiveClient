/*
 * LSFaceDectection.cpp
 *
 *  Created on: 2019年1月30日
 *      Author: max
 */

#include "LSFaceDectection.h"

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

LSFaceDectection::LSFaceDectection() {
	// TODO Auto-generated constructor stub
     detector = get_frontal_face_detector();
}

LSFaceDectection::~LSFaceDectection() {
	// TODO Auto-generated destructor stub
}

void LSFaceDectection::FilterPicture(int width, int height, const char *data, int len) {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "LSFaceDectection::FilterPicture( "
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
        if( faces.size() > 0 ) {
            FileLevelLog("rtmpdump", KLog::LOG_WARNING, "LSFaceDectection::FilterPicture( [Face Dectected], %d )", faces.size());
        }
    }

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "LSFaceDectection::FilterPicture( [Finish] )");
}

} /* namespace coollive */
