/*
 * LSLCVideoShow.h
 *
 *  Created on: 2015-3-12
 *      Author: Samson.Fan
 */

#ifndef LSLCVIDEOSHOW_H_
#define LSLCVIDEOSHOW_H_

#include <string>
#include <list>
using namespace std;

#include "../LSLiveChatRequestVideoShowDefine.h"
#include <json/json/json.h>

// 查询视频列表 VS_VIDEOLIST_PATH(/member/videoshow)
class LSLCVSVideoListItem {
public:
	bool Parsing(Json::Value root) {
		bool result = false;
		if( root.isObject() ) {
			if( root[VS_VIDEOLIST_VIDEOID].isString() ) {
				videoId = root[VS_VIDEOLIST_VIDEOID].asString();
			}

			if( root[VS_VIDEOLIST_TIME].isString() ) {
				time = root[VS_VIDEOLIST_TIME].asString();
			}

			if( root[VS_VIDEOLIST_THUMBURL].isString() ) {
				thumbURL = root[VS_VIDEOLIST_THUMBURL].asString();
			}

			if( root[VS_VIDEOLIST_WOMANID].isString() ) {
				womanId = root[VS_VIDEOLIST_WOMANID].asString();
			}

			if( root[VS_VIDEOLIST_FIRSTNAME].isString() ) {
				firstname = root[VS_VIDEOLIST_FIRSTNAME].asString();
			}

			if( root[VS_VIDEOLIST_AGE].isIntegral() ) {
				age = root[VS_VIDEOLIST_AGE].asInt();
			}

			if( root[VS_VIDEOLIST_WEIGHT].isString() ) {
				weight = root[VS_VIDEOLIST_WEIGHT].asString();
			}

			if( root[VS_VIDEOLIST_HEIGHT].isString() ) {
				height = root[VS_VIDEOLIST_HEIGHT].asString();
			}

			if( root[VS_VIDEOLIST_COUNTRY].isString() ) {
				country = root[VS_VIDEOLIST_COUNTRY].asString();
			}

			if( root[VS_VIDEOLIST_PROVINCE].isString() ) {
				province = root[VS_VIDEOLIST_PROVINCE].asString();
			}
		}

		if (!videoId.empty()) {
			result = true;
		}
		return result;
	}

	LSLCVSVideoListItem() {
		videoId = "";
		time = "";
		womanId = "";
		firstname = "";
		age = 0;
		weight = "";
		height = "";
		country = "";
		province = "";
	}
	virtual ~LSLCVSVideoListItem() {}

	string	videoId;		// 视频ID
	string	time;			// 视频时长
	string	thumbURL;		// 视频拇指图URL
	string	womanId;		// 女士ID
	string	firstname;		// 女士first name
	int		age;			// 年龄
	string	weight;			// 体重
	string	height;			// 身高
	string	country;		// 国家
	string	province;		// 省份
};
typedef list<LSLCVSVideoListItem> VSVideoList;

// 查询指定女士的视频信息 VS_VIDEODETAIL_PATH(/member/video_detail)
class LSLCVSVideoDetailItem {
public:
	bool Parsing(Json::Value root) {
		bool result = false;
		if( root.isObject() ) {
			if( root[VS_VIDEODETAIL_ID].isString() ) {
				id = root[VS_VIDEODETAIL_ID].asString();
			}

			if( root[VS_VIDEODETAIL_TITLE].isString() ) {
				title = root[VS_VIDEODETAIL_TITLE].asString();
			}

			if( root[VS_VIDEODETAIL_WOMANID].isString() ) {
				womanId = root[VS_VIDEODETAIL_WOMANID].asString();
			}

			if( root[VS_VIDEODETAIL_THUMBURL].isString() ) {
				thumbURL = root[VS_VIDEODETAIL_THUMBURL].asString();
			}

			if( root[VS_VIDEODETAIL_TIME].isString() ) {
				time = root[VS_VIDEODETAIL_TIME].asString();
			}

			if( root[VS_VIDEODETAIL_PHOTOURL].isString() ) {
				photoURL = root[VS_VIDEODETAIL_PHOTOURL].asString();
			}

			if( root[VS_VIDEODETAIL_VIDEOFAV].isIntegral() ) {
				videoFav = root[VS_VIDEODETAIL_VIDEOFAV].asInt() == 1 ? true : false;
			}

			if( root[VS_VIDEODETAIL_VIDEOSIZE].isString() ) {
				videoSize = root[VS_VIDEODETAIL_VIDEOSIZE].asString();
			}

			if( root[VS_VIDEODETAIL_TRANSCRIPTION].isString() ) {
				transcription = root[VS_VIDEODETAIL_TRANSCRIPTION].asString();
			}

			if( root[VS_VIDEODETAIL_VIEWTIME1].isString() ) {
				viewTime1 = root[VS_VIDEODETAIL_VIEWTIME1].asString();
			}

			if( root[VS_VIDEODETAIL_VIEWTIME2].isString() ) {
				viewTime2 = root[VS_VIDEODETAIL_VIEWTIME2].asString();
			}
		}

		if (!id.empty()) {
			result = true;
		}
		return result;
	}

