/*
 * LSLCLadyDetail.h
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCLADYDETAIL_H_
#define LSLCLADYDETAIL_H_

#include <string>
#include <list>
using namespace std;

#include <json/json/json.h>

#include "../LSLiveChatRequestLadyDefine.h"

#include "LSLCVideoItem.h"

class LSLCLadyDetail {
public:
	void Parse(Json::Value root);

	LSLCLadyDetail();
	virtual ~LSLCLadyDetail();

	/**
	 * 查询女士详细信息回调
	 * @param womanid			女士ID
	 * @param firstname			女士first name
	 * @param country			国家
	 * @param province			省份
	 * @param birthday			出生日期
	 * @param age				年龄
	 * @param zodiac			星座
	 * @param weight			体重
	 * @param height			身高
	 * @param smoke				吸烟情况
	 * @param drink				喝酒情况
	 * @param english			英语能力
	 * @param religion			宗教情况
	 * @param education			教育情况
	 * @param profession		职业
	 * @param children			子女状况
	 * @param marry				婚姻状况
	 * @param resume			个人简介
	 * @param age1				期望的起始年龄
	 * @param age2				期望的结束年龄
	 * @param isonline			是否在线
	 * @param isfavorite		是否收藏
	 * @param last_update		最后更新时间
	 * @param show_lovecall		是否显示Love Call功能
	 * @param photoURL			女士头像URL
	 * @param photoMinURL		女士小头像URL(100*133)
	 * @param thumbList			拇指图URL列表
	 * @param photoList			图片URL列表
	 * @param videoList			视频列表
	 * @param photoLockNum      锁定的相片数量
	 * @param camStatus         Cam是否打开
	 */

	string womanid;
	string firstname;
	string country;
    int countryIndex;
	string province;
	string birthday;
	int age;
	string zodiac;
	string weight;
	string height;
	string smoke;
	string drink;
	string english;
	string religion;
	string education;
	string profession;
	string children;
	string marry;
	string resume;
	int age1;
	int age2;
	bool isonline;
	bool isfavorite;
	string last_update;
	int show_lovecall;

	string photoURL;
	string photoMinURL;

	list<string> thumbList;
	list<string> photoList;
	list<LSLCVideoItem> videoList;
	int photoLockNum;
	bool camStatus;
};

#endif /* LADYDETAIL_H_ */
