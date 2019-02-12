/*
 * LSLiveChatRequestVSDefine.h
 *
 *  Created on: 2015-3-5
 *      Author: Samson.Fan
 * Description: Video Show 协议接口定义
 */

#ifndef LSLIVECHATREQUESTVIDEOSHOWDEFINE_H_
#define LSLIVECHATREQUESTVIDEOSHOWDEFINE_H_

/* ########################	VideoShow相关接口  ######################## */
/// ------------------- 请求参数定义 -------------------
#define VS_REQUEST_AGE1		"age1"
#define VS_REQUEST_AGE2		"age2"
#define VS_REQUEST_ORDERBY	"orderby"
#define VS_REQUEST_WOMANID	"womanid"
#define VS_REQUEST_VIDEOID	"videoid"

/// ------------------- 返回参数定义 -------------------
// 查询视频列表
#define VS_VIDEOLIST_PATH		"/member/videoshow"
// item
#define VS_VIDEOLIST_VIDEOID			"videoid"
#define VS_VIDEOLIST_TIME				"time"
#define VS_VIDEOLIST_THUMBURL			"thumb"
#define VS_VIDEOLIST_WOMANID			"womanid"
#define VS_VIDEOLIST_FIRSTNAME			"firstname"
#define VS_VIDEOLIST_AGE				"age"
#define VS_VIDEOLIST_WEIGHT				"weight"
#define VS_VIDEOLIST_HEIGHT				"height"
#define VS_VIDEOLIST_COUNTRY			"country"
#define VS_VIDEOLIST_PROVINCE			"province"

// 查询指定女士的视频信息
#define VS_VIDEODETAIL_PATH		"/member/video_detail"
//item
#define VS_VIDEODETAIL_ID				"id"
#define VS_VIDEODETAIL_TITLE			"title"
#define VS_VIDEODETAIL_WOMANID			"womanid"
#define VS_VIDEODETAIL_THUMBURL			"thumb"
#define VS_VIDEODETAIL_TIME				"time"
#define VS_VIDEODETAIL_PHOTOURL			"photo"
#define VS_VIDEODETAIL_VIDEOFAV			"videofav"
#define VS_VIDEODETAIL_VIDEOSIZE		"videosize"
#define VS_VIDEODETAIL_TRANSCRIPTION	"transcription"
#define VS_VIDEODETAIL_VIEWTIME1		"viewtime1"
#define VS_VIDEODETAIL_VIEWTIME2		"viewtime2"

// 查询视频详细信息
#define VS_PLAYVIDEO_PATH		"/member/play_video"
// item
#define VS_PLAYVIDEO_VIDEOURL			"videourl"
#define VS_PLAYVIDEO_TRANSCRIPTION		"transcription"
#define VS_PLAYVIDEO_VIEWTIME1			"viewtime1"
#define VS_PLAYVIDEO_VIEWTIME2			"viewtime2"

// 查询已经看过的视频列表
#define VS_WATCHEDVIDEO_PATH	"/member/watched_video"
// item
#define VS_WATCHEDVIDEO_VIDEOID			"videoid"
#define VS_WATCHEDVIDEO_TIME			"time"
#define VS_WATCHEDVIDEO_THUMBURL		"thumb"
#define VS_WATCHEDVIDEO_WOMANID			"womanid"
#define VS_WATCHEDVIDEO_FIRSTNAME		"firstname"
#define VS_WATCHEDVIDEO_AGE				"age"
#define VS_WATCHEDVIDEO_WEIGHT			"weight"
#define VS_WATCHEDVIDEO_HEIGHT			"height"
#define VS_WATCHEDVIDEO_COUNTRY			"country"
#define VS_WATCHEDVIDEO_PROVINCE		"province"
#define VS_WATCHEDVIDEO_VIEWTIME1		"viewtime1"
#define VS_WATCHEDVIDEO_VIEWTIME2		"viewtime2"
#define VS_WATCHEDVIDEO_VALIDTIME		"validtime"

// 收藏视频
#define VS_SAVEVIDEO_PATH		"/member/save_video"
// item

// 删除收藏视频
#define VS_REMOVEVIDEO_PATH		"/member/remove_video"
// item

// 查询已收藏的视频列表
#define VS_SAVEDVIDEO_PATH		"/member/saved_video"
// item
#define VS_SAVEDVIDEO_VIDEOID			"videoid"
#define VS_SAVEDVIDEO_TIME				"time"
#define VS_SAVEDVIDEO_THUMBURL			"thumb"
#define VS_SAVEDVIDEO_WOMANID			"womanid"
#define VS_SAVEDVIDEO_FIRSTNAME			"firstname"
#define VS_SAVEDVIDEO_AGE				"age"
#define VS_SAVEDVIDEO_WEIGHT			"weight"
#define VS_SAVEDVIDEO_HEIGHT			"height"
#define VS_SAVEDVIDEO_COUNTRY			"country"
#define VS_SAVEDVIDEO_PROVINCE			"province"

// ------ 枚举定义 ------
// orderby(排序规则)
static const int VS_ORDERBY_TYPE[] =
{
	0,	// 按最新添加排序
	1,	// 按最高点击率排序
};

#endif /* LSLIVECHATREQUESTVIDEOSHOWDEFINE_H_ */
