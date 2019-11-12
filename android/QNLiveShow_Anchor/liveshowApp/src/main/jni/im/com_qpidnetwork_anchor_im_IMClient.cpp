/*
 * com_qpidnetwork_anchor_im_IMClient.cpp
 *
 *  Created on: 2017-05-31
 *      Author: Hunter.Mun
 * Description:	直播端IM相关接口
 */
#include "com_qpidnetwork_anchor_im_IMClient.h"
#include <ZBImClient.h>
#include "IMGlobalFunc.h"
#include "IMEnumJniConvert.h"

/******************** IMClient 相关全局变量    ***************************/
#define TAG "IMClientJni"

static IZBImClient* g_ImClient = NULL;
/* java listener object */
static jobject gListener = NULL;

/******************************* 底层Client Listener **************************/
class IMClientListener : public IZBImClientListener{
public:
	IMClientListener() {};
	virtual ~IMClientListener() {}
public:
	// ------------- 登录/注销 -------------
    virtual void OnZBLogin(ZBLCC_ERR_TYPE err, const string& errmsg, const ZBLoginReturnItem& item) override{
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
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jobject jloginItem = getLoginItem(env, item);
				env->CallVoidMethod(gListener, jCallback, errType, jerrmsg, jloginItem);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != jloginItem){
					env->DeleteLocalRef(jloginItem);
				}
				FileLog(TAG, "OnLogin() callback ok");
			} else {
                FileLog(TAG, "OnLogin() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}
		ReleaseEnv(isAttachThread);
    }

    virtual void OnZBLogout(ZBLCC_ERR_TYPE err, const string& errmsg) override{
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
			}else {
                FileLog(TAG, "OnLogout() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    //2.4.用户被挤掉线
    virtual void OnZBKickOff(ZBLCC_ERR_TYPE err, const string& errmsg)override{
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
			} else {
                FileLog(TAG, "OnKickOff() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    // ------------- 直播间处理(非消息) -------------


    // 3.1.新建/进入公开直播间接口 回调
    virtual void OnZBPublicRoomIn(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const ZBRoomInfoItem& item) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        //jint statu = LiveStatusToInt(ZBLIVESTATUS_RECIPROCALEND);
        //item.status = ZBLIVESTATUS_RECIPROCALEND;
        FileLog(TAG, "OnPublicRoomIn() callback, env:%p, isAttachThread:%d, reqId:%d, errType:%d, errmsg:%s statu;%d",
                env, isAttachThread, reqId, err, errMsg.c_str(), item.status);

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
            } else {
                FileLog(TAG, "OnPublicRoomIn() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }


    // 3.2.主播进入指定直播间回调
    virtual void OnZBRoomIn(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const ZBRoomInfoItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(TAG, "OnRoomIn() callback, env:%p, isAttachThread:%d, reqId:%d, errType:%d, errmsg:%s, status:%d",
				env, isAttachThread, reqId, err, errMsg.c_str(), item.status);

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
			} else {
                FileLog(TAG, "OnRoomIn() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    // 3.3.主播退出直播间
    virtual void OnZBRoomOut(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) override{
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
			} else {
                FileLog(TAG, "OnRoomOut() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    // 3.4.接收直播间关闭通知
    virtual void OnZBRecvRoomCloseNotice(const string& roomId, ZBLCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomCloseNotice() callback, env:%p, isAttachThread:%d, roomId:%s",
				env, isAttachThread, roomId.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomCloseNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomCloseNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, errType, jerrmsg);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jerrmsg);
				FileLog(TAG, "OnRecvRoomCloseNotice() callback ok");
			}else {
                FileLog(TAG, "OnRecvRoomCloseNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

     // 3.5.接收踢出直播间通知
    virtual void OnZBRecvRoomKickoffNotice(const string& roomId, ZBLCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomKickoffNotice() callback, env:%p, isAttachThread:%d, roomId:%s", env, isAttachThread, roomId.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomKickoffNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomKickoffNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				int jerrortype = IMErrorTypeToInt(err);
				env->CallVoidMethod(gListener, jCallback, jroomId, jerrortype, jerrMsg);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnRecvRoomKickoffNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvRoomKickoffNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    // 3.6.接收观众进入直播间通知
    virtual void OnZBRecvEnterRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl,
    		const string& riderId, const string& riderName, const string& riderUrl, int fansNum, bool isHasTicket) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvEnterRoomNotice() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s, photoUrl:%s, riderId:%s, "
				"riderName:%s, riderUrl:%s, fansNum:%d, isHasTicket;%d", env, isAttachThread, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(),
				riderId.c_str(), riderName.c_str(), riderUrl.c_str(), fansNum, isHasTicket);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IZ)V";
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
				env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, jphotoUrl, jriderId, jriderName, jriderUrl, fansNum, isHasTicket);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jphotoUrl);
				env->DeleteLocalRef(jriderId);
				env->DeleteLocalRef(jriderName);
				env->DeleteLocalRef(jriderUrl);
				FileLog(TAG, "OnRecvEnterRoomNotice() callback ok");
			}else {
                FileLog(TAG, "OnRecvEnterRoomNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }


    // 3.7.接收观众退出直播间通知
    virtual void OnZBRecvLeaveRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int fansNum) override{
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
			} else {
                FileLog(TAG, "OnRecvLeaveRoomNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    // 3.8.接收关闭直播间倒数通知
    virtual void OnZBRecvLeavingPublicRoomNotice(const string& roomId, int left_second, ZBLCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvLeavingPublicRoomNotice() callback, env:%p, isAttachThread:%d, roomId:%s, err:%d, errMsg:%s", env, isAttachThread,
				roomId.c_str(), err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;IILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLeavingPublicRoomNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvLeavingPublicRoomNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				int jerrortype = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, left_second, jerrortype, jerrMsg);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnRecvLeavingPublicRoomNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvLeavingPublicRoomNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    /**
     *  3.9.接收主播退出直播间通知回调
     *
     *  @param roomId       直播间ID
     *  @param anchorId     退出直播间的主播ID
     *
     */
    virtual void OnRecvAnchorLeaveRoomNotice(const string& roomId, const string& anchorId) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvAnchorLeaveRoomNotice() callback, env:%p, isAttachThread:%d, roomId:%s, anchorId:%s", env, isAttachThread,
                roomId.c_str(), anchorId.c_str());

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(Ljava/lang/String;Ljava/lang/String;)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchorLeaveRoomNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvAnchorLeaveRoomNotice() callback now");
                jstring jroomId = env->NewStringUTF(roomId.c_str());
                jstring janchorId = env->NewStringUTF(anchorId.c_str());
                env->CallVoidMethod(gListener, jCallback, jroomId, janchorId);
                env->DeleteLocalRef(jroomId);
                env->DeleteLocalRef(janchorId);
                FileLog(TAG, "OnRecvAnchorLeaveRoomNotice() callback ok");
            } else {
                FileLog(TAG, "OnRecvAnchorLeaveRoomNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

    /**
     *  3.11.主播切换推流通知回调
     *
     *  @param pushUrl      推流地址
     *  @param deviceType   终端类型
     *
     */
    virtual void OnAnchorSwitchFlow(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const list<string> pushUrl, IMDeviceType deviceType) override{
    		JNIEnv* env = NULL;
    		bool isAttachThread = false;
    		GetEnv(&env, &isAttachThread);
    		FileLog(TAG, "OnAnchorSwitchFlow() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s",
    				env, isAttachThread, reqId, err, errMsg.c_str());

    		//callback 回调
    		if(NULL != gListener){
    			jclass jCallbackCls = env->GetObjectClass(gListener);
    			string signure = "(IZILjava/lang/String;";
    			        signure += "[Ljava/lang/String;";   //  pushUrl
    			        signure += "I";                     //  deviceType
    			        signure += ")V";
    			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnAnchorSwitchFlow", signure.c_str());
    			if(NULL != jCallback){
    				FileLog(TAG, "OnAnchorSwitchFlow() callback now");
    				int errType = IMErrorTypeToInt(err);
    				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
    				jobjectArray jpushUrl = getJavaStringArray(env, pushUrl);
    				jint jdeviceType = IMDeviceTypeToInt(deviceType);
    				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, jpushUrl, jdeviceType);
    				env->DeleteLocalRef(jerrMsg);
    				if(NULL != jpushUrl){
                        env->DeleteLocalRef(jpushUrl);
                    }
    				FileLog(TAG, "OnAnchorSwitchFlow() callback ok");
    			} else {
                    FileLog(TAG, "OnAnchorSwitchFlow() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
                }
    		}

    		ReleaseEnv(isAttachThread);
    }


    // ------------- 直播间处理(消息) -------------
    // 4.1.发送直播间文本消息回调
    virtual void OnZBSendLiveChat(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) override{
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
			} else {
                FileLog(TAG, "OnSendRoomMsg() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    // 4.2.接收直播间文本消息
    virtual void OnZBRecvSendChatNotice(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomMsg() callback, env:%p, isAttachThread:%d, roomId:%s, fromId:%s, nickName:%s, msg:%s",
				env, isAttachThread, roomId.c_str(), fromId.c_str(), nickName.c_str(), msg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;[BLjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomMsg", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomMsg() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jfromId = env->NewStringUTF(fromId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());

//				jstring jmsg = env->NewStringUTF(msg.c_str());
				const char *pMessage = msg.c_str();
				int strLen = strlen(pMessage);
				jbyteArray byteArray = env->NewByteArray(strLen);
				env->SetByteArrayRegion(byteArray, 0, strLen, reinterpret_cast<const jbyte*>(pMessage));



				jstring jhonorUrl = env->NewStringUTF(honorUrl.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, level, jfromId, jnickName, byteArray, jhonorUrl);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jfromId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(byteArray);
				env->DeleteLocalRef(jhonorUrl);
				FileLog(TAG, "OnRecvRoomMsg() callback ok");
			} else {
                FileLog(TAG, "OnRecvRoomMsg() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    // 4.3.接收直播间公告消息回调
    virtual void OnZBRecvSendSystemNotice(const string& roomId, const string& msg, const string& link, ZBIMSystemType type) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvSendSystemNotice() callback, env:%p, isAttachThread:%d, roomId:%s, message:%s, link:%s type:%d",
				env, isAttachThread, roomId.c_str(), msg.c_str(), link.c_str(), type);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvSendSystemNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvSendSystemNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jmsg = env->NewStringUTF(msg.c_str());
				jstring jlink = env->NewStringUTF(link.c_str());
				jint jtype = IMSystemTypeToInt(type);
				env->CallVoidMethod(gListener, jCallback, jroomId, jmsg, jlink, jtype);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jmsg);
				env->DeleteLocalRef(jlink);
				FileLog(TAG, "OnRecvSendSystemNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvSendSystemNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    // 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
    virtual void OnZBSendGift(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendGift() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s",
				env, isAttachThread, reqId, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendGift", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendGift() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnSendGift() callback ok");
			} else {
                FileLog(TAG, "OnSendGift() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    // 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
    virtual void OnZBRecvSendGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId,
    		const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end,  int multi_click_id, const string& honorUrl, int totalCredit) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomGiftNotice() callback, env:%p, isAttachThread:%d, roomId:%s, fromId:%s, nickName:%s, giftId:%s, giftName:%s, giftNum:%d, mutiClick:%d, "
				"multiClickStart:%d, multiClickEnd:%d", env, isAttachThread, roomId.c_str(), fromId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum,
				multi_click?1:0, multi_click_start, multi_click_end);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IZIIILjava/lang/String;I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomGiftNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomGiftNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jfromId = env->NewStringUTF(fromId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring jgiftId = env->NewStringUTF(giftId.c_str());
				jstring jgiftName = env->NewStringUTF(giftName.c_str());
				jstring jhonorUrl = env->NewStringUTF(honorUrl.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jfromId, jnickName, jgiftId, jgiftName, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id, jhonorUrl, totalCredit);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jfromId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jgiftId);
				env->DeleteLocalRef(jgiftName);
				env->DeleteLocalRef(jhonorUrl);
				FileLog(TAG, "OnRecvRoomGiftNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvRoomGiftNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    // 6.1.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
    virtual void OnZBRecvSendToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomToastNotice() callback, env:%p, isAttachThread:%d, roomId:%s, fromId:%s, nickName:%s, msg:%s ",
				env, isAttachThread, roomId.c_str(), fromId.c_str(), nickName.c_str(), msg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[BLjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomToastNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomToastNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jfromId = env->NewStringUTF(fromId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());

//				jstring jmsg = env->NewStringUTF(msg.c_str());
				const char *pMessage = msg.c_str();
				int strLen = strlen(pMessage);
				jbyteArray byteArray = env->NewByteArray(strLen);
				env->SetByteArrayRegion(byteArray, 0, strLen, reinterpret_cast<const jbyte*>(pMessage));

				jstring jhonorUrl = env->NewStringUTF(honorUrl.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jfromId, jnickName, byteArray, jhonorUrl);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jfromId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(byteArray);
				env->DeleteLocalRef(jhonorUrl);
				FileLog(TAG, "OnRecvRoomToastNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvRoomToastNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    // ------------- 直播间才艺点播邀请 -------------
    /**
     *  7.1.接收直播间才艺点播邀请通知回调
     *
     *  @param talentRequestItem             才艺点播请求
     *
     */
    virtual void OnZBRecvTalentRequestNotice(const ZBTalentRequestItem talentRequestItem) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvTalentRequestNotice() callback, env:%p, isAttachThread:%d, talentInviteId:%s, name:%s, userId:%s, nickName:%s ",
                env, isAttachThread, talentRequestItem.talentInviteId.c_str(), talentRequestItem.name.c_str(), talentRequestItem.userId.c_str(), talentRequestItem.nickName.c_str());

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvTalentRequestNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvTalentRequestNotice() callback now");
                jstring jtalentInviteId = env->NewStringUTF(talentRequestItem.talentInviteId.c_str());
                jstring jname = env->NewStringUTF(talentRequestItem.name.c_str());
                jstring juserId = env->NewStringUTF(talentRequestItem.userId.c_str());
                jstring jnickName = env->NewStringUTF(talentRequestItem.nickName.c_str());
                env->CallVoidMethod(gListener, jCallback, jtalentInviteId, jname, juserId, jnickName);
                env->DeleteLocalRef(jtalentInviteId);
                env->DeleteLocalRef(jname);
                env->DeleteLocalRef(juserId);
                env->DeleteLocalRef(jnickName);
                FileLog(TAG, "OnRecvTalentRequestNotice() callback ok");

            } else {
                FileLog(TAG, "OnRecvTalentRequestNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

    // ------------- 直播间视频互动 -------------
    /**
     *  8.1.接收观众启动/关闭视频互动通知回调
     *
     *  @param Item            互动切换
     *
     */
    virtual void OnZBRecvControlManPushNotice(const ZBControlPushItem Item) override {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvControlManPushNotice() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s, avatarImg:%s ",
                env, isAttachThread, Item.roomId.c_str(), Item.userId.c_str(), Item.nickName.c_str(), Item.avatarImg.c_str());

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I[Ljava/lang/String;)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvInteractiveVideoNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvControlManPushNotice() callback now");

                jstring jroomId = env->NewStringUTF(Item.roomId.c_str());
                jstring juserId = env->NewStringUTF(Item.userId.c_str());
                jstring jnickName = env->NewStringUTF(Item.nickName.c_str());
                jstring javatarImg = env->NewStringUTF(Item.avatarImg.c_str());
                jobjectArray jmanVideoUrl = getJavaStringArray(env, Item.manVideoUrl);
                jint type = IMControlTypeToInt(Item.control);

                env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, javatarImg, type, jmanVideoUrl);
                env->DeleteLocalRef(jroomId);
                env->DeleteLocalRef(juserId);
                env->DeleteLocalRef(jnickName);
                env->DeleteLocalRef(javatarImg);
                if(NULL != jmanVideoUrl){
                    env->DeleteLocalRef(jmanVideoUrl);
                }
                FileLog(TAG, "OnRecvControlManPushNotice() callback ok");

            } else {
                FileLog(TAG, "OnRecvControlManPushNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

    //9.1.主播发送立即私密邀请 回调
    virtual void OnZBSendPrivateLiveInvite(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const ZBIMSendInviteInfoItem& infoItem) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendPrivateLiveInvite() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s,",
				env, isAttachThread, reqId, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;";
			        signure += "L";
			        signure += IM_SENDINVITEINFO_ITEM_CLASS;
			        signure += ";";
			        signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendImmediatePrivateInvite", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendPrivateLiveInvite() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				jobject roomInfoItem = getIMSendInviteInfoItem(env, infoItem);
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, roomInfoItem);
				env->DeleteLocalRef(jerrMsg);
				if(NULL != roomInfoItem){
                	env->DeleteLocalRef(roomInfoItem);
                }
				FileLog(TAG, "OnSendPrivateLiveInvite() callback ok");
			} else {
                FileLog(TAG, "OnSendPrivateLiveInvite() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }


    //9.2.接收立即私密邀请回复通知 回调
    void OnZBRecvInstantInviteReplyNotice(const string& inviteId, ZBReplyType replyType ,const string& roomId, ZBRoomType roomType, const string& userId,
    		const string& nickName, const string& avatarImg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvSendPrivateLiveInviteReplyNotice() callback, env:%p, isAttachThread:%d, inviteId:%s, replyType:%d, roomId:%s",
				env, isAttachThread, inviteId.c_str(), replyType, roomId.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvInviteReply", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvSendPrivateLiveInviteReplyNotice() callback now");
				jstring jinviteId = env->NewStringUTF(inviteId.c_str());
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring juserId = env->NewStringUTF(userId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring javatarImg = env->NewStringUTF(avatarImg.c_str());
				int jtype = InviteReplyTypeToInt(replyType);
				int jroomType = RoomTypeToInt(roomType);
				env->CallVoidMethod(gListener, jCallback, jinviteId, jtype, jroomId, jroomType, juserId, jnickName, javatarImg);
				env->DeleteLocalRef(jinviteId);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(javatarImg);
				FileLog(TAG, "OnRecvSendPrivateLiveInviteReplyNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvSendPrivateLiveInviteReplyNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    //9.3.接收主播立即私密邀请通知 回调

    virtual void OnZBRecvInstantInviteUserNotice(const string& userId, const string& nickName, const string& photoUrl ,const string& invitationId) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvAnchoeInviteNotify() callback, env:%p, isAttachThread:%d, userId:%s, nickName:%s, photoUrl:%s, invitationId:%s",
				env, isAttachThread, userId.c_str(), nickName.c_str(), photoUrl.c_str(), invitationId.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchoeInviteNotify", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvAnchoeInviteNotify() callback now");
				jstring juserId = env->NewStringUTF(userId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring jphotoUrl = env->NewStringUTF(photoUrl.c_str());
				jstring jinvitationId = env->NewStringUTF(invitationId.c_str());
				env->CallVoidMethod(gListener, jCallback, juserId, jnickName, jphotoUrl, jinvitationId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jphotoUrl);
				env->DeleteLocalRef(jinvitationId);
				FileLog(TAG, "OnRecvAnchoeInviteNotify() callback ok");
			} else {
                FileLog(TAG, "OnRecvAnchoeInviteNotify() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }


    //9.4.接收预约开始倒数通知
    virtual void OnZBRecvBookingNotice(const string& roomId, const string& userId, const string& nickName, const string& avatarImg, int leftSeconds) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvBookingNotice() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s, avatarImg:%s, leftSeconds:%d",
				env, isAttachThread, roomId.c_str(), userId.c_str(), nickName.c_str(), avatarImg.c_str(), leftSeconds);

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
				jstring javatarImg = env->NewStringUTF(avatarImg.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, javatarImg, leftSeconds);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(javatarImg);
				FileLog(TAG, "OnRecvBookingNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvBookingNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }

    /**
     *  9.5.获取指定立即私密邀请信息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param item             立即私密邀请
     *
     */
    virtual void OnZBGetInviteInfo(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const ZBPrivateInviteItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnGetInviteInfo() callback, env:%p, isAttachThread:%d, errType:%d, errmsg:%s", env, isAttachThread, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;";
			signure += "L";
			signure += IM_LOGIN_INVITE_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnGetInviteInfo", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnGetInviteInfo() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				jobject jinviteItem = getInviteItem(env, item);
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg, jinviteItem);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != jinviteItem){
					env->DeleteLocalRef(jinviteItem);
				}
				FileLog(TAG, "OnGetInviteInfo() callback ok");
			} else {
                FileLog(TAG, "OnGetInviteInfo() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
    }


    /**
     *  9.6.接收观众接受预约通知接口 回调
     *
     *  @param userId           观众ID
     *  @param nickName         观众昵称
     *  @param photoUrl         观众头像url
     *  @param invitationId     预约ID
     *  @param bookTime         预约时间（1970年起的秒数）
     */
    virtual void OnZBRecvInvitationAcceptNotice(const string& userId, const string& nickName, const string& photoUrl, const string& invitationId, long bookTime) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvInvitationAcceptNotice() callback, env:%p, isAttachThread:%d, userId:%s, nickName:%s, photoUrl:%s, invitationId:%s, bookTime:%d",
                env, isAttachThread, userId.c_str(), nickName.c_str(), photoUrl.c_str(), invitationId.c_str(), bookTime);

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvInvitationAcceptNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvInvitationAcceptNotice() callback now");
                jstring juserId = env->NewStringUTF(userId.c_str());
                jstring jnickName = env->NewStringUTF(nickName.c_str());
                jstring jphotoUrl = env->NewStringUTF(photoUrl.c_str());
                jstring jinvitationId = env->NewStringUTF(invitationId.c_str());
                env->CallVoidMethod(gListener, jCallback, juserId, jnickName, jphotoUrl, jinvitationId, bookTime);
                env->DeleteLocalRef(juserId);
                env->DeleteLocalRef(jnickName);
                env->DeleteLocalRef(jphotoUrl);
                env->DeleteLocalRef(jinvitationId);
                FileLog(TAG, "OnRecvInvitationAcceptNotice() callback ok");
            } else {
                FileLog(TAG, "OnRecvInvitationAcceptNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

	// ------------- 直播间视频互动 -------------
	/**
     *  10.1.进入多人互动直播间接口 回调
     *
     *  @param success      操作是否成功
     *  @param reqId        请求序列号
     *  @param errMsg      结果描述
     *  @param item        进入多人互动直播间信息
     *  @param expire      倒数进入秒数，倒数完成后再调用本接口重新进入
     *
     */
	virtual void OnAnchorEnterHangoutRoom(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const AnchorHangoutRoomItem& item, int expire) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnEnterHangoutRoom() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s, expire:%d",
				env, isAttachThread, reqId, err, errMsg.c_str(), expire);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;";
			signure +=	"L";
			signure +=	IM_HANGOUT_HANGOUTROOM_ITEM_CLASS;
			signure +=	";I)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnEnterHangoutRoom", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnEnterHangoutRoom() callback now");
				int errType = IMErrorTypeToInt(err);
				jobject roomInfoItem = getHangoutRoomItem(env, item);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg, roomInfoItem, expire);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != roomInfoItem){
					env->DeleteLocalRef(roomInfoItem);
				}
				FileLog(TAG, "OnEnterHangoutRoom() callback ok");
			} else {
                FileLog(TAG, "OnEnterHangoutRoom() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
	}

    /**
 *  10.2.退出多人互动直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg      结果描述
 *
 */
    virtual void OnAnchorLeaveHangoutRoom(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnLeaveHangoutRoom() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s",
                env, isAttachThread, reqId, err, errMsg.c_str());

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(IZILjava/lang/String;)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLeaveHangoutRoom", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnLeaveHangoutRoom() callback now");
                int errType = IMErrorTypeToInt(err);
                jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
                env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg);
                env->DeleteLocalRef(jerrmsg);
                FileLog(TAG, "OnLeaveHangoutRoom() callback ok");
            } else {
                FileLog(TAG, "OnLeaveHangoutRoom() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

    /**
     *  10.3.接收观众邀请多人互动通知接口 回调
     *
     *  @param item         观众邀请多人互动信息
     *
     */
    virtual void OnRecvAnchorInvitationHangoutNotice(const AnchorHangoutInviteItem& item) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvInvitationHangoutNotice() callback");

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(L";
            signure +=	IM_HANGOUT_HANGOUTINVITE_ITEM_CLASS;
            signure +=	";)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvInvitationHangoutNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvInvitationHangoutNotice() callback now");
                jobject roomInfoItem = getHangoutInviteItem(env, item);
                env->CallVoidMethod(gListener, jCallback, roomInfoItem);
                if(NULL != roomInfoItem){
                    env->DeleteLocalRef(roomInfoItem);
                }
                FileLog(TAG, "OnRecvInvitationHangoutNotice() callback ok");
            } else {
                FileLog(TAG, "OnRecvInvitationHangoutNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

/**
     *  10.4.接收推荐好友通知接口 回调
     *
     *  @param item         主播端接收自己推荐好友给观众的信息
     *
     */
	virtual void OnRecvAnchorRecommendHangoutNotice(const IMAnchorRecommendHangoutItem& item) override{
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvAnchorRecommendHangoutNotice() callback");

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(L";
            signure +=	IM_HANGOUT_HANGOUTRECOMMEND_ITEM_CLASS;
            signure +=	";)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchorRecommendHangoutNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvAnchorRecommendHangoutNotice() callback now");
                jobject jItem = getHangoutCommendItem(env, item);
                env->CallVoidMethod(gListener, jCallback, jItem);
                if(NULL != jItem){
                    env->DeleteLocalRef(jItem);
                }
                FileLog(TAG, "OnRecvAnchorRecommendHangoutNotice() callback ok");
            } else {
                FileLog(TAG, "OnRecvAnchorRecommendHangoutNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
	}

	/**
 *  10.5.接收敲门回复通知接口 回调
 *
 *  @param item         接收敲门回复信息
 *
 */
	virtual void OnRecvAnchorDealKnockRequestNotice(const IMAnchorKnockRequestItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvAnchorDealKnockRequestNotice() callback");

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure +=	IM_HANGOUT_KNOCKREQUEST_ITEM_CLASS;
			signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchorDealKnockRequestNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvAnchorDealKnockRequestNotice() callback now");
				jobject jItem = getDealKnockRequestItem(env, item);
				env->CallVoidMethod(gListener, jCallback, jItem);
				if(NULL != jItem){
					env->DeleteLocalRef(jItem);
				}
				FileLog(TAG, "OnRecvAnchorDealKnockRequestNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvAnchorDealKnockRequestNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
	}

	/**
 *  10.6.接收观众邀请其它主播加入多人互动通知接口 回调
 *
 *  @param item         接收观众邀请其它主播加入多人互动信息
 *
 */
	virtual void OnRecvAnchorOtherInviteNotice(const IMAnchorRecvOtherInviteItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvAnchorOtherInviteNotice() callback");

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure +=	IM_HANGOUT_OTHERINVITE_ITEM_CLASS;
			signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchorOtherInviteNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvAnchorOtherInviteNotice() callback now");
				jobject jItem = getOtherInviteItem(env, item);
				env->CallVoidMethod(gListener, jCallback, jItem);
				if(NULL != jItem){
					env->DeleteLocalRef(jItem);
				}
				FileLog(TAG, "OnRecvAnchorOtherInviteNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvAnchorOtherInviteNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
	}

	/**
 *  10.7.接收主播回复观众多人互动邀请通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
	virtual void OnRecvAnchorDealInviteNotice(const IMAnchorRecvDealInviteItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvAnchorDealInviteNotice() callback");

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure +=	IM_HANGOUT_DEALINVITE_ITEM_CLASS;
			signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchorDealInviteNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvAnchorDealInviteNotice() callback now");
				jobject jItem = getDealInviteItem(env, item);
				env->CallVoidMethod(gListener, jCallback, jItem);
				if(NULL != jItem){
					env->DeleteLocalRef(jItem);
				}
				FileLog(TAG, "OnRecvAnchorDealInviteNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvAnchorDealInviteNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
	}

	/**
 *  10.8.观众端/主播端接收观众/主播进入多人互动直播间通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
	virtual void OnRecvAnchorEnterRoomNotice(const IMAnchorRecvEnterRoomItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvAnchorEnterRoomNotice() callback");

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure +=	IM_HANGOUT_RECVENTERROOM_ITEM_CLASS;
			signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchorEnterRoomNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvAnchorEnterRoomNotice() callback now");
				jobject jItem = getEnterHangoutRoomItem(env, item);
				env->CallVoidMethod(gListener, jCallback, jItem);
				if(NULL != jItem){
					env->DeleteLocalRef(jItem);
				}
				FileLog(TAG, "OnRecvAnchorEnterRoomNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvAnchorEnterRoomNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
	}

	/**
 *  10.9.接收观众/主播退出多人互动直播间通知接口 回调
 *
 *  @param item         接收观众/主播退出多人互动直播间信息
 *
 */
	virtual void OnRecvAnchorLeaveRoomNotice(const IMAnchorRecvLeaveRoomItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvAnchorLeaveRoomNotice() callback");

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure +=	IM_HANGOUT_RECVLEAVEROOM_ITEM_CLASS;
			signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchorLeaveRoomNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvAnchorLeaveRoomNotice() callback now");
				jobject jItem = getLeaveHangoutRoomItem(env, item);
				env->CallVoidMethod(gListener, jCallback, jItem);
				if(NULL != jItem){
					env->DeleteLocalRef(jItem);
				}
				FileLog(TAG, "OnRecvAnchorLeaveRoomNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvAnchorLeaveRoomNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
	}

	/**
 *  10.10.接收观众/主播多人互动直播间视频切换通知接口 回调
 *
 *  @param roomId         直播间ID
 *  @param isAnchor       是否主播（0：否，1：是）
 *  @param userId         观众/主播ID
 *  @param playUrl        视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
 *
 */
	virtual void OnRecvAnchorChangeVideoUrl(const string& roomId, bool isAnchor, const string& userId, const list<string>& playUrl) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvAnchorChangeVideoUrl() callback");

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ZLjava/lang/String;[Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchorChangeVideoUrl", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvAnchorChangeVideoUrl() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring juserId = env->NewStringUTF(userId.c_str());
				jobjectArray jplayUrlArray = getJavaStringArray(env, playUrl);
				env->CallVoidMethod(gListener, jCallback, jroomId, isAnchor, juserId, jplayUrlArray);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				if(NULL != jplayUrlArray){
					env->DeleteLocalRef(jplayUrlArray);
				}
				FileLog(TAG, "OnRecvAnchorChangeVideoUrl() callback ok");
			} else {
                FileLog(TAG, "OnRecvAnchorChangeVideoUrl() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
	}

	/**
 *  10.11.发送多人互动直播间礼物消息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *
 */
	virtual void OnSendAnchorHangoutGift(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnSendAnchorHangoutGift() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s",
                env, isAttachThread, reqId, err, errMsg.c_str());

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(IZILjava/lang/String;)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendHangoutGift", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnSendAnchorHangoutGift() callback now");
                int errType = IMErrorTypeToInt(err);
                jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
                env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg);
                env->DeleteLocalRef(jerrmsg);
                FileLog(TAG, "OnSendAnchorHangoutGift() callback ok");
            } else {
                FileLog(TAG, "OnSendAnchorHangoutGift() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
	}

	/**
 *  10.12.接收多人互动直播间礼物通知接口 回调
 *
 *  @param item         接收多人互动直播间礼物信息
 *
 */
	virtual void OnRecvAnchorGiftNotice(const IMAnchorRecvGiftItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvAnchorGiftNotice() callback");

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure +=	IM_HANGOUT_RECVHANGOUTGIFT_ITEM_CLASS;
			signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchorGiftNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvAnchorGiftNotice() callback now");
				jobject jItem = getHangoutGiftItem(env, item);
				env->CallVoidMethod(gListener, jCallback, jItem);
				if(NULL != jItem){
					env->DeleteLocalRef(jItem);
				}
				FileLog(TAG, "OnRecvAnchorGiftNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvAnchorGiftNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
	}

    /**
 *  10.13.接收多人互动直播间观众启动/关闭视频互动通知回调
 *
 *  @param item            互动切换
 *
 */
    virtual void OnRecvAnchorControlManPushHangoutNotice(const ZBControlPushItem item) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvAnchorControlManPushHangoutNotice() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s, avatarImg:%s ",
                env, isAttachThread, item.roomId.c_str(), item.userId.c_str(), item.nickName.c_str(), item.avatarImg.c_str());

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I[Ljava/lang/String;)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvHangoutInteractiveVideoNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvAnchorControlManPushHangoutNotice() callback now");

                jstring jroomId = env->NewStringUTF(item.hangoutRoomId.c_str());
                jstring juserId = env->NewStringUTF(item.hangoutUserId.c_str());
                jstring jnickName = env->NewStringUTF(item.nickName.c_str());
                jstring javatarImg = env->NewStringUTF(item.avatarImg.c_str());
                jobjectArray jmanVideoUrl = getJavaStringArray(env, item.manVideoUrl);
                jint type = IMControlTypeToInt(item.control);

                env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, javatarImg, type, jmanVideoUrl);
                env->DeleteLocalRef(jroomId);
                env->DeleteLocalRef(juserId);
                env->DeleteLocalRef(jnickName);
                env->DeleteLocalRef(javatarImg);
                if(NULL != jmanVideoUrl){
                    env->DeleteLocalRef(jmanVideoUrl);
                }
                FileLog(TAG, "OnRecvAnchorControlManPushHangoutNotice() callback ok");

            } else {
                FileLog(TAG, "OnRecvAnchorControlManPushHangoutNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

	/**
 *  10.14.发送多人互动直播间文本消息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *
 */
	virtual void OnSendAnchorHangoutLiveChat(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) override {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendHangoutMsg() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s",
				env, isAttachThread, reqId, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendHangoutMsg", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendHangoutMsg() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg);
				env->DeleteLocalRef(jerrMsg);
				FileLog(TAG, "OnSendHangoutMsg() callback ok");
			} else {
				FileLog(TAG, "OnSendHangoutMsg() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
			}
		}

		ReleaseEnv(isAttachThread);
	}

	/**
 *  10.15.接收直播间文本消息回调
 *
 *  @param item            接收直播间的文本消息
 *
 */
	virtual void OnRecvAnchorHangoutChatNotice(const IMAnchorRecvHangoutChatItem& item) override {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvHangoutMsg() callback, env:%p, isAttachThread:%d, roomId:%s, fromId:%s, nickName:%s, msg:%s level;%d",
				env, isAttachThread, item.roomId.c_str(), item.fromId.c_str(), item.nickName.c_str(), item.msg.c_str(), item.level);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;[BLjava/lang/String;[Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvHangoutMsg", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvHangoutMsg() callback now");
				jstring jroomId = env->NewStringUTF(item.roomId.c_str());
				jstring jfromId = env->NewStringUTF(item.fromId.c_str());
				jstring jnickName = env->NewStringUTF(item.nickName.c_str());

//				jstring jmsg = env->NewStringUTF(msg.c_str());
				const char *pMessage = item.msg.c_str();
				int strLen = strlen(pMessage);
				jbyteArray byteArray = env->NewByteArray(strLen);
				env->SetByteArrayRegion(byteArray, 0, strLen, reinterpret_cast<const jbyte*>(pMessage));


				jstring jhonorUrl = env->NewStringUTF(item.honorUrl.c_str());
				jobjectArray jat = getJavaStringArray(env, item.at);
				env->CallVoidMethod(gListener, jCallback, jroomId, item.level, jfromId, jnickName, byteArray, jhonorUrl, jat);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jfromId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(byteArray);
				env->DeleteLocalRef(jhonorUrl);
				if(NULL != jat){
					env->DeleteLocalRef(jat);
				}
				FileLog(TAG, "OnRecvHangoutMsg() callback ok");
			} else {
				FileLog(TAG, "OnRecvHangoutMsg() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
			}
		}

		ReleaseEnv(isAttachThread);
	}


    /**
     *  10.16.接收进入多人互动直播间倒数通知回调
     *
     *  @param roomId            待进入的直播间ID
     *  @param anchorId          主播ID
     *  @param left_second       进入直播间的剩余秒数
     *
     */
    virtual void OnRecvAnchorCountDownEnterRoomNotice(const string& roomId, const string& anchorId, int leftSecond) override {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvAnchorCountDownEnterRoomNotice() callback, env:%p, isAttachThread:%d, roomId:%s, anchorId:%s, leftSecond:%d",
                env, isAttachThread, roomId.c_str(), anchorId.c_str(), leftSecond);

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(Ljava/lang/String;Ljava/lang/String;I)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchorCountDownEnterRoomNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvAnchorCountDownEnterRoomNotice() callback now");
                jstring jroomId = env->NewStringUTF(roomId.c_str());
                jstring janchorId = env->NewStringUTF(anchorId.c_str());;
                env->CallVoidMethod(gListener, jCallback, jroomId, janchorId, leftSecond);
                env->DeleteLocalRef(jroomId);
                env->DeleteLocalRef(janchorId);
                FileLog(TAG, "OnRecvAnchorCountDownEnterRoomNotice() callback ok");
            } else {
                FileLog(TAG, "OnRecvAnchorCountDownEnterRoomNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

	// ------------- 节目 -------------
	/**
     *  11.1.接收节目开播通知接口 回调
     *
     *  @param item         节目信息
     *  @param msg          消息提示文字
     *
     */
	virtual void OnRecvAnchorProgramPlayNotice(const IMAnchorProgramInfoItem& item, const string& msg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvProgramPlayNotice() callback");

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure +=	IM_PROGRAM_PROGRAMINFO_ITEM_CLASS;
			signure +=	";Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvProgramPlayNotice", signure.c_str());
            FileLog(TAG, "OnRecvProgramPlayNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvProgramPlayNotice() callback now");
				jobject jItem = getIMProgramInfoItem(env, item);
                jstring jmsg = env->NewStringUTF(msg.c_str());
				env->CallVoidMethod(gListener, jCallback, jItem, jmsg);
                env->DeleteLocalRef(jmsg);
				if(NULL != jItem){
					env->DeleteLocalRef(jItem);
				}
				FileLog(TAG, "OnRecvProgramPlayNotice() callback ok");
			} else {
                FileLog(TAG, "OnRecvProgramPlayNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
	}

	/**
     *  11.2.接收节目状态改变通知接口 回调
     *
     *  @param item         节目信息
     *
     */
	virtual void OnRecvAnchorChangeStatusNotice(const IMAnchorProgramInfoItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvChangeStatusNotice() callback");

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure +=	IM_PROGRAM_PROGRAMINFO_ITEM_CLASS;
			signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvChangeStatusNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvChangeStatusNotice() callback now");
				jobject jItem = getIMProgramInfoItem(env, item);
				env->CallVoidMethod(gListener, jCallback, jItem);
				if(NULL != jItem){
					env->DeleteLocalRef(jItem);
				}
				FileLog(TAG, "OnRecvChangeStatusNotice() callback ok");
			}else {
                FileLog(TAG, "OnRecvChangeStatusNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
		}

		ReleaseEnv(isAttachThread);
	}


    /**
     *  11.3.接收无操作的提示通知接口 回调
     *
     *  @param backgroundUrl 背景图url
     *  @param msg           描述
     *
     */
    virtual void OnRecvAnchorShowMsgNotice(const string& backgroundUrl, const string& msg) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvAnchorShowMsgNotice() callback backgroundUrl:%s msg:%s", backgroundUrl.c_str(), msg.c_str());

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(Ljava/lang/String;Ljava/lang/String;)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvShowMsgNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvAnchorShowMsgNotice() callback now");
                jstring jbackgroundUrl = env->NewStringUTF(backgroundUrl.c_str());
                jstring jmsg = env->NewStringUTF(msg.c_str());
                env->CallVoidMethod(gListener, jCallback, jbackgroundUrl, jmsg);
                env->DeleteLocalRef(jbackgroundUrl);
                env->DeleteLocalRef(jmsg);

                FileLog(TAG, "OnRecvAnchorShowMsgNotice() callback ok");
            }else {
                FileLog(TAG, "OnRecvAnchorShowMsgNotice() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

	// ------------- 多端功能 -------------
	/**
     *  12.1.多端获取预约邀请未读或代处理数量同步推送接口 回调
     *
     *  @param item         未读信息
     *
     */
    virtual void OnRecvGetScheduleListNReadNum(const ZBIMBookingUnreadUnhandleNumItem& item) override {
            JNIEnv* env = NULL;
            bool isAttachThread = false;
            GetEnv(&env, &isAttachThread);
            FileLog(TAG, "OnRecvGetScheduleListNReadNum() callback");

            //callback 回调
            if(NULL != gListener){
                jclass jCallbackCls = env->GetObjectClass(gListener);
                string signure = "(I";  // total
                        signure += "I"; // pendingNum
                        signure += "I"; // confirmedUnreadCount
                        signure += "I"; // otherUnreadCount
                        signure += ")V";
                jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvGetScheduleListNReadNum", signure.c_str());
                if(NULL != jCallback){
                    FileLog(TAG, "OnRecvGetScheduleListNReadNum() callback now");
                    env->CallVoidMethod(gListener, jCallback, item.totalNoReadNum, item.pendingNoReadNum, item.scheduledNoReadNum, item.historyNoReadNum);

                    FileLog(TAG, "OnRecvGetScheduleListNReadNum() callback ok");
                }else {
                    FileLog(TAG, "OnRecvGetScheduleListNReadNum() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
                }
            }

            ReleaseEnv(isAttachThread);
    }

    virtual void OnRecvGetScheduledAcceptNum(int scheduleNum) override {
            JNIEnv* env = NULL;
            bool isAttachThread = false;
            GetEnv(&env, &isAttachThread);
            FileLog(TAG, "OnRecvGetScheduledAcceptNum() callback scheduleNum:%d", scheduleNum);

            //callback 回调
            if(NULL != gListener){
                jclass jCallbackCls = env->GetObjectClass(gListener);
                string signure = "(I";  // scheduleNum
                        signure += ")V";
                jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvGetScheduledAcceptNum", signure.c_str());
                if(NULL != jCallback){
                    FileLog(TAG, "OnRecvGetScheduledAcceptNum() callback now");
                    env->CallVoidMethod(gListener, jCallback, scheduleNum);

                    FileLog(TAG, "OnRecvGetScheduledAcceptNum() callback ok");
                }else {
                    FileLog(TAG, "OnRecvGetScheduledAcceptNum() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
                }
            }

            ReleaseEnv(isAttachThread);
    }

    virtual void OnRecvNoreadShowNum(int num) override {
            JNIEnv* env = NULL;
            bool isAttachThread = false;
            GetEnv(&env, &isAttachThread);
            FileLog(TAG, "OnRecvNoreadShowNum() callback num:%d", num);

            //callback 回调
            if(NULL != gListener){
                jclass jCallbackCls = env->GetObjectClass(gListener);
                string signure = "(I";  // num
                        signure += ")V";
                jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvNoreadShowNum", signure.c_str());
                if(NULL != jCallback){
                    FileLog(TAG, "OnRecvNoreadShowNum() callback now");
                    env->CallVoidMethod(gListener, jCallback, num);

                    FileLog(TAG, "OnRecvNoreadShowNum() callback ok");
                }else {
                    FileLog(TAG, "OnRecvNoreadShowNum() callback jCallback:%p, signure:%s", jCallback, signure.c_str());
                }
            }

            ReleaseEnv(isAttachThread);
    }
};

static IMClientListener g_listener;


/******************************* 用户请求入口   ***********************************/
/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    IMSetLogDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_anchor_im_IMClient_IMSetLogDirectory
	(JNIEnv *env, jclass cls, jstring directory) {
	const char *cpDirectory = env->GetStringUTFChars(directory, 0);

	KLog::SetLogDirectory(cpDirectory);


	FileLog(TAG, "IMSetLogDirectory ( directory : %s ) ", cpDirectory);

	env->ReleaseStringUTFChars(directory, cpDirectory);
}

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    init
 * Signature: ([Ljava/lang/String;Lcom/qpidnetwork/livemodule/im/listener/IMClientListener;)V
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_init
  (JNIEnv *env, jclass cls, jobjectArray urlArray, jobject listener){
	bool result  = false;


	FileLog(TAG, "Init() listener:%p, urlArray:%p ", listener, urlArray);

	FileLog(TAG, "Init() IImClient::ReleaseClient(g_ImClient) g_ImClient:%p", g_ImClient);

	// 释放旧的ImClient

    if (g_ImClient != NULL) {

        IZBImClient::ReleaseClient(g_ImClient);
    }

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
			g_ImClient = IZBImClient::CreateClient();
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
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    GetReqId
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_qpidnetwork_anchor_im_IMClient_GetReqId
  (JNIEnv *env, jclass cls){
	int reqId = -1;
	if(NULL != g_ImClient){
		reqId = g_ImClient->GetReqId();
	}
	return reqId;
}

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    IsInvalidReqId
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_IsInvalidReqId
  (JNIEnv *env, jclass cls, jint reqId){
	bool isValid = false;
	if(NULL != g_ImClient){
		isValid = g_ImClient->IsInvalidReqId(reqId);
	}
	return isValid;
}

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    Login
 * Signature: (Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_Login
  (JNIEnv *env, jclass cls, jstring token){
	bool result = false;
	if(NULL != g_ImClient){
		string strToken = JString2String(env, token);
		FileLog(TAG, "Login() token:%s", strToken.c_str());
		result = g_ImClient->ZBLogin(strToken, ZBPAGENAMETYPE_MOVEPAGE);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    Logout
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_Logout
  (JNIEnv *env, jclass cls){
	bool result = false;
	if(NULL != g_ImClient){
		FileLog(TAG, "Logout()");
		result = g_ImClient->ZBLogout();
	}
	return result;
}


/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    PublicRoomIn
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_PublicRoomIn
        (JNIEnv *env, jclass cls, jint reqId){
    bool result = false;
    if(NULL != g_ImClient){
        FileLog(TAG, "PublicRoomIn() reqId: %d", reqId);
        result = g_ImClient->ZBPublicRoomIn(reqId);
    }
    return result;
}

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    RoomIn
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_RoomIn
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		FileLog(TAG, "RoomIn() reqId: %d, roomId:%s", reqId, strRoomId.c_str());
		result = g_ImClient->ZBRoomIn(reqId, strRoomId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    RoomOut
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_RoomOut
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId){
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		FileLog(TAG, "RoomOut() reqId: %d, roomId:%s", reqId, strRoomId.c_str());
		result = g_ImClient->ZBRoomOut(reqId, strRoomId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    AnchorSwitchFlow
 * Signature: (ILjava/lang/String;I)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_AnchorSwitchFlow
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jint deviceType) {
 	bool result = false;
 	if(NULL != g_ImClient){
 		string strRoomId = JString2String(env, roomId);
 		IMDeviceType jdeviceType = IntToIMDeviceType(deviceType);
 		FileLog(TAG, "AnchorSwitchFlow() reqId: %d, roomId:%s, deviceType:%d, jdeviceType:%d", reqId, strRoomId.c_str(), deviceType, jdeviceType);
 		result = g_ImClient->ZBAnchorSwitchFlow(reqId, strRoomId, jdeviceType);
 	}
 	return result;
 }

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    SendRoomMsg
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_SendRoomMsg
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
		result = g_ImClient->ZBSendLiveChat(reqId, strRoomId, strNickName, strMessage, targetIdList);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    SendGift
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZIZIII)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_SendGift
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
		result = g_ImClient->ZBSendGift(reqId, strRoomId, strNickName, strGiftId, strGiftName, isPackage, count, isMultiClick, multiStart, multiEnd, multiClickId);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    SendImmediatePrivateInvite
 * Signature: (ILjava/lang/String;Ljava/lang/String;Z)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_SendImmediatePrivateInvite
  (JNIEnv *env, jclass cls, jint reqId, jstring userId){

	bool result = false;
	if(NULL != g_ImClient){
		string strUserId = JString2String(env, userId);
        FileLog(TAG, "SendImmediatePrivateInvite() reqId: %d, userId:%s", reqId, strUserId.c_str());
		result = g_ImClient->ZBSendPrivateLiveInvite(reqId, strUserId, IMDEVICETYPE_APP);
	}
	return result;
}


/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    GetInviteInfo
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_GetInviteInfo
        (JNIEnv *env, jclass cls, jint reqId, jstring invitationId) {
    bool result = false;

    if(NULL != g_ImClient){
        string strInvitationId = JString2String(env, invitationId);
        FileLog(TAG, "GetInviteInfo() reqId: %d, strInvitationId:%s", reqId, strInvitationId.c_str());
        result = g_ImClient->ZBGetInviteInfo(reqId, strInvitationId);
    }
    return result;
}

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    EnterhangoutRoom
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_EnterHangoutRoom
	(JNIEnv *env, jclass cls, jint reqId, jstring roomId) {
	bool result = false;

	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		FileLog(TAG, "EnterHangoutRoom() reqId: %d, strRoomId:%s", reqId, strRoomId.c_str());
		result = g_ImClient->AnchorEnterHangoutRoom(reqId, strRoomId);
	}
	return result;
}


/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    LeaveHangoutRoom
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_LeaveHangoutRoom
        (JNIEnv *env, jclass cls, jint reqId, jstring roomId) {
    bool result = false;

    if(NULL != g_ImClient){
        string strRoomId = JString2String(env, roomId);
        FileLog(TAG, "LeaveHangoutRoom() reqId: %d, strRoomId:%s", reqId, strRoomId.c_str());
        result = g_ImClient->AnchorLeaveHangoutRoom(reqId, strRoomId);
    }
    return result;
}

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    SendHangoutGift
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZIZIIIZ)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_SendHangoutGift
        (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jstring nickName, jstring toUid, jstring giftId, jstring giftName, jboolean isBackPack, jint giftNum, jboolean isMultiClick, jint multiClickStart, jint multiClickEnd, jint multiClickId, jboolean isPrivate) {
    bool result = false;

    if(NULL != g_ImClient){
        string strRoomId = JString2String(env, roomId);
        string strNickName = JString2String(env, nickName);
        string strToUid = JString2String(env, toUid);
        string strGiftId = JString2String(env, giftId);
        string strGiftName = JString2String(env, giftName);
        FileLog(TAG, "SendHangoutGift() reqId: %d, strRoomId:%s, strNickName:%s, strToUid:%s, strGiftId:%s, strGiftName:%s, isBackPack:%d, giftNum:%d, isMultiClick:%d, multiClickStart:%d, multiClickEnd:%d, multiClickId:%d isPrivate:%d", reqId, strRoomId.c_str(), strNickName.c_str(), strToUid.c_str(), strGiftId.c_str(), strGiftName.c_str(), isBackPack, giftNum, isMultiClick, multiClickStart, multiClickEnd, multiClickId, isPrivate);
        result = g_ImClient->SendAnchorHangoutGift(reqId, strRoomId, strNickName, strToUid, strGiftId, strGiftName, isBackPack, giftNum, isMultiClick, multiClickStart, multiClickEnd, multiClickId, isPrivate);
    }
    return result;
}


/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    SendHangoutMsg
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_SendHangoutMsg
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

		FileLog(TAG, "SendHangoutMsg() reqId: %d, roomId:%s, nickName:%s, message:%s",
				reqId, strRoomId.c_str(), strNickName.c_str(), strMessage.c_str());
		result = g_ImClient->SendAnchorHangoutLiveChat(reqId, strRoomId, strNickName, strMessage, targetIdList);
	}
	return result;
}