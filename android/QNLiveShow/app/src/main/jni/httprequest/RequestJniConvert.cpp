/*
 * RequestJniConvert.cpp
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 *  Description Jni中间转换层
 */

#include "RequestJniConvert.h"
#include <common/CommonFunc.h>

int ReviewStatusToInt(LiveRoomStatus liveRoomStatus)
{
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(LiveRoomStatusArray); i++)
	{
		if (liveRoomStatus == LiveRoomStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

PhotoType IntToPhotoType(int value)
{
	return (PhotoType)(value < _countof(PhotoTypeArray) ? PhotoTypeArray[value] : PhotoTypeArray[0]);
}

int GenderToInt(Gender gender){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(GenderArray); i++)
	{
		if (gender == GenderArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

Gender IntToGender(int value){
	return (Gender)(value < _countof(GenderArray) ? GenderArray[value] : GenderArray[0]);
}


int GiftTypeToInt(GiftType giftType){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(GiftTypeArray); i++)
	{
		if (giftType == GiftTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}

int CoverPhotoStatusToInt(ExamineStatus status){
	int value = 0;
	int i = 0;
	for (i = 0; i < _countof(CoverPhotoStatusArray); i++)
	{
		if (status == CoverPhotoStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}


ImageType IntToUploadPhotoType(int value){
	return (ImageType)(value < _countof(uploadPhotoTypeArray) ? uploadPhotoTypeArray[value] : uploadPhotoTypeArray[0]);
}


