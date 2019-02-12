/*
 * LSLiveChatRequestEMFDefine.h
 *
 *  Created on: 2015-3-5
 *      Author: Samson.Fan
 * Description: EMF 协议接口定义
 */

#ifndef LSLIVECHATREQUESTEMFDEFINE_H_
#define LSLIVECHATREQUESTEMFDEFINE_H_

#include <string>
#include <list>

using namespace std;

/* ########################	EMF相关 定义  ######################## */
/// ------------------- 请求参数定义 -------------------
#define EMF_REQUEST_SORTBY		"sortby"
#define EMF_REQUEST_GETCOUNT	"getcount"
#define EMF_REQUEST_WOMANID		"womanid"
#define EMF_REQUEST_MESSAGEID	"messageid"
#define EMF_REQUEST_PROGRESS	"progress"
#define EMF_REQUEST_BODY		"body"
#define EMF_REQUEST_USEINTEGRAL	"use_integral"
#define EMF_REQUEST_FILENAME	"filename"
#define EMF_REQUEST_EMAILID		"emailID"
#define EMF_REQUEST_MAILTYPE	"mailType"
#define EMF_REQUEST_BLOCKREASON	"blockreason"
#define EMF_REQUEST_PHOTOID		"photoid"
#define EMF_REQUEST_SENDID		"sendid"
#define EMF_REQUEST_ATTACHTYPE	"type"
#define EMF_REQUEST_ATTACHINFO	"attachinfo"
#define EMF_REQUEST_GIFTS		"gifts"
#define EMF_REQUEST_ATTACHS		"attachs"
#define EMF_REQUEST_REPLYTYPE	"replytype"
#define EMF_REQUEST_MTA			"mta"
#define EMF_REQUEST_LOVECALL_FLAG 	"mail"

#define EMF_REQUEST_ATTACH_ID	"id"


/// ------------------- 请求参数结构定义 -------------------
// 发送邮件(/emf/sendmsg)
typedef list<string>	SendMsgGifts;		// 虚拟礼物ID数组
typedef list<string>	SendMsgAttachs;	// 附件ID数组

/// ------------------- 返回参数定义 -------------------
// 查询收件箱列表
#define EMF_INBOXLIST_PATH		"/emf/inboxlist"
// item
#define EMF_INBOXLIST_ID			"id"
#define EMF_INBOXLIST_WOMANID		"womanid"
#define EMF_INBOXLIST_ATTACHNUM		"attachnum"
#define EMF_INBOXLIST_SHORTVIDEO    "short_video"
#define EMF_INBOXLIST_VIRTUALGIFTS	"virtual_gifts"
#define EMF_INBOXLIST_READFLAG 		"readflag"
#define EMF_INBOXLIST_RFLAG			"rflag"
#define EMF_INBOXLIST_FFLAG			"fflag"
#define EMF_INBOXLIST_PFLAG		 	"pflag"
#define EMF_INBOXLIST_FIRSTNAME 	"firstname"
#define EMF_INBOXLIST_LASTNAME 		"lastname"
#define EMF_INBOXLIST_WEIGHT 		"weight"
#define EMF_INBOXLIST_HEIGHT 		"height"
#define EMF_INBOXLIST_COUNTRY 		"country"
#define EMF_INBOXLIST_PROVINCE 		"province"
#define EMF_INBOXLIST_ONLINESTATUS  "online_status"
#define EMF_INBOXLIST_CAMSTATUS     "camStatus"
#define EMF_INBOXLIST_AGE	 		"age"
#define EMF_INBOXLIST_SENDTIME 		"sendTime"
#define EMF_INBOXLIST_PHOTOURL 		"photoURL"
#define EMF_INBOXLIST_INTRO			"intro"
#define EMF_INBOXLIST_VGID			"vg_id"

