/*
 * LSLCRecord.h
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCRECORD_H_
#define LSLCRECORD_H_

#include <string>
using namespace std;


#include <json/json/json.h>
#include <common/Arithmetic.h>
#include "../LSLiveChatRequestLiveChatDefine.h"
#include "LSLCHttpScheduleInviteItem.h"
#include <common/KLog.h>

class LSLCRecord {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			if( root[LIVECHAT_TOFLAG].isString() ) {
				toflag = (LIVECHAT_RECODE_TOFLAG)atoi(root[LIVECHAT_TOFLAG].asString().c_str());
			}

			if( root[LIVECHAT_ADDDATE].isInt() ) {
				adddate = root[LIVECHAT_ADDDATE].asInt();
			}

			string message("");
			if (root[LIVECHAT_MSG].isString()) {
				message = root[LIVECHAT_MSG].asString();
			}

			if( root[LIVECHAT_MSGTYPE].isString() ) {
				int msgType = atoi(root[LIVECHAT_MSGTYPE].asString().c_str());
				switch(msgType) {
				case LRPM_TEXT:
				case LRPM_COUPON:
				case LRPM_AUTO_INVITE:
				case LIPM_INVITE_ASSISTANT:
				case LIPM_CAMSHARE_MESSAGE:{
					textMsg = message;
					messageType = LRM_TEXT;
				}break;
				case LRPM_INVITE:{
					inviteMsg = message;
					messageType = LRM_INVITE;
				}break;
				case LRPM_WARNING:{
					warningMsg = message;
					messageType = LRM_WARNING;
				}break;
				case LRPM_EMOTION:{
					emotionId = message;
					messageType = LRM_EMOTION;
				}break;
				case LRPM_VOICE:{
					voiceId = message;
					ParsingVoiceMsg(voiceId, voiceType, voiceTime);
					messageType = LRM_VOICE;
				}break;
				case LRPM_PHOTO:{
					ParsingPhotoMsg(message, photoId, photoSendId, photoDesc, photoCharge);
					messageType = LRM_PHOTO;
				}break;
				case LRPM_VIDEO:{
					ParsingVideoMsg(message, videoId, videoSendId, videoDesc, videoCharge);
					messageType = LRM_VIDEO;
				}break;
				case LRPM_MAGIC_ICON:{
					magicIconId = message;
					messageType = LRM_MAGIC_ICON;
				}break;
                    case LIPM_SCHEDULE_INVITE:{
                        Json::Value jRoot;
                        Json::Reader reader;
                        if( reader.parse(message, jRoot) ) {
                            if( jRoot.isObject() ) {
                                scheduleMsg.Parse(jRoot);
                            }
                        }
                        messageType = LRM_SCHEDULE;
                    }break;
				default:{
					messageType = LRM_UNKNOW;
				}break;
				}
			}
		}
	}

	LSLCRecord() {
		toflag = LRT_SEND;
		adddate = 0;
		messageType = LRM_UNKNOW;
		textMsg = "";
		inviteMsg = "";
		warningMsg = "";
		emotionId = "";
		photoId = "";
		photoSendId = "";
		photoDesc = "";
		photoCharge = false;
		voiceId = "";
		voiceType = "";
		voiceTime = 0;
		videoId = "";
		videoSendId = "";
		videoDesc = "";
		videoCharge = false;
		magicIconId = "";
	}
    
    LSLCRecord(const LSLCRecord& item) {
        toflag = item.toflag;
        adddate = item.adddate;
        messageType = item.messageType;
        textMsg = item.textMsg;
        inviteMsg = item.inviteMsg;
        warningMsg = item.warningMsg;
        emotionId = item.emotionId;
        photoId = item.photoId;
        photoSendId = item.photoSendId;
        photoDesc = item.photoDesc;
        photoCharge = item.photoCharge;
        voiceId = item.voiceId;
        voiceType = item.voiceType;
        voiceTime = item.voiceTime;
        videoId = item.videoId;
        videoSendId = item.videoSendId;
        videoDesc = item.videoDesc;
        videoCharge = item.videoCharge;
        magicIconId = item.magicIconId;
        scheduleMsg = item.scheduleMsg;
    }

	virtual ~LSLCRecord() {

	}

private:
	// 解析语音ID
	inline void ParsingVoiceMsg(const string& voiceId, string& fileType, int& timeLen)
	{
		char buffer[512] = {0};
		if (sizeof(buffer) > voiceId.length())
		{
			strcpy(buffer, voiceId.c_str());
			char* pIdItem = strtok(buffer, LIVECHAT_VOICEID_DELIMIT);
			int i = 0;
			while (NULL != pIdItem)
			{
				if (i == 4) {
					fileType = pIdItem;
				}
				else if (i == 5) {
					timeLen = atoi(pIdItem);
				}
				pIdItem = strtok(NULL, LIVECHAT_VOICEID_DELIMIT);
				i++;
			}
		}
	}

	// 解析img（图片信息）
	inline void ParsingPhotoMsg(const string& message, string& photoId, string& sendId, string& photoDesc, bool& charge)
	{
		size_t begin = 0;
		size_t end = 0;
		int i = 0;

		while (string::npos != (end = message.find_first_of(LIVECHAT_PHOTO_DELIMIT, begin)))
		{
			if (i == 0) {
				// photoId
				photoId = message.substr(begin, end - begin);
				begin = end + strlen(LIVECHAT_PHOTO_DELIMIT);
			}
			else if (i == 1) {
				// charget
				string strCharget = message.substr(begin, end - begin);
				charge = (strCharget==LIVECHAT_CHARGE_YES ? true : false);
				begin = end + strlen(LIVECHAT_PHOTO_DELIMIT);
			}
			else if (i == 2) {
				// photoDesc
				photoDesc = message.substr(begin, end - begin);
				const int bufferSize = 1024;
				char buffer[bufferSize] = {0};
				if (!photoDesc.empty() && photoDesc.length() < bufferSize) {
					Arithmetic::Base64Decode(photoDesc.c_str(), photoDesc.length(), buffer);
					photoDesc = buffer;
				}
				begin = end + strlen(LIVECHAT_PHOTO_DELIMIT);

				// sendId
				sendId = message.substr(begin);
				break;
			}
			i++;
		}
	}

	// 解析video（视频信息）
	inline void ParsingVideoMsg(const string& message, string& videoId, string& sendId, string& videoDesc, bool& charge)
	{
		size_t begin = 0;
		size_t end = 0;
		int i = 0;

		while (string::npos != (end = message.find_first_of(LIVECHAT_VIDEO_DELIMIT, begin)))
		{
			if (i == 0) {
				// videoId
				videoId = message.substr(begin, end - begin);
				begin = end + strlen(LIVECHAT_VIDEO_DELIMIT);
			}
			else if (i == 1) {
				// charget
				string strCharget = message.substr(begin, end - begin);
				charge = (strCharget==LIVECHAT_CHARGE_YES ? true : false);
				begin = end + strlen(LIVECHAT_VIDEO_DELIMIT);
			}
			else if (i == 2) {
				// videoDesc
				videoDesc = message.substr(begin, end - begin);
				const int bufferSize = 1024;
				char buffer[bufferSize] = {0};
				if (!videoDesc.empty() && videoDesc.length() < bufferSize) {
					Arithmetic::Base64Decode(videoDesc.c_str(), videoDesc.length(), buffer);
					videoDesc = buffer;
				}
				begin = end + strlen(LIVECHAT_VIDEO_DELIMIT);

				// sendId
				sendId = message.substr(begin);
				break;
			}
			i++;
		}
	}

public:
	/**
	 * 5.4.查询聊天记录
	 * @param toflag		发送类型
	 * @param adddate		消息生成时间
	 * @param messageType	消息类型
	 * @param textMsg		文本消息
	 * @param inviteMsg		邀请消息
	 * @param warningMsg	警告消息
	 * @param emotionId		高级表情ID
	 * @param photoId		图片ID
	 * @param photoSendId		图片发送ID
	 * @param photoDesc		图片描述
	 * @param photoCharge	图片是否已付费
	 * @param voiceId		语音ID
	 * @param voiceType		语音文件类型
	 * @param voiceTime		语音时长
	 * @param videoId		视频ID
	 * @param videoSendId	视频发送ID
	 * @param videoDesc		视频描述
	 * @param videoCharge	视频是否已付费
	 * @param magicIconId   小高表Id
     * @param scheduleMsg  预付费邀请消息
	 */
	LIVECHAT_RECODE_TOFLAG toflag;
	long adddate;
	LIVECHAT_RECORD_MSGTYPE messageType;
	string textMsg;
	string inviteMsg;
	string warningMsg;
	string emotionId;
	string photoId;
	string photoSendId;
	string photoDesc;
	bool photoCharge;
	string voiceId;
	string voiceType;
	int voiceTime;
	string videoId;
	string videoSendId;
	string videoDesc;
	bool videoCharge;
	string magicIconId;
    LSLCHttpScheduleInviteItem scheduleMsg;
};

#endif /* LSLCRECORD_H_ */
