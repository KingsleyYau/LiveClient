/*
 * com_qpidnetwork_im_IMClient.cpp
 *
 *  Created on: 2017-05-31
 *      Author: Hunter.Mun
 * Description:	直播端IM相关接口
 */
#include "com_qpidnetwork_im_IMClient.h"
#include <ImClient.h>
#include "IMGlobalFunc.h"
#include "IMEnumJniConvert.h"

/******************** IMClient 相关全局变量    ***************************/
#define TAG "IMClientJni"

static IImClient* g_ImClient = NULL;
/* java listener object */
static jobject gListener = NULL;

/******************************* 底层Client Listener **************************/
class IMClientListener : public IImClientListener{
public:
	IMClientListener() {};
	virtual ~IMClientListener() {}
public:
	// ------------- 登录/注销 -------------
    virtual void OnLogin(LCC_ERR_TYPE err, const string& errmsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnLogin() callback, env:%p, isAttachThread:%d, errType:%d, errmsg:%s", env, isAttachThread, err, errmsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(ILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLogin", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnLogin() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(gListener, jCallback, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
				FileLog(TAG, "OnLogin() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    virtual void OnLogout(LCC_ERR_TYPE err, const string& errmsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnLogout() callback, env:%p, isAttachThread:%d, errType:%d, errmsg:%s", env, isAttachThread, err, errmsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(ILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLogout", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnLogout() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(gListener, jCallback, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
				FileLog(TAG, "OnLogout() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //2.4.用户被挤掉线
    virtual void OnKickOff(const string reason)override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnKickOff() callback, env:%p, isAttachThread:%d, reason:%d", env, isAttachThread, reason.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnKickOff", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnKickOff() callback now");
				jstring jreason = env->NewStringUTF(reason.c_str());
				env->CallVoidMethod(gListener, jCallback, jreason);
				env->DeleteLocalRef(jreason);
				FileLog(TAG, "OnKickOff() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // ------------- 直播间处理(非消息) -------------
    // 观众进入直播间回调
    virtual void OnFansRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& userId, const string& nickName,
    		const string& photoUrl, const string& country, const list<string>& videoUrls, int fansNum, int contribute, const RoomTopFanList& fans) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnFansRoomIn() callback, env:%p, isAttachThread:%d, reqId:%d, errType:%d, errmsg:%s, userId:%s, nickName:%s, photoUrl:%s,"
				"country:%s, videoUrls.size:%d, fansNum:%d, contribute:%d, fans.size: %d", env, isAttachThread, reqId, err, errMsg.c_str(), userId.c_str(),
				nickName.c_str(), photoUrl.c_str(), country.c_str(), videoUrls.size(), fansNum,  contribute, fans.size());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;";
			signure +=	"L";
			signure +=	IM_ROOM_INFO_ITEM_CLASS;
			signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnFansRoomIn", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnFansRoomIn() callback now");
				int errType = IMErrorTypeToInt(err);
				jobject roomInfoItem = getRoomInfoItem(env, userId, nickName, photoUrl, country, videoUrls, fansNum, contribute, fans);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg, roomInfoItem);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != roomInfoItem){
					env->DeleteLocalRef(roomInfoItem);
				}
				FileLog(TAG, "OnFansRoomIn() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 观众退出直播间回调
    virtual void OnFansRoomOut(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnFansRoomOut() callback, env:%p, isAttachThread:%d, errType:%d, errmsg:%s", env, isAttachThread, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnFansRoomOut", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnFansRoomOut() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
				FileLog(TAG, "OnFansRoomOut() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收直播间关闭通知(观众)
    virtual void OnRecvRoomCloseFans(const string& roomId, const string& userId, const string& nickName, int fansNum) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomCloseFans() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s, fansNum:%d",
				env, isAttachThread, roomId.c_str(), userId.c_str(), nickName.c_str(), fansNum);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomCloseFans", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomCloseFans() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring juserId = env->NewStringUTF(userId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, fansNum);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				FileLog(TAG, "OnRecvRoomCloseFans() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收直播间关闭通知(直播)
    virtual void OnRecvRoomCloseBroad(const string& roomId, int fansNum, int inCome, int newFans, int shares, int duration) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomCloseBroad() callback, env:%p, isAttachThread:%d, roomId:%s, fansNum:%d, inCome:%d, newFans:%d, shares:%d, duration:%d",
				env, isAttachThread, roomId.c_str(), fansNum, inCome, newFans, shares, duration);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;IIIII)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomCloseBroad", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomCloseBroad() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, fansNum, inCome, newFans, shares, duration);
				env->DeleteLocalRef(jroomId);
				FileLog(TAG, "OnRecvRoomCloseBroad() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收观众进入直播间通知
    virtual void OnRecvFansRoomIn(const string& roomId, const string& userId, const string& nickName, const string& photoUrl) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvFansRoomIn() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s, photoUrl:%s",
				env, isAttachThread, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvFansRoomIn", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvFansRoomIn() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring juserId = env->NewStringUTF(userId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring jphotoUrl = env->NewStringUTF(photoUrl.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, jphotoUrl);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jphotoUrl);
				FileLog(TAG, "OnRecvFansRoomIn() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //3.6.获取直播间信息
    virtual void OnGetRoomInfo(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, int fansNum, int contribute) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnGetRoomInfo() callback, env:%p, isAttachThread:%d, fansNum:%d, contribute:%d", env, isAttachThread, fansNum, contribute);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;II)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomCloseBroad", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnGetRoomInfo() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg, fansNum, contribute);
				env->DeleteLocalRef(jerrmsg);
				FileLog(TAG, "OnGetRoomInfo() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //3.7.主播禁言观众（直播端把制定观众禁言）
    virtual void OnFansShutUp(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnFansShutUp() callback, env:%p, isAttachThread:%d, errType:%d, errmsg:%s", env, isAttachThread, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnAnchorForbidMessage", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnFansShutUp() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
				FileLog(TAG, "OnFansShutUp() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）
    virtual void OnRecvShutUpNotice(const string& roomId, const string& userId, const string& nickName, int timeOut) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvShutUpNotice() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s, timeOut:%d",
				env, isAttachThread, roomId.c_str(), userId.c_str(), nickName.c_str(), timeOut);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvShutUpNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvShutUpNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring juserId = env->NewStringUTF(userId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, timeOut);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				FileLog(TAG, "OnRecvShutUpNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 3.9.主播踢观众出直播间（主播端把指定观众踢出直播间）
    virtual void OnFansKickOffRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnFansKickOffRoom() callback, env:%p, isAttachThread:%d, errType:%d, errmsg:%s", env, isAttachThread, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnAnchorKickOffAudience", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnFansKickOffRoom() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
				FileLog(TAG, "OnFansKickOffRoom() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 3.10.接收观众踢出直播间通知（观众端／主播端接收观众踢出直播间通知）
    virtual void OnRecvKickOffRoomNotice(const string& roomId, const string& userId, const string& nickName) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvKickOffRoomNotice() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s",
				env, isAttachThread, roomId.c_str(), userId.c_str(), nickName.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvKickOffRoomNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvKickOffRoomNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring juserId = env->NewStringUTF(userId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				FileLog(TAG, "OnRecvKickOffRoomNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // ------------- 直播间处理(消息) -------------
    // 发送直播间文本消息回调
    virtual void OnSendRoomMsg(SEQ_T reqId, LCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendRoomMsg() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s",
				env, isAttachThread, reqId, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendRoomMsg", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendRoomMsg() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, errType, jerrMsg);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnSendRoomMsg() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收直播间文本消息通知
    virtual void OnRecvRoomMsg(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomMsg() callback, env:%p, isAttachThread:%d, roomId:%s, fromId:%s, nickName:%s, msg:%s",
				env, isAttachThread, roomId.c_str(), fromId.c_str(), nickName.c_str(), msg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomMsg", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomMsg() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jfromId = env->NewStringUTF(fromId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring jmsg = env->NewStringUTF(msg.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, level, jfromId, jnickName, jmsg);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jfromId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jmsg);
				FileLog(TAG, "OnRecvRoomMsg() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 5.1.发送直播间点赞消息（观众端向直播间发送点赞消息）
    virtual void OnSendRoomFav(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendRoomFav() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s",
				env, isAttachThread, reqId, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendLikeEvent", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendRoomFav() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnSendRoomFav() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }


    // 5.2.接收直播间点赞通知（观众端／主播端接收服务器的直播间点赞通知）
    virtual void OnRecvPushRoomFav(const string& roomId, const string& fromId, const string& nickName, bool isFirst) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvPushRoomFav() callback, env:%p, isAttachThread:%d, roomId:%s, fromId:%s, nickName:%s, isFirst:%d",
					env, isAttachThread, roomId.c_str(), fromId.c_str(), nickName.c_str(), isFirst?1:0);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Z)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvPushRoomFav", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvPushRoomFav() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jfromId = env->NewStringUTF(fromId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jfromId, jnickName, isFirst);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jfromId);
				env->DeleteLocalRef(jnickName);
				FileLog(TAG, "OnRecvPushRoomFav() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 6.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
    virtual void OnSendRoomGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double coins) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendRoomGift() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s, coins:%d",
				env, isAttachThread, reqId, err, errMsg.c_str(), coins);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;D)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendGift", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendRoomGift() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, coins);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnSendRoomGift() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 6.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
    virtual void OnRecvRoomGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId,
    		const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end,  int multi_click_id) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomGiftNotice() callback, env:%p, isAttachThread:%d, roomId:%s, fromId:%s, nickName:%s, giftId:%s, giftName:%s, giftNum:%d, mutiClick:%d, "
				"multiClickStart:%d, multiClickEnd:%d", env, isAttachThread, roomId.c_str(), fromId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum,
				multi_click?1:0, multi_click_start, multi_click_end);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IZIII)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomGiftNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomGiftNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jfromId = env->NewStringUTF(fromId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring jgiftId = env->NewStringUTF(giftId.c_str());
				jstring jgiftName = env->NewStringUTF(giftName.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jfromId, jnickName, jgiftId, jgiftName, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jfromId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jgiftId);
				env->DeleteLocalRef(jgiftName);
				FileLog(TAG, "OnRecvRoomGiftNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 7.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
    virtual void OnSendRoomToast(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double coins) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendRoomToast() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s, coins:%d",
				env, isAttachThread, reqId, err, errMsg.c_str(), coins);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;D)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendBarrage", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendRoomToast() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, coins);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnSendRoomToast() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 7.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
    virtual void OnRecvRoomToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomToastNotice() callback, env:%p, isAttachThread:%d, roomId:%s, fromId:%s, nickName:%s, msg:%s ",
				env, isAttachThread, roomId.c_str(), fromId.c_str(), nickName.c_str(), msg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomToastNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomToastNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jfromId = env->NewStringUTF(fromId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring jmsg = env->NewStringUTF(msg.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jfromId, jnickName, jmsg);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jfromId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jmsg);
				FileLog(TAG, "OnRecvRoomToastNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

};

static IMClientListener g_listener;


/******************************* 用户请求入口   ***********************************/
/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    init
 * Signature: ([Ljava/lang/String;Lcom/qpidnetwork/im/listener/IMClientListener;)V
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_init
  (JNIEnv *env, jclass cls, jobjectArray urlArray, jobject listener){
	bool result  = false;

	FileLog(TAG, "Init() listener:%p, urlArray:%p", listener, urlArray);

	FileLog(TAG, "Init() IImClient::ReleaseClient(g_ImClient) g_ImClient:%p", g_ImClient);

	// 释放旧的ImClient
	IImClient::ReleaseClient(g_ImClient);
	g_ImClient = NULL;

	FileLog(TAG, "Init() env->DeleteGlobalRef(gListener) gListener:%p", gListener);

	// 释放旧的listener
	if (NULL != gListener) {
		env->DeleteGlobalRef(gListener);
		gListener = NULL;
	}

	FileLog(TAG, "Init() get url array");

	// 获取url列表
	list<string> urlList;
	if (NULL != urlArray) {
		for (int i = 0; i < env->GetArrayLength(urlArray); i++) {
			jstring url = (jstring)env->GetObjectArrayElement(urlArray, i);
			string strUrl = JString2String(env, url);
			if (!strUrl.empty()) {
				urlList.push_back(strUrl);
			}
		}
	}

	FileLog(TAG, "Init() create client");

	if (NULL != listener
		&& !urlList.empty())
	{
		if (NULL == g_ImClient) {
			g_ImClient = IImClient::CreateClient();
			FileLog(TAG, "Init() IImClient::CreateClient() g_ImClient:%p", g_ImClient);
		}

		if (NULL != g_ImClient) {
			gListener = env->NewGlobalRef(listener);
			FileLog(TAG, "Init() gListener:%p", gListener);
			result = g_ImClient->Init(urlList);
			g_ImClient->AddListener(&g_listener);
		}
	}

	FileLog(TAG, "Init() result: %d", result);
	return result;
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    GetReqId
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_qpidnetwork_im_IMClient_GetReqId
  (JNIEnv *env, jclass cls){
	int reqId = -1;
	if(NULL != g_ImClient){
		reqId = g_ImClient->GetReqId();
	}
	return reqId;
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    IsInvalidReqId
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_IsInvalidReqId
  (JNIEnv *env, jclass cls, jint reqId){
	bool isValid = false;
	if(NULL != g_ImClient){
		isValid = g_ImClient->IsInvalidReqId(reqId);
	}
	return isValid;
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    Login
 * Signature: (Ljava/lang/String;Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_Login
  (JNIEnv *env, jclass cls, jstring userId, jstring token){
	bool result = false;
	if(NULL != g_ImClient){
		string strUserId = JString2String(env, userId);
		string strToken = JString2String(env, token);
		FileLog(TAG, "Login() user:%s, token:%s", strUserId.c_str(), strToken.c_str());
		result = g_ImClient->Login(strUserId, strToken, CLIENTTYPE_ANDROID);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    Logout
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_Logout
  (JNIEnv *env, jclass cls){
	bool result = false;
	if(NULL != g_ImClient){
		FileLog(TAG, "Logout()");
		result = g_ImClient->Logout();
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    GetUser
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_qpidnetwork_im_IMClient_GetUser
  (JNIEnv *env, jclass cls){
	string strUserId = "";
	if(NULL != g_ImClient){
		strUserId = g_ImClient->GetUser();
		FileLog(TAG, "GetUser() userId: %s", strUserId.c_str());
	}
	return env->NewStringUTF(strUserId.c_str());
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    FansRoomIn
 * Signature: (ILjava/lang/String;Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_FansRoomIn
  (JNIEnv *env, jclass cls, jint reqId, jstring token, jstring roomId){
	bool result = false;
	if(NULL != g_ImClient){
		string strToken = JString2String(env, token);
		string strRoomId = JString2String(env, roomId);
		FileLog(TAG, "FansRoomIn() reqId: %d, token:%s, roomId:%s", reqId, strToken.c_str(), strRoomId.c_str());
		result = g_ImClient->FansRoomIn(reqId, strToken, strRoomId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    FansRoomOut
 * Signature: (ILjava/lang/String;Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_FansRoomOut
  (JNIEnv *env, jclass cls, jint reqId, jstring token, jstring roomId){
	bool result = false;
	if(NULL != g_ImClient){
		string strToken = JString2String(env, token);
		string strRoomId = JString2String(env, roomId);
		FileLog(TAG, "FansRoomOut() reqId: %d, token:%s, roomId:%s", reqId, strToken.c_str(), strRoomId.c_str());
		result = g_ImClient->FansRoomOut(reqId, strToken, strRoomId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    GetRoomInfo
 * Signature: (ILjava/lang/String;Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_GetRoomInfo
  (JNIEnv *env, jclass cls, jint reqId, jstring token, jstring roomId){
	bool result = false;
	if(NULL != g_ImClient){
		string strToken = JString2String(env, token);
		string strRoomId = JString2String(env, roomId);
		FileLog(TAG, "GetRoomInfo() reqId: %d, token:%s, roomId:%s", reqId, strToken.c_str(), strRoomId.c_str());
		result = g_ImClient->GetRoomInfo(reqId, strToken, strRoomId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    AnchorForbidMessage
 * Signature: (ILjava/lang/String;Ljava/lang/String;I)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_AnchorForbidMessage
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jstring userId, jint time){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		string strUserId = JString2String(env, userId);
		FileLog(TAG, "AnchorForbidMessage() reqId: %d, roomId:%s, userId:%s,  time:%d", reqId, strRoomId.c_str(), strUserId.c_str(), time);
		result = g_ImClient->FansShutUp(reqId, strRoomId, strUserId, time);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    AnchorKickOffAudience
 * Signature: (ILjava/lang/String;Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_AnchorKickOffAudience
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jstring userId){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		string strUserId = JString2String(env, userId);
		FileLog(TAG, "AnchorKickOffAudience() reqId: %d, roomId:%s, userId:%s", reqId, strRoomId.c_str(), strUserId.c_str());
		result = g_ImClient->FansKickOffRoom(reqId, strRoomId, strUserId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    SendRoomMsg
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_SendRoomMsg
  (JNIEnv *env, jclass cls, jint reqId, jstring token, jstring roomId, jstring nickName, jstring message){
	bool result = false;
	if(NULL != g_ImClient){
		string strToken = JString2String(env, token);
		string strRoomId = JString2String(env, roomId);
		string strNickName = JString2String(env, nickName);
		string strMessage = JString2String(env, message);
		FileLog(TAG, "FansRoomIn() reqId: %d, token:%s, roomId:%s, nickName:%s, message:%s",
				reqId, strToken.c_str(), strRoomId.c_str(), strNickName.c_str(), strMessage.c_str());
		result = g_ImClient->SendRoomMsg(reqId, strToken, strRoomId, strNickName, strMessage);
	}
	return result;
}


/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    SendLikeEvent
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_SendLikeEvent
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jstring token, jstring nickName){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		string strToken = JString2String(env, token);
		string strNickName = JString2String(env, nickName);
		FileLog(TAG, "AnchorKickOffAudience() reqId: %d, roomId:%s, token:%s, strNickName:%s", reqId, strRoomId.c_str(), strToken.c_str(), strNickName.c_str());
		result = g_ImClient->SendRoomFav(reqId, strRoomId, strToken, strNickName);
	}
	return result;
}


/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    SendGift
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IZIII)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_SendGift
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jstring token, jstring nickName, jstring giftId, jstring giftName, jint count, jboolean isMultiClick,
		  jint multiStart, jint multiEnd, jint multiClickId){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		string strToken = JString2String(env, token);
		string strNickName = JString2String(env, nickName);
		string strGiftId = JString2String(env, giftId);
		string strGiftName= JString2String(env, giftName);
		FileLog(TAG, "AnchorKickOffAudience() reqId: %d, roomId:%s, token:%s, nickName:%s, giftId:%s, giftName:%s, count:%d, isMultiClick:%d, multiStart:%d, multiEnd:%d, multiClickId:%d",
				reqId, strRoomId.c_str(), strToken.c_str(), strNickName.c_str(), strGiftId.c_str(), strGiftName.c_str(), count, isMultiClick?1:0, multiStart, multiEnd, multiClickId);
		result = g_ImClient->SendRoomGift(reqId, strRoomId, strToken, strNickName, strGiftId, strGiftName, count, isMultiClick, multiStart, multiEnd, multiClickId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_im_IMClient
 * Method:    SendBarrage
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_im_IMClient_SendBarrage
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jstring token, jstring nickName, jstring message){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		string strToken = JString2String(env, token);
		string strNickName = JString2String(env, nickName);
		string strMessage = JString2String(env, message);
		FileLog(TAG, "AnchorKickOffAudience() reqId: %d, roomId:%s, token:%s, nickName:%s, message:%s",
				reqId, strRoomId.c_str(), strToken.c_str(), strNickName.c_str(), strMessage.c_str());
		result = g_ImClient->SendRoomToast(reqId, strRoomId, strToken, strNickName, strMessage);
	}
	return result;
}