// 查询已收邮件详细
#define EMF_INBOXMSG_PATH		"/emf/inboxmsg"
// item
#define EMF_INBOXMSG_ID 			"id"
#define EMF_INBOXMSG_WOMANID		"womanid"
#define EMF_INBOXMSG_FIRSTNAME 		"firstname"
#define EMF_INBOXMSG_LASTNAME 		"lastname"
#define EMF_INBOXMSG_WEIGHT 		"weight"
#define EMF_INBOXMSG_HEIGHT 		"height"
#define EMF_INBOXMSG_COUNTRY 		"country"
#define EMF_INBOXMSG_PROVINCE 		"province"
#define EMF_INBOXMSG_AGE	 		"age"
#define EMF_INBOXMSG_ONLINESTATUS   "online_status"
#define EMF_INBOXMSG_CAMSTATUS      "camStatus"
#define EMF_INBOXMSG_PHOTOURL	 	"photoURL"
#define EMF_INBOXMSG_BODY		 	"body"
#define EMF_INBOXMSG_NOTETOMAN	 	"notetoman"
#define EMF_INBOXMSG_PHOTOSURL	 	"photosURL"
#define EMF_INBOXMSG_SENDTIME	 	"sendTime"
#define EMF_INBOXMSG_VGID		 	"vg_id"
#define EMF_INBOXMSG_PRIVATEPHOTOS 	"private_photos"
#define EMF_INBOXMSG_SENDID			"send_id"
#define EMF_INBOXMSG_PHOTOID		"photo_id"
#define EMF_INBOXMSG_PHOTOFEE		"photo_fee"
#define EMF_INBOXMSG_PHOTODESC		"photo_desc"
#define EMF_INBOXMSG_SHORTVIDEOS 	"short_videos"
#define EMF_INBOXMSG_VIDEOID		"video_id"
#define EMF_INBOXMSG_VIDEOFEE		"video_fee"
#define EMF_INBOXMSG_VIDEODESC		"video_desc"

// 查询已发邮件详细
#define EMF_OUTBOXLIST_PATH		"/emf/outboxlist"
// item
#define EMF_OUTBOXLIST_ID			"id"
#define EMF_OUTBOXLIST_ATTACHNUM	"attachnum"
#define EMF_OUTBOXLIST_VIRTUALGIFTS	"virtual_gifts"
#define EMF_OUTBOXLIST_PROGRESS		"progress"
#define EMF_OUTBOXLIST_WOMANID		"womanid"
#define EMF_OUTBOXLIST_FIRSTNAME	"firstname"
#define EMF_OUTBOXLIST_LASTNAME		"lastname"
#define EMF_OUTBOXLIST_WEIGHT		"weight"
#define EMF_OUTBOXLIST_HEIGHT		"height"
#define EMF_OUTBOXLIST_COUNTRY		"country"
#define EMF_OUTBOXLIST_PROVINCE		"province"
#define EMF_OUTBOXLIST_AGE			"age"
#define EMF_OUTBOXLIST_ONLINESTATUS "online_status"
#define EMF_OUTBOXLIST_CAMSTATUS    "camStatus"
#define EMF_OUTBOXLIST_INTRO		"intro"
#define EMF_OUTBOXLIST_SENDTIME		"sendTime"
#define EMF_OUTBOXLIST_PHOTOURL		"photoURL"

// 查询已发邮件详细
#define EMF_OUTBOXMSG_PATH		"/emf/outboxmsg"
// item
#define EMF_OUTBOXMSG_ID			"id"
#define EMF_OUTBOXMSG_VGID			"vg_id"
#define EMF_OUTBOXMSG_CONTENT		"content"
#define EMF_OUTBOXMSG_SENDTIME		"sendTime"
#define EMF_OUTBOXMSG_PHOTOSURL		"photosURL"
#define EMF_OUTBOXMSG_PHOTOURL		"photoURL"
#define EMF_OUTBOXMSG_WOMANID		"womanid"
#define EMF_OUTBOXMSG_FIRSTNAME		"firstname"
#define EMF_OUTBOXMSG_LASTNAME		"lastname"
#define EMF_OUTBOXMSG_WEIGHT		"weight"
#define EMF_OUTBOXMSG_HEIGHT		"height"
#define EMF_OUTBOXMSG_COUNTRY		"country"
#define EMF_OUTBOXMSG_PROVINCE		"province"
#define EMF_OUTBOXMSG_AGE			"age"
#define EMF_OUTBOXMSG_ONLINESTATUS  "online_status"
#define EMF_OUTBOXMSG_CAMSTATUS     "camStatus"
#define EMF_OUTBOXMSG_PRIVATEPHOTOS	"private_photos"
#define EMF_OUTBOXMSG_SENDID		"send_id"
#define EMF_OUTBOXMSG_PHOTOID		"photo_id"
#define EMF_OUTBOXMSG_PHOTOFEE		"photo_fee"
#define EMF_OUTBOXMSG_PHOTODESC		"photo_desc"

