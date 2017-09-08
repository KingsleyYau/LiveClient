/*
 * com_qpidnetwork_livemodule_im_IMClient.cpp
 *
 *  Created on: 2017-05-31
 *      Author: Hunter.Mun
 * Description:	直播端IM相关接口
 */
#include "com_qpidnetwork_livemodule_im_IMClient.h"
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
    virtual void OnLogin(LCC_ERR_TYPE err, const string& errmsg, const LoginReturnItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnLogin() callback, env:%p, isAttachThread:%d, errType:%d, errmsg:%s", env, isAttachThread, err, errmsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(ILjava/lang/String;";
			signure += "L";
			signure += IM_LOGIN_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLogin", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnLogin() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jobject jloginItem = getLoginItem(env, item);
				env->CallVoidMethod(gListener, jCallback, errType, jerrmsg, jloginItem);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != jloginItem){
					env->DeleteLocalRef(jloginItem);
				}
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
    virtual void OnKickOff(LCC_ERR_TYPE err, const string& errmsg)override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnKickOff() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(ILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnKickOff", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnKickOff() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(gListener, jCallback, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
				FileLog(TAG, "OnKickOff() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // ------------- 直播间处理(非消息) -------------

    // 观众进入直播间回调
    virtual void OnRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(TAG, "OnRoomIn() callback, env:%p, isAttachThread:%d, reqId:%d, errType:%d, errmsg:%s",
				env, isAttachThread, reqId, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;";
			signure +=	"L";
			signure +=	IM_ROOMIN_ITEM_CLASS;
			signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRoomIn", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRoomIn() callback now");
				int errType = IMErrorTypeToInt(err);
				jobject roomInfoItem = getRoomInItem(env, item);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg, roomInfoItem);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != roomInfoItem){
					env->DeleteLocalRef(roomInfoItem);
				}
				FileLog(TAG, "OnRoomIn() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 观众退出直播间回调
    virtual void OnRoomOut(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRoomOut() callback, env:%p, isAttachThread:%d, errType:%d, errmsg:%s", env, isAttachThread, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRoomOut", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRoomOut() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
				FileLog(TAG, "OnRoomOut() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收直播间关闭通知(观众)
    virtual void OnRecvRoomCloseNotice(const string& roomId, const string& userId, const string& nickName, LCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomCloseNotice() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s",
				env, isAttachThread, roomId.c_str(), userId.c_str(), nickName.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomCloseNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomCloseNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring juserId = env->NewStringUTF(userId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, errType, jerrmsg);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jerrmsg);
				FileLog(TAG, "OnRecvRoomCloseNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收观众进入直播间通知
    virtual void OnRecvEnterRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl,
    		const string& riderId, const string& riderName, const string& riderUrl, int fansNum) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvEnterRoomNotice() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s, photoUrl:%s, riderId:%s, "
				"riderName:%s, riderUrl:%s, fansNum:%d", env, isAttachThread, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(),
				riderId.c_str(), riderName.c_str(), riderUrl.c_str(), fansNum);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvEnterRoomNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvEnterRoomNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring juserId = env->NewStringUTF(userId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring jphotoUrl = env->NewStringUTF(photoUrl.c_str());
				jstring jriderId = env->NewStringUTF(riderId.c_str());
				jstring jriderName = env->NewStringUTF(riderName.c_str());
				jstring jriderUrl = env->NewStringUTF(riderUrl.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, jphotoUrl, jriderId, jriderName, jriderUrl, fansNum);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jphotoUrl);
				env->DeleteLocalRef(jriderId);
				env->DeleteLocalRef(jriderName);
				env->DeleteLocalRef(jriderUrl);
				FileLog(TAG, "OnRecvEnterRoomNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }


    // 接收观众退出直播间通知
    virtual void OnRecvLeaveRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int fansNum) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvLeaveRoomNotice() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s, photoUrl:%s, fansNum:%d",
				env, isAttachThread, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), fansNum);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLeaveRoomNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvLeaveRoomNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring juserId = env->NewStringUTF(userId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring jphotoUrl = env->NewStringUTF(photoUrl.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, jphotoUrl, fansNum);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jphotoUrl);
				FileLog(TAG, "OnRecvLeaveRoomNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收返点通知
    virtual void OnRecvRebateInfoNotice(const string& roomId, const RebateInfoItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRebateInfoNotice() callback, env:%p, isAttachThread:%d, roomId:%s", env, isAttachThread,
				roomId.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;";
			signure	+= "L";
			signure += IM_REBATE_ITEM_CLASS;
			signure += ";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRebateInfoNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRebateInfoNotice() callback now");
				jobject jrebateItem = getRebateItem(env, item);
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jrebateItem);
				env->DeleteLocalRef(jroomId);
				if(NULL != jrebateItem){
					env->DeleteLocalRef(jrebateItem);
				}
				FileLog(TAG, "OnRecvRebateInfoNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收关闭直播间倒数通知
    virtual void OnRecvLeavingPublicRoomNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvLeavingPublicRoomNotice() callback, env:%p, isAttachThread:%d, roomId:%s, err:%d, errMsg:%s", env, isAttachThread,
				roomId.c_str(), err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLeavingPublicRoomNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvLeavingPublicRoomNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				int jerrortype = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jerrortype, jerrMsg);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnRecvLeavingPublicRoomNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收踢出直播间通知
    virtual void OnRecvRoomKickoffNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg, double credit) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomKickoffNotice() callback, env:%p, isAttachThread:%d, roomId:%s", env, isAttachThread, roomId.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ILjava/lang/String;D)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomKickoffNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomKickoffNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				int jerrortype = IMErrorTypeToInt(err);
				env->CallVoidMethod(gListener, jCallback, jroomId, jerrortype, jerrMsg, credit);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnRecvRoomKickoffNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收充值通知
    virtual void OnRecvLackOfCreditNotice(const string& roomId, const string& msg, double credit) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvLackOfCreditNotice() callback, env:%p, isAttachThread:%d, roomId:%s, msg:%s, credit:%f", env, isAttachThread, roomId.c_str(),
				msg.c_str(), credit);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;D)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLackOfCreditNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvLackOfCreditNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jmsg = env->NewStringUTF(msg.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jmsg, credit);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jmsg);
				FileLog(TAG, "OnRecvLackOfCreditNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收定时扣费通知
    virtual void OnRecvCreditNotice(const string& roomId, double credit) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvCreditNotice() callback, env:%p, isAttachThread:%d, roomId:%s, credit:%f", env, isAttachThread, roomId.c_str(), credit);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;D)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvCreditNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvCreditNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, credit);
				env->DeleteLocalRef(jroomId);
				FileLog(TAG, "OnRecvCreditNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 直播间开播通知
    virtual void OnRecvWaitStartOverNotice(const string& roomId, int leftSeconds) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvWaitStartOverNotice() callback, env:%p, isAttachThread:%d, roomId:%s, leftSeconds:%d", env, isAttachThread, roomId.c_str(), leftSeconds);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLiveStart", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvWaitStartOverNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, leftSeconds);
				env->DeleteLocalRef(jroomId);
				FileLog(TAG, "OnRecvWaitStartOverNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 3.12.接收观众／主播切换视频流通知接口
    virtual void OnRecvChangeVideoUrl(const string& roomId, bool isAnchor, const string& playUrl) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvChangeVideoUrl() callback, env:%p, isAttachThread:%d, roomId:%s, isAnchor:%d, playUrl:%s", env, isAttachThread,
				roomId.c_str(), isAnchor?1:0, playUrl.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ZLjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvChangeVideoUrl", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvChangeVideoUrl() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jplayUrl = env->NewStringUTF(playUrl.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, isAnchor, jplayUrl);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jplayUrl);
				FileLog(TAG, "OnRecvChangeVideoUrl() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 3.13.观众进入公开直播间接口 回调
    virtual void OnPublicRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(TAG, "OnPublicRoomIn() callback, env:%p, isAttachThread:%d, reqId:%d, errType:%d, errmsg:%s",
				env, isAttachThread, reqId, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;";
			signure +=	"L";
			signure +=	IM_ROOMIN_ITEM_CLASS;
			signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnPublicRoomIn", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnPublicRoomIn() callback now");
				int errType = IMErrorTypeToInt(err);
				jobject roomInfoItem = getRoomInItem(env, item);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg, roomInfoItem);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != roomInfoItem){
					env->DeleteLocalRef(roomInfoItem);
				}
				FileLog(TAG, "OnPublicRoomIn() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // ------------- 直播间处理(消息) -------------
    // 4.1.发送直播间文本消息回调
    virtual void OnSendLiveChat(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendRoomMsg() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s",
				env, isAttachThread, reqId, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendRoomMsg", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendRoomMsg() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnSendRoomMsg() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 4.2.接收直播间文本消息通知
    virtual void OnRecvSendChatNotice(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg) override{
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

    // 4.3.接收直播间公告消息回调
    virtual void OnRecvSendSystemNotice(const string& roomId, const string& msg, const string& link) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvSendSystemNotice() callback, env:%p, isAttachThread:%d, roomId:%s, message:%s, link:%s",
				env, isAttachThread, roomId.c_str(), msg.c_str(), link.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvSendSystemNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvSendSystemNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jmsg = env->NewStringUTF(msg.c_str());
				jstring jlink = env->NewStringUTF(link.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jmsg, jlink);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jmsg);
				env->DeleteLocalRef(jlink);
				FileLog(TAG, "OnRecvSendSystemNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
    virtual void OnSendGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit, double rebateCredit) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendGift() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s, credit: %f, rebateCredit: %f",
				env, isAttachThread, reqId, err, errMsg.c_str(), credit, rebateCredit);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;DD)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendGift", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendGift() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, credit, rebateCredit);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnSendGift() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
    virtual void OnRecvSendGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId,
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

    // 6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
    virtual void OnSendToast(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit, double rebateCredit) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendRoomToast() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s, credit:%f, rebateCredit:%f",
				env, isAttachThread, reqId, err, errMsg.c_str(), credit, rebateCredit);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;DD)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendBarrage", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendRoomToast() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, credit, rebateCredit);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnSendRoomToast() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
    virtual void OnRecvSendToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg) override{
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

    //观众立即私密邀请 回调
    virtual void OnSendPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& invitationId, int timeOut, const string& roomId) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendPrivateLiveInvite() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s, invitationId:%s",
				env, isAttachThread, reqId, err, errMsg.c_str(), invitationId.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;Ljava/lang/String;ILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendImmediatePrivateInvite", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendPrivateLiveInvite() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				jstring jinviteId = env->NewStringUTF(invitationId.c_str());
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, jinviteId, timeOut, jroomId);
				env->DeleteLocalRef(jerrMsg);
				env->DeleteLocalRef(jinviteId);
				env->DeleteLocalRef(jroomId);
				FileLog(TAG, "OnSendPrivateLiveInvite() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //观众取消立即私密邀请 回调
    virtual void OnSendCancelPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& roomId) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendCancelPrivateLiveInvite() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s, roomId:%s",
				env, isAttachThread, reqId, err, errMsg.c_str(), roomId.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnCancelImmediatePrivateInvite", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendCancelPrivateLiveInvite() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, jroomId);
				env->DeleteLocalRef(jerrMsg);
				env->DeleteLocalRef(jroomId);
				FileLog(TAG, "OnSendCancelPrivateLiveInvite() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //接收立即私密邀请回复通知 回调
    void OnRecvInstantInviteReplyNotice(const string& inviteId, ReplyType replyType ,const string& roomId, RoomType roomType, const string& anchorId,
    		const string& nickName, const string& avatarImg, const string& msg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvSendPrivateLiveInviteReplyNotice() callback, env:%p, isAttachThread:%d, inviteId:%s, replyType:%d, roomId:%s",
				env, isAttachThread, inviteId.c_str(), replyType, roomId.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvInviteReply", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvSendPrivateLiveInviteReplyNotice() callback now");
				jstring jinviteId = env->NewStringUTF(inviteId.c_str());
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring janchorId = env->NewStringUTF(anchorId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring javatarImg = env->NewStringUTF(avatarImg.c_str());
				jstring jmsg = env->NewStringUTF(msg.c_str());
				int jtype = InviteReplyTypeToInt(replyType);
				int jroomType = RoomTypeToInt(roomType);
				env->CallVoidMethod(gListener, jCallback, jinviteId, jtype, jroomId, jroomType, janchorId, jnickName, javatarImg, jmsg);
				env->DeleteLocalRef(jinviteId);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(janchorId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(javatarImg);
				env->DeleteLocalRef(jmsg);
				FileLog(TAG, "OnRecvSendPrivateLiveInviteReplyNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //接收主播立即私密邀请通知 回调
    virtual void OnRecvInstantInviteUserNotice(const string& logId, const string& anchorId, const string& nickName ,const string& avatarImg, const string& msg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvAnchoeInviteNotify() callback, env:%p, isAttachThread:%d, logId:%s, anchorId:%s, nickName:%s, avatarImg:%s, msg:%s",
				env, isAttachThread, logId.c_str(), anchorId.c_str(), nickName.c_str(), avatarImg.c_str(), msg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchoeInviteNotify", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvAnchoeInviteNotify() callback now");
				jstring jlogId = env->NewStringUTF(logId.c_str());
				jstring janchorId = env->NewStringUTF(anchorId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring javatarImg = env->NewStringUTF(avatarImg.c_str());
				jstring jmsg = env->NewStringUTF(msg.c_str());
				env->CallVoidMethod(gListener, jCallback, jlogId, janchorId, jnickName, javatarImg, jmsg);
				env->DeleteLocalRef(jlogId);
				env->DeleteLocalRef(janchorId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(javatarImg);
				env->DeleteLocalRef(jmsg);
				FileLog(TAG, "OnRecvAnchoeInviteNotify() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //接收主播预约私密邀请通知 回调
    virtual void OnRecvScheduledInviteUserNotice(const string& inviteId, const string& anchorId ,const string& nickName, const string& avatarImg,
    		const string& msg)  override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvScheduledInviteNotify() callback, env:%p, isAttachThread:%d, inviteId:%s, anchorId:%s, nickName:%s, avatarImg:%s, msg:%s"
				"bookTime:%d, inviteId:%s", env, isAttachThread, inviteId.c_str(), anchorId.c_str(), nickName.c_str(), avatarImg.c_str(), msg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvScheduledInviteNotify", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvScheduledInviteNotify() callback now");
				jstring jinviteId = env->NewStringUTF(inviteId.c_str());
				jstring janchorId = env->NewStringUTF(anchorId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring javatarImg = env->NewStringUTF(avatarImg.c_str());
				jstring jmsg = env->NewStringUTF(msg.c_str());
				env->CallVoidMethod(gListener, jCallback, jinviteId, janchorId, jnickName, javatarImg, jmsg);
				env->DeleteLocalRef(jinviteId);
				env->DeleteLocalRef(janchorId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(javatarImg);
				env->DeleteLocalRef(jmsg);
				FileLog(TAG, "OnRecvScheduledInviteNotify() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //7.6.接收预约私密邀请回复通知 回调
    virtual void OnRecvSendBookingReplyNotice(const string& inviteId, AnchorReplyType replyType)  override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvSendBookingReplyNotice() callback, env:%p, isAttachThread:%d, inviteId:%s, replyType:%d", env, isAttachThread,
				inviteId.c_str(), replyType);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvSendBookingReplyNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvSendBookingReplyNotice() callback now");
				jstring jinviteId = env->NewStringUTF(inviteId.c_str());
				int jinviteReplyType = AnchorReplyTypeToInt(replyType);
				env->CallVoidMethod(gListener, jCallback, jinviteId, jinviteReplyType);
				env->DeleteLocalRef(jinviteId);
				FileLog(TAG, "OnRecvSendBookingReplyNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //7.7.接收预约开始倒数通知
    virtual void OnRecvBookingNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int leftSeconds) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvBookingNotice() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s, photoUrl:%s, leftSeconds:%d",
				env, isAttachThread, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), leftSeconds);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvBookingNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvBookingNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring juserId = env->NewStringUTF(userId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring jphotoUrl = env->NewStringUTF(photoUrl.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, jphotoUrl, leftSeconds);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jphotoUrl);
				FileLog(TAG, "OnRecvBookingNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //8.1.发送直播间才艺点播邀请 回调
    virtual void OnSendTalent(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& talentInviteId) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendTalent() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendTalent", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendTalent() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				jstring jtalentInviteId = env->NewStringUTF(talentInviteId.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, jtalentInviteId);
				env->DeleteLocalRef(jerrMsg);
				env->DeleteLocalRef(jtalentInviteId);
				FileLog(TAG, "OnSendTalent() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //8.2.接收直播间才艺点播回复通知
    virtual void OnRecvSendTalentNotice(const string& roomId, const string& talentInviteId, const string& talentId, const string& name,
    		double credit, TalentStatus status) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvSendTalentNotice() callback, env:%p, isAttachThread:%d, roomId:%s, talentInviteId:%s, talentId:%s, name:%s, "
				"credit:%f, status:%d", env, isAttachThread, roomId.c_str(), talentInviteId.c_str(), talentId.c_str(), name.c_str(), credit, status);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;DI)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvSendTalentNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvSendTalentNotice() callback now");
				int talentStatus = TalentInviteStatusToInt(status);
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jtalentInviteId = env->NewStringUTF(talentInviteId.c_str());
				jstring jtalentId = env->NewStringUTF(talentId.c_str());
				jstring jname = env->NewStringUTF(name.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jtalentInviteId, jtalentId, jname, credit, talentStatus);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jtalentInviteId);
				env->DeleteLocalRef(jtalentId);
				env->DeleteLocalRef(jname);
				FileLog(TAG, "OnRecvSendTalentNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //9.1.观众等级升级通知
    virtual void OnRecvLevelUpNotice(int level) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvLevelUpNotice() callback, env:%p, isAttachThread:%d, level:%d", env, isAttachThread, level);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLevelUpNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvLevelUpNotice() callback now");
				env->CallVoidMethod(gListener, jCallback, level);
				FileLog(TAG, "OnRecvLevelUpNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //9.2.观众亲密度升级通知
    virtual void OnRecvLoveLevelUpNotice(int loveLevel) override{
 		JNIEnv* env = NULL;
 		bool isAttachThread = false;
 		GetEnv(&env, &isAttachThread);
 		FileLog(TAG, "OnRecvLoveLevelUpNotice() callback, env:%p, isAttachThread:%d, loveLevel:%d", env, isAttachThread, loveLevel);

 		//callback 回调
 		if(NULL != gListener){
 			jclass jCallbackCls = env->GetObjectClass(gListener);
 			string signure = "(I)V";
 			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLoveLevelUpNotice", signure.c_str());
 			if(NULL != jCallback){
 				FileLog(TAG, "OnRecvLoveLevelUpNotice() callback now");
 				env->CallVoidMethod(gListener, jCallback, loveLevel);
 				FileLog(TAG, "OnRecvLoveLevelUpNotice() callback ok");
 			}
 		}

 		ReleaseEnv(isAttachThread);
     }

    //9.3.背包更新通知
    virtual void OnRecvBackpackUpdateNotice(const BackpackInfo& item) override{
 		JNIEnv* env = NULL;
 		bool isAttachThread = false;
 		GetEnv(&env, &isAttachThread);
 		FileLog(TAG, "OnRecvBackpackUpdateNotice() callback, env:%p, isAttachThread:%d", env, isAttachThread);

 		jobject jItem = getPackageUpdateItem(env, item);

 		//callback 回调
 		if(NULL != gListener){
 			jclass jCallbackCls = env->GetObjectClass(gListener);
 			string signure = "(";
 			signure += "L";
 			signure += IM_PACKAGE_UPDATE_ITEM_CLASS;
 			signure += ";";
 			signure += ")V";
 			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvBackpackUpdateNotice", signure.c_str());
 			if(NULL != jCallback){
 				FileLog(TAG, "OnRecvBackpackUpdateNotice() callback now");
 				env->CallVoidMethod(gListener, jCallback, jItem);
 				FileLog(TAG, "OnRecvBackpackUpdateNotice() callback ok");
 			}
 		}

 		if(NULL != jItem){
 			env->DeleteLocalRef(jItem);
 		}

 		ReleaseEnv(isAttachThread);
     }

};

static IMClientListener g_listener;


/******************************* 用户请求入口   ***********************************/
/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    init
 * Signature: ([Ljava/lang/String;Lcom/qpidnetwork/livemodule/im/listener/IMClientListener;)V
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_init
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
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    GetReqId
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_GetReqId
  (JNIEnv *env, jclass cls){
	int reqId = -1;
	if(NULL != g_ImClient){
		reqId = g_ImClient->GetReqId();
	}
	return reqId;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    IsInvalidReqId
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_IsInvalidReqId
  (JNIEnv *env, jclass cls, jint reqId){
	bool isValid = false;
	if(NULL != g_ImClient){
		isValid = g_ImClient->IsInvalidReqId(reqId);
	}
	return isValid;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    Login
 * Signature: (Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_Login
  (JNIEnv *env, jclass cls, jstring token){
	bool result = false;
	if(NULL != g_ImClient){
		string strToken = JString2String(env, token);
		FileLog(TAG, "Login() token:%s", strToken.c_str());
		result = g_ImClient->Login(strToken, PAGENAMETYPE_MOVEPAGE);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    Logout
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_Logout
  (JNIEnv *env, jclass cls){
	bool result = false;
	if(NULL != g_ImClient){
		FileLog(TAG, "Logout()");
		result = g_ImClient->Logout();
	}
	return result;
}


/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    RoomIn
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_RoomIn
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		FileLog(TAG, "RoomIn() reqId: %d, roomId:%s", reqId, strRoomId.c_str());
		result = g_ImClient->RoomIn(reqId, strRoomId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    RoomOut
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_RoomOut
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		FileLog(TAG, "RoomOut() reqId: %d, roomId:%s", reqId, strRoomId.c_str());
		result = g_ImClient->RoomOut(reqId, strRoomId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    PublicRoomIn
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_PublicRoomIn
  (JNIEnv *env, jclass cls, jint reqId, jstring anchorId){
	bool result = false;
	if(NULL != g_ImClient){
		string strAnchorId = JString2String(env, anchorId);
		FileLog(TAG, "PublicRoomIn() reqId: %d, strAnchorId:%s", reqId, strAnchorId.c_str());
		result = g_ImClient->PublicRoomIn(reqId, strAnchorId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    SendRoomMsg
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_SendRoomMsg
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jstring nickName, jstring message, jobjectArray targetIdsArray){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		string strNickName = JString2String(env, nickName);
		string strMessage = JString2String(env, message);

		// 获取url列表
		list<string> targetIdList;
		if (NULL != targetIdsArray) {
			for (int i = 0; i < env->GetArrayLength(targetIdsArray); i++) {
				jstring targetId = (jstring)env->GetObjectArrayElement(targetIdsArray, i);
				string strTargetId = JString2String(env, targetId);
				if (!strTargetId.empty()) {
					targetIdList.push_back(strTargetId);
				}
			}
		}

		FileLog(TAG, "SendRoomMsg() reqId: %d, roomId:%s, nickName:%s, message:%s",
				reqId, strRoomId.c_str(), strNickName.c_str(), strMessage.c_str());
		result = g_ImClient->SendLiveChat(reqId, strRoomId, strNickName, strMessage, targetIdList);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    SendGift
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZIZIII)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_SendGift
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jstring nickName, jstring giftId, jstring giftName, jboolean isPackage, jint count, jboolean isMultiClick,
		  jint multiStart, jint multiEnd, jint multiClickId){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		string strNickName = JString2String(env, nickName);
		string strGiftId = JString2String(env, giftId);
		string strGiftName= JString2String(env, giftName);
		FileLog(TAG, "SendGift() reqId: %d, roomId:%s, nickName:%s, giftId:%s, giftName:%s, count:%d, isMultiClick:%d, multiStart:%d, multiEnd:%d, multiClickId:%d",
				reqId, strRoomId.c_str(), strNickName.c_str(), strGiftId.c_str(), strGiftName.c_str(), count, isMultiClick?1:0, multiStart, multiEnd, multiClickId);
		result = g_ImClient->SendGift(reqId, strRoomId, strNickName, strGiftId, strGiftName, isPackage, count, isMultiClick, multiStart, multiEnd, multiClickId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    SendBarrage
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_SendBarrage
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jstring nickName, jstring message){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		string strNickName = JString2String(env, nickName);
		string strMessage = JString2String(env, message);
		FileLog(TAG, "SendBarrage() reqId: %d, roomId:%s, nickName:%s, message:%s",
				reqId, strRoomId.c_str(), strNickName.c_str(), strMessage.c_str());
		result = g_ImClient->SendToast(reqId, strRoomId, strNickName, strMessage);
	}
	return result;
}


/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    SendImmediatePrivateInvite
 * Signature: (ILjava/lang/String;Ljava/lang/String;Z)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_SendImmediatePrivateInvite
  (JNIEnv *env, jclass cls, jint reqId, jstring userId, jstring logId, jboolean force){
	bool result = false;
	if(NULL != g_ImClient){
		string strUserId = JString2String(env, userId);
		string strLogId = JString2String(env, logId);
		FileLog(TAG, "SendImmediatePrivateInvite() reqId: %d, userId:%s, strLogId:%S", reqId, strUserId.c_str(), strLogId.c_str());
		result = g_ImClient->SendPrivateLiveInvite(reqId, strUserId, strLogId, force);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    CancelImmediatePrivateInvite
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_CancelImmediatePrivateInvite
  (JNIEnv *env, jclass cls, jint reqId, jstring inviteId){
	bool result = false;
	if(NULL != g_ImClient){
		string strInviteId = JString2String(env, inviteId);
		FileLog(TAG, "CancelImmediatePrivateInvite() reqId: %d, inviteId:%s", reqId, strInviteId.c_str());
		result = g_ImClient->SendCancelPrivateLiveInvite(reqId, strInviteId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    SendTalentInvite
 * Signature: (ILjava/lang/String;Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_SendTalentInvite
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jstring talentId){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		string strTalentId = JString2String(env, talentId);
		FileLog(TAG, "CancelImmediatePrivateInvite() reqId: %d, strRoomId:%s, strTalentId:%s", reqId, strRoomId.c_str(), strTalentId.c_str());
		result = g_ImClient->SendTalent(reqId, strRoomId, strTalentId);
	}
	return result;
}