	LSLCVSVideoDetailItem() {
		id = "";
		title = "";
		womanId = "";
		thumbURL = "";
		time = "";
		photoURL = "";
		videoFav = "";
		videoSize = "";
		transcription = "";
		viewTime1 = "";
		viewTime2 = "";
	}
	virtual ~LSLCVSVideoDetailItem() {}

	string	id;				// 视频ID
	string	title;			// 视频时长
	string	womanId;		// 女士ID
	string	thumbURL;		// 视频拇指图URL
	string	time;			// 时长
	string	photoURL;		// 视频图片URL
	bool	videoFav;		// 是否收藏
	string	videoSize;		// 视频文件大小（MB）
	string	transcription;	// 视频文字说明
	string	viewTime1;		// 有效起始时间
	string	viewTime2;		// 有效终止时间
};
typedef list<LSLCVSVideoDetailItem> VSVideoDetailList;

// 查询视频详细信息 VS_PLAYVIDEO_PATH(/member/play_video)
class LSLCVSPlayVideoItem {
public:
	bool Parsing(Json::Value root) {
		bool result = false;
		if( root.isObject() ) {
			if( root[VS_PLAYVIDEO_VIDEOURL].isString() ) {
				videoURL = root[VS_PLAYVIDEO_VIDEOURL].asString();
			}

			if( root[VS_VIDEODETAIL_TRANSCRIPTION].isString() ) {
				transcription = root[VS_VIDEODETAIL_TRANSCRIPTION].asString();
			}

			if( root[VS_VIDEODETAIL_VIEWTIME1].isString() ) {
				viewTime1 = root[VS_VIDEODETAIL_VIEWTIME1].asString();
			}

			if( root[VS_VIDEODETAIL_VIEWTIME2].isString() ) {
				viewTime2 = root[VS_VIDEODETAIL_VIEWTIME2].asString();
			}
		}

		if (!videoURL.empty()) {
			result = true;
		}
		return result;
	}

	LSLCVSPlayVideoItem() {
		videoURL = "";
		transcription = "";
		viewTime1 = "";
		viewTime2 = "";
	}
	virtual ~LSLCVSPlayVideoItem() {}

	string	videoURL;		// 视频URL
	string	transcription;	// 视频文字说明
	string	viewTime1;		// 有效起始时间
	string	viewTime2;		// 有效终止时间
};

// 查询已看过的视频列表 VS_WATCHEDVIDEO_PATH(/member/watched_video)
class LSLCVSWatchedVideoListItem {
public:
	bool Parsing(Json::Value root) {
		bool result = false;
		if( root.isObject() ) {
			if( root[VS_WATCHEDVIDEO_VIDEOID].isString() ) {
				videoId = root[VS_WATCHEDVIDEO_VIDEOID].asString();
			}

			if( root[VS_WATCHEDVIDEO_TIME].isString() ) {
				time = root[VS_WATCHEDVIDEO_TIME].asString();
			}

			if( root[VS_WATCHEDVIDEO_THUMBURL].isString() ) {
				thumbURL = root[VS_WATCHEDVIDEO_THUMBURL].asString();
			}

			if( root[VS_WATCHEDVIDEO_WOMANID].isString() ) {
				womanId = root[VS_WATCHEDVIDEO_WOMANID].asString();
			}

			if( root[VS_WATCHEDVIDEO_FIRSTNAME].isString() ) {
				firstname = root[VS_WATCHEDVIDEO_FIRSTNAME].asString();
			}

			if( root[VS_WATCHEDVIDEO_AGE].isIntegral() ) {
				age = root[VS_WATCHEDVIDEO_AGE].asInt();
			}

			if( root[VS_WATCHEDVIDEO_WEIGHT].isString() ) {
				weight = root[VS_WATCHEDVIDEO_WEIGHT].asString();
			}

			if( root[VS_WATCHEDVIDEO_HEIGHT].isString() ) {
				height = root[VS_WATCHEDVIDEO_HEIGHT].asString();
			}

			if( root[VS_WATCHEDVIDEO_COUNTRY].isString() ) {
				country = root[VS_WATCHEDVIDEO_COUNTRY].asString();
			}

			if( root[VS_WATCHEDVIDEO_PROVINCE].isString() ) {
				province = root[VS_WATCHEDVIDEO_PROVINCE].asString();
			}

			if( root[VS_WATCHEDVIDEO_VIEWTIME1].isString() ) {
				viewTime1 = root[VS_WATCHEDVIDEO_VIEWTIME1].asString();
			}

			if( root[VS_WATCHEDVIDEO_VIEWTIME2].isString() ) {
				viewTime2 = root[VS_WATCHEDVIDEO_VIEWTIME2].asString();
			}

			if( root[VS_WATCHEDVIDEO_VALIDTIME].isIntegral() ) {
				validTime = root[VS_WATCHEDVIDEO_VALIDTIME].asInt();
			}
		}

		if (!videoId.empty()) {
			result = true;
		}
		return result;
	}