// 查询收件箱某状态邮件数量
#define EMF_MSGTOTAL_PATH		"/emf/msgtotal"
// item
#define EMF_MSGTOTAL_MSGTOTAL		"data"

// 发送邮件
#define EMF_SENDMSG_PATH		"/emf/sendmsg"
// item
#define EMF_SENDMSG_MESSAGEID		"messageid"
#define EMF_SENDMSG_SENDTIME		"sendTime"
// error item
#define EMF_SENDMSG_MONEY			"money"
#define EMF_MEMBER_TYPE             "type"

// 追加邮件附件（已废弃）
#define EMF_UPLOADIMAGE_PATH	"/emf/uploadimage"
// item（暂无）

// 上传邮件附件
#define EMF_UPLOADATTACH_PATH	"/emf/uploadattach"
// item
#define EMF_UPLOADATTACH_ID			"attachid"

// 删除邮件
#define EMF_DELETEMSG_PATH		"/emf/deletemsg"
// item（暂无）

// 查询意向信收件箱列表
#define EMF_ADMIRERLIST_PATH	"/emf/admirerlist"
// item
#define EMF_ADMIRERLIST_ID			"id"
#define EMF_ADMIRERLIST_IDCODE		"idcode"
#define EMF_ADMIRERLIST_READFLAG	"readflag"
#define EMF_ADMIRERLIST_REPLYFLAG	"replyflag"
#define EMF_ADMIRERLIST_WOMANID		"womanid"
#define EMF_ADMIRERLIST_FIRSTNAME	"firstname"
#define EMF_ADMIRERLIST_WEIGHT		"weight"
#define EMF_ADMIRERLIST_HEIGHT		"height"
#define EMF_ADMIRERLIST_COUNTRY		"country"
#define EMF_ADMIRERLIST_PROVINCE	"province"
#define EMF_ADMIRERLIST_ADDDATE1	"adddate1"
#define EMF_ADMIRERLIST_MTAB		"mtab"
#define EMF_ADMIRERLIST_AGE			"age"
#define EMF_ADMIRERLIST_ONLINESTATUS  "online_status"
#define EMF_ADMIRERLIST_CAMSTATUS     "camStatus"
#define EMF_ADMIRERLIST_PHOTOURL	"photoURL"
#define EMF_ADMIRERLIST_SENDTIME	"sendTime"
#define EMF_ADMIRERLIST_ATTACHNUM	"attachnum"
#define EMF_ADMIRERLIST_TEMPLATE_TYPE	"template_type"
// 查询意向信详细信息
#define EMF_ADMIRERVIEWER_PATH	"/emf/admirerviewer"
// item
#define EMF_ADMIRERVIEWER_ID		"id"
#define EMF_ADMIRERVIEWER_BODY		"body"
#define EMF_ADMIRERVIEWER_PHOTOSURL	"photosURL"
#define EMF_ADMIRERVIEWER_WOMANID	"womanid"
#define EMF_ADMIRERVIEWER_FIRSTNAME	"firstname"
#define EMF_ADMIRERVIEWER_WEIGHT	"weight"
#define EMF_ADMIRERVIEWER_HEIGHT	"height"
#define EMF_ADMIRERVIEWER_COUNTRY	"country"
#define EMF_ADMIRERVIEWER_PROVINCE	"province"
#define EMF_ADMIRERVIEWER_MTAB		"mtab"
#define EMF_ADMIRERVIEWER_AGE		"age"
#define EMF_ADMIRERVIEWER_ONLINESTATUS  "online_status"
#define EMF_ADMIRERVIEWER_CAMSTATUS     "camStatus"
#define EMF_ADMIRERVIEWER_PHOTOURL	"photoURL"
#define EMF_ADMIRERVIEWER_SENDTIME	"sendTime"
#define EMF_ADMIRERVIEWER_TEMPLATE_TYPE	"template_type"
#define EMF_ADMIRERVIEWER_VGID	    "vg_id"

