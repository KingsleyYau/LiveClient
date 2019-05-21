/*
 * LSLiveChatRequestLiveChatController.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTLIVECHATCONTROLLER_H_
#define LSLIVECHATREQUESTLIVECHATCONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"

#include <list>
using namespace std;

#include <json/json/json.h>
#include <xml/tinyxml.h>

#include "LSLiveChatRequestLiveChatDefine.h"
#include "LSLiveChatRequestOtherDefine.h"
#include <ProtocolCommon/DeviceTypeDef.h>

#include "item/LSLCCoupon.h"
#include "item/LSLCGift.h"
#include "item/LSLCRecordMutiple.h"
#include "item/LSLCLCSendPhotoItem.h"
#include "item/LSLCLCVideoItem.h"
#include "item/LSLCMagicIconConfig.h"
#include "item/LSLCThemeConfig.h"

//virtual void OnCheckCoupon)(long requestId, bool success, Coupon item, string userId, string errnum, string errmsg);
//virtual void OnUseCoupon)(long requestId, bool success, string errnum, string errmsg, string userId);
//virtual void OnQueryChatVirtualGift)(long requestId, bool success, list<Gift> giftList, int totalCount, string path, string version,string errnum, string errmsg);
//virtual void OnQueryChatRecord)(long requestId, bool success, int dbTime, list<Record> recordList, string errnum, string errmsg, string inviteId);
//virtual void OnQueryChatRecordMutiple)(long requestId, bool success, int dbTime, list<RecordMutiple> recordMutiList, string errnum, string errmsg);
//virtual void OnSendPhoto)(long requestId, bool success, const string& errnum, const string& errmsg, const LCSendPhotoItem& item);
//virtual void OnPhotoFee)(long requestId, bool success, const string& errnum, const string& errmsg);
//virtual void OnGetPhoto)(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath);
//virtual void OnUploadVoice)(long requestId, bool success, const string& errnum, const string& errmsg, const string& voiceId);
//virtual void OnPalyVoice)(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath);
//virtual void OnSendGift)(long requestId, bool success, const string& errnum, const string& errmsg);
//virtual void OnQueryRecentVideoList)(long requestId, bool success, list<LSLCVideoItem> itemList, string errnum, string errmsg);
//virtual void OnGetVideoPhoto)(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath);
//virtual void OnGetVideo)(long requestId, bool success, const string& errnum, const string& errmsg, const string& url);
//typedef struct LSLiveChatRequestLiveChatControllerCallback {
//	OnCheckCoupon onCheckCoupon;
//	OnUseCoupon onUseCoupon;
//	OnQueryChatVirtualGift onQueryChatVirtualGift;
//	OnQueryChatRecord onQueryChatRecord;
//	OnQueryChatRecordMutiple onQueryChatRecordMutiple;
//	OnSendPhoto onSendPhoto;
//	OnPhotoFee onPhotoFee;
//	OnGetPhoto onGetPhoto;
//	OnUploadVoice onUploadVoice;
//	OnPalyVoice onPalyVoice;
//	OnSendGift onSendGift;
//	OnQueryRecentVideoList onQueryRecentVideoList;
//	OnGetVideoPhoto onGetVideoPhoto;
//	OnGetVideo onGetVideo;
//} LSLiveChatRequestLiveChatControllerCallback;

class ILSLiveChatRequestLiveChatControllerCallback
{
public:
	ILSLiveChatRequestLiveChatControllerCallback() {}
	virtual ~ILSLiveChatRequestLiveChatControllerCallback() {}
public:
    virtual void OnCheckCoupon(long requestId, bool success, const LSLCCoupon& item, const string& userId, const string& errnum, const string& errmsg) {};
    virtual void OnUseCoupon(long requestId, bool success, const string& errnum, const string& errmsg, const string& userId, const string& couponid) {};
	virtual void OnQueryChatVirtualGift(long requestId, bool success, const list<LSLCGift>& giftList, int totalCount, const string& path, const string& version, const string& errnum, const string& errmsg) {};
	virtual void OnQueryChatRecord(long requestId, bool success, int dbTime, const list<LSLCRecord>& recordList, const string& errnum, const string& errmsg, const string& inviteId) {};
	virtual void OnQueryChatRecordMutiple(long requestId, bool success, int dbTime, const list<LSLCRecordMutiple>& recordMutiList, const string& errnum, const string& errmsg) {};
	virtual void OnSendPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCLCSendPhotoItem& item) {};
	virtual void OnPhotoFee(long requestId, bool success, const string& errnum, const string& errmsg, const string& sendId) {};
	virtual void OnCheckPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& sendId, bool isCharge) {};
	virtual void OnGetPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath) {};
	virtual void OnUploadVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& voiceId) {};
	virtual void OnPlayVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath) {};
	virtual void OnSendGift(long requestId, bool success, const string& errnum, const string& errmsg) {};
	virtual void OnQueryRecentVideoList(long requestId, bool success, const list<LSLCVideoItem>& itemList, const string& errnum, const string& errmsg) {};
	virtual void OnGetVideoPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath) {};
	virtual void OnGetVideo(long requestId, bool success, const string& errnum, const string& errmsg, const string& url) {};
	virtual void OnGetMagicIconConfig(long requestId, bool success, const string& errnum, const string& errmsg,const LSLCMagicIconConfig& config){};
	virtual void OnChatRecharge(long requestId, bool success, const string& errnum, const string& errmsg, double credits) {};
	virtual void OnGetThemeConfig(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCThemeConfig& config){};
	virtual void OnGetThemeDetail(long requestId, bool success, const string& errnum, const string& errmsg, const ThemeItemList& themeList){};
	virtual void OnCheckFunctions(long requestId, bool success, const string& errnum, const string& errmsg, const list<string>& flagList) {};
    // 12.16.上传LiveChat相关附件
    virtual void OnUploadManPhoto(long requestId, bool success, int errnum, const string& errmsg, const string& url, const string& md5) {};
};


class LSLiveChatRequestLiveChatController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestLiveChatController(LSLiveChatHttpRequestManager* pHttpRequestManager, ILSLiveChatRequestLiveChatControllerCallback* callback/*, CallbackManager* pCallbackManager*/);
	virtual ~LSLiveChatRequestLiveChatController();

    typedef enum ServiceType {
        ServiceType_Livechat = 0,
        ServiceType_Camshare = 1,
    } ServiceType;
    
	/**
	 * 5.1.查询是否符合试聊条件
	 * @param womanId			女士ID
	 * @param serviceType       服务类型
	 * @return					请求唯一标识
	 */
	long CheckCoupon(string womanId, ServiceType serviceType = ServiceType_Livechat);

	/**
	 * 5.2.使用试聊券
	 * @param womanId			女士ID
	 * @param serviceType       服务类型
	 * @return					请求唯一标识
	 */
	long UseCoupon(string womanId, ServiceType serviceType = ServiceType_Livechat);

	/**
	 * 5.3.获取虚拟礼物列表
	 * @param sessionId			登录成功返回的sessionid
	 * @param userId			登录成功返回的manid
	 * @return					请求唯一标识
	 */
	long QueryChatVirtualGift(string sessionId, string userId);

	/**
	 * 5.4.查询聊天记录
	 * @param inviteId			邀请ID
	 * @return					请求唯一标识
	 */
	long QueryChatRecord(string inviteId);

	/**
	 * 5.5.批量查询聊天记录
	 * @param inviteId			邀请ID数组
	 * @return					请求唯一标识
	 */
	long QueryChatRecordMutiple(list<string> inviteIdList);

	// 12.9.发送私密照片， filePath是使用《12.16.上传LiveChat相关附件》的返回参数“url”
	long SendPhoto(const string& targetId, const string& inviteId, const string& userId, const string& sid, const string& filePath);

	// 付费获取私密照片
	long PhotoFee(const string& targetId, const string& inviteId, const string& userId, const string& sid, const string& photoId);

	// 检查私密照片是否已付费
	long CheckPhoto(const string& targetId, const string& inviteId, const string& userId, const string& sid, const string& photoId);


	// 获取私密照片文件
	long GetPhoto(GETPHOTO_TOFLAG_TYPE toFlag
			, const string& targetId
			, const string& userId
			, const string& sid
			, const string& photoId
			, GETPHOTO_PHOTOSIZE_TYPE sizeType
			, GETPHOTO_PHOTOMODE_TYPE modeType
			, const string& filePath);

	// 上传语音文件
	long UploadVoice(const string& voiceCode, const string& inviteId, const string& mineId, bool isMan, const string& userId, OTHER_SITE_TYPE siteType, const string& fileType, int voiceLen, const string& filePath);

	// 获取语音文件
	long PlayVoice(const string& voiceId, OTHER_SITE_TYPE siteType, const string& filePath);

	/**
	 * 6.11.发送虚拟礼物
	 * @param womanId		女士ID
	 * @param vg_id			虚拟礼物ID
	 * @param device_id		设备唯一标识
	 * @param chat_id		livechat邀请ID或EMF邮件ID
	 * @param use_type		模块类型<UseType>
	 * @param user_sid		登录成功返回的sessionid
	 * @param user_id		登录成功返回的manid
	 * @return				请求唯一Id
	 */
	long SendGift(string womanId, string vg_id, string device_id, string chat_id, int use_type, string user_sid, string user_id);

	/**
	 * 6.12.获取最近已看微视频列表（http post）（New）
	 * @param womanId		女士ID
	 * @return				请求唯一Id
	 */
	long QueryRecentVideo(string user_sid, string user_id, string womanId);

	/**
	 * 6.13.获取微视频图片（http get）（New）
	 * @param womanId		女士ID
	 * @param videoid		视频ID
	 * @param type			图片尺寸
	 * @return				请求唯一Id
	 */
	long GetVideoPhoto(
			string user_sid,
			string user_id,
			string womanId,
			string videoid,
			VIDEO_PHOTO_TYPE type,
			const string& filePath
			);

	/**
	 * 6.14.获取微视频文件URL（http post）
	 * @param womanId		女士ID
	 * @param videoid		视频ID
	 * @param inviteid		邀请ID
	 * @param toflag		客户端类型（0：女士端，1：男士端）
	 * @param sendid		发送ID，在LiveChat收到女士端发出的消息中
	 * @return				请求唯一Id
	 */
	long GetVideo(
			string user_sid,
			string user_id,
			string womanId,
			string videoid,
			string inviteid,
			GETVIDEO_CLIENT_TYPE toflag,
			string sendid
			);
    
    // 12.16.上传LiveChat相关附件, file:照片二进制流（用于发送私密照前使用）
    long UploadManPhoto(const string& file);

	/**
	 * 6.15 查询小高级表情配置
	 */
	long GetMagicIconConfig();

	/**
	 * 6.16.开聊自动买点（http post）
	 * @param womanId		女士ID
	 */
	long ChatRecharge(
			string womanId,
			string user_sid,
			string user_id
			);

	/**
	 * 6.17.查询主题配置（http post）
	 * user_sid 用户SessionId
	 * user_id  用户Id
	 */
	long GetThemeConfig(
			string user_sid,
			string user_id
			);

	/**
	 * 6.18.获取指定主题（http post）
	 * themeIds 指定主题Id列表
	 * user_sid 用户SessionId
	 * user_id  用户Id
	 */
	long GetThemeDetail(
			string themeIds,
			string user_sid,
			string user_id
			);

	/**
	 * 6.19.检测功能是否开通（http post）
	 * @param founctions 功能列表
	 * @param deviceType 设备类型
	 * @param versionCode 版本号
	 * @param user_sid sessionId
	 * @param user_id 用户ID
	 */
	long CheckFunctions(
			string functions,
			TDEVICE_TYPE deviceType,
			string versionCode,
			string user_sid,
			string user_id);

protected:
	virtual void onSuccess(long requestId, string path, const char* buf, int size);
	virtual void onFail(long requestId, string path);
	virtual void onReceiveBody(long requestId, string path, const char* buf, int size);

private:
	string GetTempFilePath(const string& filePath);

private:
	ILSLiveChatRequestLiveChatControllerCallback* mLSLiveChatRequestLiveChatControllerCallback;

	void HandleQueryChatVirtualGift(TiXmlDocument &doc, list<LSLCGift> &giftList, int &totalCount,
			string &path, string &version);
	void HandleQueryRecentVideo(Json::Value root, list<LSLCVideoItem> &itemList);
	void HandleGetVideo(Json::Value root, string &url);
    void UploadManPhotoCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
};

#endif /* LSLIVECHATREQUESTLIVECHATCONTROLLER_H_ */