	LSLCVSWatchedVideoListItem() {
		videoId = "";
		time = "";
		womanId = "";
		firstname = "";
		age = 0;
		weight = "";
		height = "";
		country = "";
		province = "";
		viewTime1 = "";
		viewTime2 = "";
		validTime = 0;
	}
	virtual ~LSLCVSWatchedVideoListItem() {}

	string	videoId;		// 视频ID
	string	time;			// 视频时长
	string	thumbURL;		// 视频拇指图URL
	string	womanId;		// 女士ID
	string	firstname;		// 女士first name
	int		age;			// 年龄
	string	weight;			// 体重
	string	height;			// 身高
	string	country;		// 国家
	string	province;		// 省份
	string	viewTime1;		// 有效起始时间
	string 	viewTime2;		// 有效终止时间
	int		validTime;		// 有效时间，距离当前时间还有多少天到期
};
typedef list<LSLCVSWatchedVideoListItem> VSWatchedVideoList;


// 查询已收藏的视频列表 VS_SAVEDVIDEO_PATH(/member/saved_video)
class LSLCVSSavedVideoListItem {
public:
	bool Parsing(Json::Value root) {
		bool result = false;
		if( root.isObject() ) {
			if( root[VS_SAVEDVIDEO_VIDEOID].isString() ) {
				videoId = root[VS_SAVEDVIDEO_VIDEOID].asString();
			}

			if( root[VS_SAVEDVIDEO_TIME].isString() ) {
				time = root[VS_SAVEDVIDEO_TIME].asString();
			}

			if( root[VS_SAVEDVIDEO_THUMBURL].isString() ) {
				thumbURL = root[VS_SAVEDVIDEO_THUMBURL].asString();
			}

			if( root[VS_SAVEDVIDEO_WOMANID].isString() ) {
				womanId = root[VS_SAVEDVIDEO_WOMANID].asString();
			}

			if( root[VS_SAVEDVIDEO_FIRSTNAME].isString() ) {
				firstname = root[VS_SAVEDVIDEO_FIRSTNAME].asString();
			}

			if( root[VS_SAVEDVIDEO_AGE].isIntegral() ) {
				age = root[VS_SAVEDVIDEO_AGE].asInt();
			}

			if( root[VS_SAVEDVIDEO_WEIGHT].isString() ) {
				weight = root[VS_SAVEDVIDEO_WEIGHT].asString();
			}

			if( root[VS_SAVEDVIDEO_HEIGHT].isString() ) {
				height = root[VS_SAVEDVIDEO_HEIGHT].asString();
			}

			if( root[VS_SAVEDVIDEO_COUNTRY].isString() ) {
				country = root[VS_SAVEDVIDEO_COUNTRY].asString();
			}

			if( root[VS_SAVEDVIDEO_PROVINCE].isString() ) {
				province = root[VS_SAVEDVIDEO_PROVINCE].asString();
			}
		}

		if (!videoId.empty()) {
			result = true;
		}
		return result;
	}

	LSLCVSSavedVideoListItem() {
		videoId = "";
		time = "";
		womanId = "";
		firstname = "";
		age = 0;
		weight = "";
		height = "";
		country = "";
		province = "";
	}
	virtual ~LSLCVSSavedVideoListItem() {}

	string	videoId;		// 视频ID
	string	time;			// 视频时长
	string	thumbURL;		// 视频拇指图URL
	string	womanId;		// 女士ID
	string	firstname;		// 女士first name
	int		age;			// 年龄
	string	weight;			// 体重
	string	height;			// 身高
	string	country;		// 国家
	string	province;		// 省份
};
typedef list<LSLCVSSavedVideoListItem> VSSavedVideoList;

#endif /* LSLCVIDEOSHOW_H_ */
