/*
 * LSFaceDectection.cpp
 *
 *  Created on: 2019年1月30日
 *      Author: max
 */

#include "LSFaceDectection.h"

#include <common/KLog.h>

#include <iostream>
#include <sstream>
#include <string>

using namespace cv;
using namespace std;

namespace coollive {

LSFaceDectection::LSFaceDectection() {
	// TODO Auto-generated constructor stub
}

LSFaceDectection::~LSFaceDectection() {
	// TODO Auto-generated destructor stub
}

void LSFaceDectection::FilterPicture(int width, int height, const char *data, int len) {
	Mat img = imread("/sdcard/input/2.png");
    //Mat img(Size(width, height), CV_8UC4, data);

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "LSFaceDectection::FilterPicture( "
    		"width : %d, "
    		"height : %d, "
    		"len : %d, "
    		"img.empty() : %d "
    		")",
    		width,
    		height,
    		len,
    		img.empty()
    		);

    if( !img.empty() ) {
        Mat img_gray;
        cvtColor(img, img_gray, COLOR_BGR2GRAY);
        equalizeHist(img_gray, img_gray);

        vector<Rect> faces = DetectFaces(img_gray);
        if( faces.size() > 0 ) {
            FileLevelLog("rtmpdump", KLog::LOG_WARNING, "LSFaceDectection::FilterPicture( [Face Dectected], %d )", faces.size());

            string fileName = "/sdcard/faces/mat.jpg";
            SaveMat(img, fileName);
        }
    }

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "LSFaceDectection::FilterPicture( [Finish] )");
}

vector<Rect> LSFaceDectection::DetectFaces(Mat img_gray) {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "LSFaceDectection::DetectFaces()");
	// 检测灰度图片中的人脸，返回人脸矩形坐标(x,y,width,height)
	// 因为可能检测出多个人脸，所以返回类型为vetor<Rect>
	CascadeClassifier faces_cascade;
	faces_cascade.load("/sdcard/haarcascades/haarcascade_frontalface_alt.xml");
	vector<Rect> faces;
	faces_cascade.detectMultiScale(img_gray, faces, 1.5, 2, CV_HAAR_DO_CANNY_PRUNING, Size(30, 30));
	return faces;
}

void LSFaceDectection::DrawFace(Mat img, Rect face) {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "LSFaceDectection::DrawFace()");

    // 先确定人脸矩形中心坐标,再根据该坐标画椭圆
    Point center(face.x + face.width / 2, face.y + face.height / 2);
    ellipse(img, center, Size(face.width / 2, face.height / 1.5), 0, 0, 360, Scalar(0,255,0), 2, 8, 0);
}

vector<Rect> LSFaceDectection::DetectEyes(Mat img_gray, Rect face) {
    Mat faceROI = img_gray(face);
    CascadeClassifier eyes_cascade;
    eyes_cascade.load("/sdcard/haarcascades/haarcascade_eye.xml");
    vector<Rect> eyes;
    eyes_cascade.detectMultiScale(faceROI, eyes, 1.1, 2, 0 | CV_HAAR_SCALE_IMAGE, Size(30, 30));
    return eyes;
}

void LSFaceDectection::DrawEyes(Mat img, Rect face, vector<Rect> eyes) {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "LSFaceDectection::DrawFace()");

    // 用圆形框出眼睛区域
    for(size_t i = 0; i < eyes.size(); i++){
        Point eyes_center(face.x + eyes[i].x + eyes[i].width / 2, face.y + eyes[i].y + eyes[i].height / 2);
        int r = cvRound((eyes[i].width + eyes[i].height) * 0.25);
        circle(img, eyes_center, r, Scalar(255,0,0), 1, 8, 0);
    }
}

void LSFaceDectection::SaveManMat(Mat img, string fileName) {
    imwrite(fileName, img);
}

void LSFaceDectection::SaveMat(Mat img, string fileName) {
    imwrite(fileName, img);
}

} /* namespace coollive */