// 查询黑名单列表
#define EMF_BLOCKLIST_PATH		"/emf/blocklist"
// item
#define EMF_BLOCKLIST_WOMANID		"womanid"
#define EMF_BLOCKLIST_FIRSTNAME		"firstname"
#define EMF_BLOCKLIST_AGE			"age"
#define EMF_BLOCKLIST_WEIGHT		"weight"
#define EMF_BLOCKLIST_HEIGHT		"height"
#define EMF_BLOCKLIST_COUNTRY		"country"
#define EMF_BLOCKLIST_PROVINCE		"province"
#define EMF_BLOCKLIST_CITY			"city"
#define EMF_BLOCKLIST_PHOTOURL		"photoURL"
#define EMF_BLOCKLIST_BLOCKREASON	"blockreason"

// 添加黑名单
#define EMF_BLOCK_PATH			"/emf/block"
// item（暂无）

// 删除黑名单
#define EMF_UNBLOCK_PATH		"/emf/unblock"
// item（暂无）

// 男士付费获取EMF私密照片
#define EMF_INBOXPHOTOFEE_PATH	"/emf/inbox_photo_fee"
// item
#define EMF_INBOXPHOTOFEE_WOMANID	"womanid"
#define EMF_INBOXPHOTOFEE_SENDID	"send_id"
#define EMF_INBOXPHOTOFEE_MESSAGEID	"messageid"
#define EMF_INBOXPHOTOFEE_SIZE		"size"
#define EMF_INBOXPHOTOFEE_MODE		"mode"

// 获取对方或自己的EMF私密照片
#define EMF_PRIVATEPHOTOVIEW_PATH	"/emf/private_photo_view"
// item
#define EMF_PRIVATEPHOTOVIEW_WOMANID	"womanid"
#define EMF_PRIVATEPHOTOVIEW_SENDID		"send_id"
#define EMF_PRIVATEPHOTOVIEW_MESSAGEID	"messageid"

//获取EMF微视频 thumb 图片
#define EMF_SHORTVIDEOTHUMBPHOTO_PATH		"/emf/short_video_photo"
//请求
#define EMF_SHORTVIDEOTHUMBPHOTO_WOMANID	"womanid"
#define EMF_SHORTVIDEOTHUMBPHOTO_SENDID		"send_id"
#define EMF_SHORTVIDEOTHUMBPHOTO_VIDEOID	"video_id"
#define EMF_SHORTVIDEOTHUMBPHOTO_MESSAGEID	"messageid"
#define EMF_SHORTVIDEOTHUMBPHOTO_PHOTOSIZE	"size"

//获取EMF微视频下载地址
#define EMF_SHORTVIDEOURL_PATH				"/emf/short_video_url"


// ------ 枚举定义 ------
// progress(邮件处理状态)
static const char* EMF_PROGRESS_TYPE[] =
{
	"U",	// Unread
	"P",	// Pending
	"D",	// Delivered
};

// sortby(筛选条件)
static const char* EMF_SORTBY_TYPE[] =
{
	"1",	// 未读
	"2",	// 已读未回复
	"3",	// 已读
};

// mailType(邮件类型)
static const char* EMF_MAILTYPE_TYPE[] =
{
	"1",	// 收件箱邮件
	"2",	// 发件箱邮件
	"3",	// 意向信邮件
};

// blockreason(加入黑名单原因)
static const char* EMF_BLOCKREASON_TYPE[] =
{
	"1",	// 原因A
	"2",	// 原因B
	"3",	// 原因C
};

// replyflag(回复状态)
static const char* EMF_REPLYFLAG_TYPE[] =
{
	"0",	// 考虑中(Considering)
	"1",	// 已回复(Replied)
	"2",	// 拒绝原因A(Reason A)
	"3",	// 拒绝原因B(Reason B)
	"4",	// 拒绝原因C(Reason C)
};

// attachType(上传的附件类型)
static const char* EMF_UPLOADATTACH_TYPE[] =
{
	"1",	// 图片
};

static const char* PRIVITE_PHOTO_SIZE_ARRAY[] = {
	"l",
	"m",
	"s",
	"o"
};

// 回复类型
static const char* REPLY_TYPE_ARRAY[] = {
	"emf",
	"adr"
};

// ------ 特殊字符定义 ------
// 附件文件(photosURL)分隔符
#define EMF_PHOTOSURL_DELIMITER	","
// 女士ID(womanid)分隔符
#define EMF_WOMANID_DELIMITER	","

#endif /* LSLIVECHATREQUESTEMFDEFINE_H_ */
