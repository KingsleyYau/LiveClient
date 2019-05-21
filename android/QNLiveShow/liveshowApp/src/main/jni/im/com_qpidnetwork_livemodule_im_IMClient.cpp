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
    virtual void OnRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item, const IMAuthorityItem& priv) override{
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
			signure +=	";";
			signure +=	"L";
            signure +=	IM_AUTHORITY_ITEM_CLASS;
            signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRoomIn", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRoomIn() callback now");
				int errType = IMErrorTypeToInt(err);
				jobject roomInfoItem = getRoomInItem(env, item);
				jobject privItem = getIMAuthorityItemItem(env, priv);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg, roomInfoItem, privItem);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != roomInfoItem){
					env->DeleteLocalRef(roomInfoItem);
				}
				if(NULL != privItem){
                	env->DeleteLocalRef(privItem);
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
    virtual void OnRecvRoomCloseNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg, const IMAuthorityItem& priv) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomCloseNotice() callback, env:%p, isAttachThread:%d, roomId:%s",
				env, isAttachThread, roomId.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ILjava/lang/String;";
			signure += "L";
			signure += IM_AUTHORITY_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomCloseNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomCloseNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				jobject privItem = getIMAuthorityItemItem(env, priv);
				env->CallVoidMethod(gListener, jCallback, jroomId, errType, jerrmsg, privItem);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != privItem){
                	env->DeleteLocalRef(privItem);
                }
				FileLog(TAG, "OnRecvRoomCloseNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收观众进入直播间通知
    virtual void OnRecvEnterRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl,
    		const string& riderId, const string& riderName, const string& riderUrl, int fansNum, const string& honorImg, bool isHasTicket) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvEnterRoomNotice() callback, env:%p, isAttachThread:%d, roomId:%s, userId:%s, nickName:%s, photoUrl:%s, riderId:%s, "
				"riderName:%s, riderUrl:%s, fansNum:%d", env, isAttachThread, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(),
				riderId.c_str(), riderName.c_str(), riderUrl.c_str(), fansNum);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Z)V";
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
				jstring jhonorImg = env->NewStringUTF(honorImg.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, juserId, jnickName, jphotoUrl, jriderId, jriderName, jriderUrl, fansNum, jhonorImg, isHasTicket);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(juserId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jphotoUrl);
				env->DeleteLocalRef(jriderId);
				env->DeleteLocalRef(jriderName);
				env->DeleteLocalRef(jriderUrl);
				env->DeleteLocalRef(jhonorImg);
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
    virtual void OnRecvLeavingPublicRoomNotice(const string& roomId, int left_second, LCC_ERR_TYPE err, const string& errMsg, const IMAuthorityItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvLeavingPublicRoomNotice() callback, env:%p, isAttachThread:%d, roomId:%s, err:%d, errMsg:%s", env, isAttachThread,
				roomId.c_str(), err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;IILjava/lang/String;";
				signure += "L";
            	signure += IM_AUTHORITY_ITEM_CLASS;
            	signure += ";";
            	signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLeavingPublicRoomNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvLeavingPublicRoomNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				int jerrortype = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				jobject privItem = getIMAuthorityItemItem(env, item);
				env->CallVoidMethod(gListener, jCallback, jroomId, left_second, jerrortype, jerrMsg, privItem);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jerrMsg);
				if(NULL != privItem){
                    env->DeleteLocalRef(privItem);
                }
				FileLog(TAG, "OnRecvLeavingPublicRoomNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 接收踢出直播间通知
    virtual void OnRecvRoomKickoffNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg, double credit, const IMAuthorityItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomKickoffNotice() callback, env:%p, isAttachThread:%d, roomId:%s", env, isAttachThread, roomId.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;ILjava/lang/String;D";
							signure += "L";
                        	signure += IM_AUTHORITY_ITEM_CLASS;
                        	signure += ";";
                        	signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomKickoffNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomKickoffNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				int jerrortype = IMErrorTypeToInt(err);
				jobject privItem = getIMAuthorityItemItem(env, item);
				env->CallVoidMethod(gListener, jCallback, jroomId, jerrortype, jerrMsg, credit, privItem);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jerrMsg);
				if(NULL != privItem){
                   env->DeleteLocalRef(privItem);
                }
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
    virtual void OnRecvWaitStartOverNotice(const StartOverRoomItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvWaitStartOverNotice() callback, env:%p, isAttachThread:%d, roomId:%s, leftSeconds:%d", env, isAttachThread, item.roomId.c_str(), item.leftSeconds);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I[Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLiveStart", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvWaitStartOverNotice() callback now");
				jstring jroomId = env->NewStringUTF(item.roomId.c_str());
				jstring janchorId = env->NewStringUTF(item.anchorId.c_str());
				jstring jnickName = env->NewStringUTF(item.nickName.c_str());
				jstring javatarImg = env->NewStringUTF(item.avatarImg.c_str());
				//playUrl转Java数组
				jobjectArray jplayUrls = getJavaStringArray(env, item.playUrl);
				env->CallVoidMethod(gListener, jCallback, jroomId, janchorId, jnickName, javatarImg, item.leftSeconds, jplayUrls);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(janchorId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(javatarImg);
				if(NULL != jplayUrls){
					env->DeleteLocalRef(jplayUrls);
				}
				FileLog(TAG, "OnRecvWaitStartOverNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 3.12.接收观众／主播切换视频流通知接口
    virtual void OnRecvChangeVideoUrl(const string& roomId, bool isAnchor, const list<string>& playUrl, const string& userId = "") override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvChangeVideoUrl() callback, env:%p, isAttachThread:%d, roomId:%s, isAnchor:%d", env, isAttachThread,
				roomId.c_str(), isAnchor?1:0);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Z[Ljava/lang/String;Ljava/lang/String;)V";
            //string signure = "(Ljava/lang/String;Z[Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvChangeVideoUrl", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvChangeVideoUrl() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				//playUrl转Java数组
				jobjectArray jplayUrls = getJavaStringArray(env, playUrl);
                jstring juserId = env->NewStringUTF(userId.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, isAnchor, jplayUrls, juserId);
                //env->CallVoidMethod(gListener, jCallback, jroomId, isAnchor, jplayUrls);
				env->DeleteLocalRef(jroomId);
                env->DeleteLocalRef(juserId);
				if(NULL != jplayUrls){
					env->DeleteLocalRef(jplayUrls);
				}
				FileLog(TAG, "OnRecvChangeVideoUrl() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }


    // 3.13.观众进入公开直播间接口 回调
    virtual void OnPublicRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item, const IMAuthorityItem& priv) override{
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
			signure +=	";";
			signure +=	"L";
            signure +=	IM_AUTHORITY_ITEM_CLASS;
            signure +=	";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnPublicRoomIn", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnPublicRoomIn() callback now");
				int errType = IMErrorTypeToInt(err);
				jobject roomInfoItem = getRoomInItem(env, item);
				jobject privItem = getIMAuthorityItemItem(env, priv);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg, roomInfoItem, privItem);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != roomInfoItem){
					env->DeleteLocalRef(roomInfoItem);
				}
				if(NULL != privItem){
                	env->DeleteLocalRef(privItem);
                }
				FileLog(TAG, "OnPublicRoomIn() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    /**
     *  3.14.观众开始／结束视频互动接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param manPushUrl       观众视频流url
     *
     */
    virtual void OnControlManPush(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(TAG, "OnControlManPush() callback, env:%p, isAttachThread:%d, reqId:%d, errType:%d, errmsg:%s",
				env, isAttachThread, reqId, err, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;[Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnControlManPush", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnControlManPush() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				//manPushUrl转Java数组
				jobjectArray jmanUploadUrls = getJavaStringArray(env, manPushUrl);
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg, jmanUploadUrls);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != jmanUploadUrls){
					env->DeleteLocalRef(jmanUploadUrls);
				}
				FileLog(TAG, "OnControlManPush() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);

    }

    /**
     *  3.15.获取指定立即私密邀请信息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param item             立即私密邀请
     *
     */
    virtual void OnGetInviteInfo(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const PrivateInviteItem& item, const IMAuthorityItem& privItem) override{
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
			signure += "L";
            signure += IM_AUTHORITY_ITEM_CLASS;
            signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnGetInviteInfo", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnGetInviteInfo() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrmsg = env->NewStringUTF(errMsg.c_str());
				jobject jinviteItem = getInviteItem(env, item);
				jobject jprivItem = getIMAuthorityItemItem(env, privItem);
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrmsg, jinviteItem, jprivItem);
				env->DeleteLocalRef(jerrmsg);
				if(NULL != jinviteItem){
					env->DeleteLocalRef(jinviteItem);
				}
				if(NULL != jprivItem){
                	env->DeleteLocalRef(jprivItem);
                }
				FileLog(TAG, "OnGetInviteInfo() callback ok");
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
    virtual void OnRecvSendChatNotice(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) override{
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
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 4.3.接收直播间公告消息回调
    virtual void OnRecvSendSystemNotice(const string& roomId, const string& msg, const string& link, IMSystemType type) override{
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
    		const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end,  int multi_click_id, const string& honorUrl) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRoomGiftNotice() callback, env:%p, isAttachThread:%d, roomId:%s, fromId:%s, nickName:%s, giftId:%s, giftName:%s, giftNum:%d, mutiClick:%d, "
				"multiClickStart:%d, multiClickEnd:%d", env, isAttachThread, roomId.c_str(), fromId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum,
				multi_click?1:0, multi_click_start, multi_click_end);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IZIIILjava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRoomGiftNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRoomGiftNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jfromId = env->NewStringUTF(fromId.c_str());
				jstring jnickName = env->NewStringUTF(nickName.c_str());
				jstring jgiftId = env->NewStringUTF(giftId.c_str());
				jstring jgiftName = env->NewStringUTF(giftName.c_str());
				jstring jhonorUrl = env->NewStringUTF(honorUrl.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jfromId, jnickName, jgiftId, jgiftName, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id, jhonorUrl);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jfromId);
				env->DeleteLocalRef(jnickName);
				env->DeleteLocalRef(jgiftId);
				env->DeleteLocalRef(jgiftName);
				env->DeleteLocalRef(jhonorUrl);
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
    virtual void OnRecvSendToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) override{
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
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //观众立即私密邀请 回调
    virtual void OnSendPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& invitationId, int timeOut, const string& roomId, const IMInviteErrItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendPrivateLiveInvite() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s, invitationId:%s",
				env, isAttachThread, reqId, err, errMsg.c_str(), invitationId.c_str());

	   jobject errObject = NULL;

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;Ljava/lang/String;ILjava/lang/String;";
			signure += "L";
			signure += IM_INVITE_ERR_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendImmediatePrivateInvite", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendPrivateLiveInvite() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				jstring jinviteId = env->NewStringUTF(invitationId.c_str());
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				errObject = getIMInviteErrItem(env, item);
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, jinviteId, timeOut, jroomId, errObject);
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
    void OnRecvInstantInviteReplyNotice(const IMInviteReplyItem& replyItem) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvSendPrivateLiveInviteReplyNotice() callback, env:%p, isAttachThread:%d, inviteId:%s, replyType:%d, roomId:%s",
				env, isAttachThread, replyItem.inviteId.c_str(), replyItem.replyType, replyItem.roomId.c_str());

       jobject obj = NULL;
		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(";
			signure += "L";
			signure += IM_INVITE_REPLY_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvInviteReply", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvSendPrivateLiveInviteReplyNotice() callback now");
				jobject obj =  getIMInviteReplyItem(env, replyItem);

				env->CallVoidMethod(gListener, jCallback, obj);

				FileLog(TAG, "OnRecvSendPrivateLiveInviteReplyNotice() callback ok");
			}
		}

		if (obj != NULL) {
		    env->DeleteLocalRef(obj);
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
    virtual void OnRecvSendBookingReplyNotice(const BookingReplyItem& item)  override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvSendBookingReplyNotice() callback, env:%p, isAttachThread:%d, inviteId:%s, replyType:%d", env, isAttachThread,
				item.inviteId.c_str(),item.replyType);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(L";
            signure += IM_BOOKINGREPLY_ITEM_CLASS;
            signure += ";)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvSendBookingReplyNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvSendBookingReplyNotice() callback now");
                jobject jbookingReplyItem = getBookingReplyItem(env, item);
				env->CallVoidMethod(gListener, jCallback, jbookingReplyItem);
                if(NULL != jbookingReplyItem){
                    env->DeleteLocalRef(jbookingReplyItem);
                }
				FileLog(TAG, "OnRecvSendBookingReplyNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //7.7.接收预约开始倒数通知
    virtual void OnRecvBookingNotice(const string& roomId, const string& userId, const string& nickName, const string& avatarImg, int leftSeconds) override{
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
			}
		}

		ReleaseEnv(isAttachThread);
    }

    // 7.8.观众端是否显示主播立即私密邀请 回调
    virtual void OnSendInstantInviteUserReport(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnSendInstantInviteUserReport() callback, env:%p, isAttachThread:%d, reqId:%d, err:%d, errMsg:%s",
                env, isAttachThread, reqId, err, errMsg.c_str());

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(IZILjava/lang/String;)V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnInstantInviteUserReport", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnSendInstantInviteUserReport() callback now");
                int errType = IMErrorTypeToInt(err);
                jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
                env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg);
                env->DeleteLocalRef(jerrMsg);
                FileLog(TAG, "OnSendInstantInviteUserReport() callback ok");
            }
        }

        ReleaseEnv(isAttachThread);
    }

    //8.1.发送直播间才艺点播邀请 回调
    virtual void OnSendTalent(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& talentInviteId, const string& talentId) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnSendTalent() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendTalent", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnSendTalent() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				jstring jtalentInviteId = env->NewStringUTF(talentInviteId.c_str());
				jstring jtalentId = env->NewStringUTF(talentId.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, jtalentInviteId, jtalentId);
				env->DeleteLocalRef(jerrMsg);
				env->DeleteLocalRef(jtalentInviteId);
				env->DeleteLocalRef(jtalentId);
				FileLog(TAG, "OnSendTalent() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

    //8.2.接收直播间才艺点播回复通知
    virtual void OnRecvSendTalentNotice(const TalentReplyItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvSendTalentNotice() callback, env:%p, isAttachThread:%d, roomId:%s, talentInviteId:%s, talentId:%s, name:%s, "
				"credit:%f, status:%d", env, isAttachThread, item.roomId.c_str(), item.talentInviteId.c_str(), item.talentId.c_str(), item.name.c_str(), item.credit, item.status);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;DID";
			signure += "Ljava/lang/String;Ljava/lang/String;I";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvSendTalentNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvSendTalentNotice() callback now");
				int talentStatus = TalentInviteStatusToInt(item.status);
				jstring jroomId = env->NewStringUTF(item.roomId.c_str());
				jstring jtalentInviteId = env->NewStringUTF(item.talentInviteId.c_str());
				jstring jtalentId = env->NewStringUTF(item.talentId.c_str());
				jstring jname = env->NewStringUTF(item.name.c_str());
				jstring jgiftId = env->NewStringUTF(item.giftId.c_str());
				jstring jgiftName = env->NewStringUTF(item.giftName.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jtalentInviteId, jtalentId, jname, item.credit, talentStatus, item.rebateCredit, jgiftId, jgiftName, item.giftNum);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jtalentInviteId);
				env->DeleteLocalRef(jtalentId);
				env->DeleteLocalRef(jname);
				env->DeleteLocalRef(jgiftId);
				env->DeleteLocalRef(jgiftName);
				FileLog(TAG, "OnRecvSendTalentNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
    }

	/**
     *  8.3.接收直播间才艺点播提示公告通知 回调
     *
     *  @param roomId          直播间ID
     *  @param introduction    公告描述
     *
     */
	virtual void OnRecvTalentListNotice(const string& roomId, const string& introduction) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvTalentPromptNotice() callback, env:%p, isAttachThread:%d, roomId:%s, introduction:%s"
				, env, isAttachThread, roomId.c_str(), introduction.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(Ljava/lang/String;Ljava/lang/String;";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvTalentPromptNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvTalentPromptNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jstring jintroduction = env->NewStringUTF(introduction.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, jintroduction);
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jintroduction);
				FileLog(TAG, "OnRecvTalentPromptNotice() callback ok");
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
    virtual void OnRecvLoveLevelUpNotice(const IMLoveLevelItem& loveLevelItem) override{
 		JNIEnv* env = NULL;
 		bool isAttachThread = false;
 		GetEnv(&env, &isAttachThread);
 		FileLog(TAG, "OnRecvLoveLevelUpNotice() callback, env:%p, isAttachThread:%d, loveLevel:%d, anchorId:%s anchorName:%s", env, isAttachThread, loveLevelItem.loveLevel, loveLevelItem.anchorId.c_str(), loveLevelItem.anchorName.c_str());

		jobject jItem = getIMLoveLeveItem(env, loveLevelItem);
 		//callback 回调
 		if(NULL != gListener){
 			jclass jCallbackCls = env->GetObjectClass(gListener);
 			string signure = "(";
			signure += "L";
			signure += IM_HANGOUT_IMLOVELEVEL_ITEM_CLASS;
			signure += ";";
			signure += ")V";
 			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLoveLevelUpNotice", signure.c_str());
 			if(NULL != jCallback){
 				FileLog(TAG, "OnRecvLoveLevelUpNotice() callback now");
 				env->CallVoidMethod(gListener, jCallback, jItem);
 				FileLog(TAG, "OnRecvLoveLevelUpNotice() callback ok");
 			}
 		}

		if(NULL != jItem){
			env->DeleteLocalRef(jItem);
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

    //9.4.观众勋章升级通知
    virtual void OnRecvGetHonorNotice(const string& honorId, const string& honorUrl) override{
 		JNIEnv* env = NULL;
 		bool isAttachThread = false;
 		GetEnv(&env, &isAttachThread);
 		FileLog(TAG, "OnRecvGetHonorNotice() callback, env:%p, isAttachThread:%d, honorId:%s honorUrl:%s", env, isAttachThread, honorId.c_str(), honorUrl.c_str());

 		//callback 回调
 		if(NULL != gListener){
 			jclass jCallbackCls = env->GetObjectClass(gListener);
 			string signure = "(Ljava/lang/String;Ljava/lang/String;)V";
 			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvGetHonorNotice", signure.c_str());
 			if(NULL != jCallback){
 				jstring jhonorId = env->NewStringUTF(honorId.c_str());
 				jstring jhonorUrl = env->NewStringUTF(honorUrl.c_str());
 				FileLog(TAG, "OnRecvGetHonorNotice() callback now");
 				env->CallVoidMethod(gListener, jCallback, jhonorId, jhonorUrl);
 				env->DeleteLocalRef(jhonorId);
 				env->DeleteLocalRef(jhonorUrl);
 				FileLog(TAG, "OnRecvGetHonorNotice() callback ok");
 			}
 		}

		ReleaseEnv(isAttachThread);
     }

 // ------------- 多人互动直播间 -------------
	/**
 	*  10.1.接收主播推荐好友通知接口 回调
 	*
 	*  @param item         接收主播推荐好友通知
 	*
 	*/
	virtual void OnRecvRecommendHangoutNotice(const IMRecommendHangoutItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRecommendHangoutNotice() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		jobject jItem = getHangoutCommendItem(env, item);
		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure += IM_HANGOUT_RECOMMEND_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRecommendHangoutNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRecommendHangoutNotice() callback now");
				env->CallVoidMethod(gListener, jCallback, jItem);
				FileLog(TAG, "OnRecvRecommendHangoutNotice() callback ok");
			} else {
				FileLog(TAG, "OnRecvRecommendHangoutNotice( callback : %p, signure : %s )",
						jCallback, signure.c_str());
			}
		}
		if (jItem != NULL) {
			env->DeleteLocalRef(jItem);
		}

		ReleaseEnv(isAttachThread);
	}

/**
 *  10.2.接收主播回复观众多人互动邀请通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
	virtual void OnRecvDealInviteHangoutNotice(const IMRecvDealInviteItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvDealInviteHangoutNotice() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		jobject jItem = getHangoutDealInviteItem(env, item);
		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure += IM_HANGOUT_IMDEALINVITE_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvDealInvitationHangoutNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvDealInviteHangoutNotice() callback now");
				env->CallVoidMethod(gListener, jCallback, jItem);

				FileLog(TAG, "OnRecvDealInviteHangoutNotice() callback ok");
			} else {
				FileLog(TAG, "OnRecvDealInviteHangoutNotice( callback : %p, signure : %s )",
						jCallback, signure.c_str());
			}
		}

		if (jItem != NULL) {
			env->DeleteLocalRef(jItem);
		}
		ReleaseEnv(isAttachThread);
	}

	/**
 *  10.3.观众新建/进入多人互动直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg      结果描述
 *  @param item        进入多人互动直播间信息
 *
 */
	virtual void OnEnterHangoutRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const IMHangoutRoomItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnEnterHangoutRoom() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;";
			signure += "L";
			signure += IM_HANGOUT_IMHANGOUTROOM_ITEM_CLASS;
			signure += ";)V";

			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnEnterHangoutRoom", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnEnterHangoutRoom() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				jobject jitem = getHangoutRoomItem(env, item);
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, jitem);
				env->DeleteLocalRef(jerrMsg);
				if (jitem != NULL) {
					env->DeleteLocalRef(jitem);
				}

				FileLog(TAG, "OnEnterHangoutRoom() callback ok");
			} else {
				FileLog(TAG, "OnEnterHangoutRoom( callback : %p, signure : %s )",
						jCallback, signure.c_str());
			}
		}

		ReleaseEnv(isAttachThread);
	}

	/**
 *  10.4.退出多人互动直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg      结果描述
 *
 */
	virtual void OnLeaveHangoutRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnLeaveHangoutRoom() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(IZILjava/lang/String;";
			signure += ")V";

			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnLeaveHangoutRoom", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnLeaveHangoutRoom() callback now");
				int errType = IMErrorTypeToInt(err);
				jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg);
				env->DeleteLocalRef(jerrMsg);

				FileLog(TAG, "OnLeaveHangoutRoom() callback ok");
			} else {
				FileLog(TAG, "OnLeaveHangoutRoom( callback : %p, signure : %s )",
						jCallback, signure.c_str());
			}
		}

		ReleaseEnv(isAttachThread);
	}

/**
 *  10.5.接收观众/主播进入多人互动直播间通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
	virtual void OnRecvEnterHangoutRoomNotice(const IMRecvEnterRoomItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvEnterHangoutRoomNotice() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		jobject jItem = getRecvEnterHangoutRoomItem(env, item);
		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure += IM_HANGOUT_IMRECVENTERROOM_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvEnterHangoutRoomNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvEnterHangoutRoomNotice() callback now");
				env->CallVoidMethod(gListener, jCallback, jItem);
				FileLog(TAG, "OnRecvEnterHangoutRoomNotice() callback ok");
			} else {
				FileLog(TAG, "OnRecvEnterHangoutRoomNotice( callback : %p, signure : %s )",
						jCallback, signure.c_str());
			}
		}

		if (jItem != NULL) {
			env->DeleteLocalRef(jItem);
		}
		ReleaseEnv(isAttachThread);
	}

/**
 *  10.6.接收观众/主播退出多人互动直播间通知接口 回调
 *
 *  @param item         接收观众/主播退出多人互动直播间信息
 *
 */
	virtual void OnRecvLeaveHangoutRoomNotice(const IMRecvLeaveRoomItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "alextest:OnRecvLeaveHangoutRoomNotice() callback, env:%p, isAttachThread:%d err:%d", env, isAttachThread, item.errNo);

		jobject jItem = getRecvLeaveHangoutRoomItem(env, item);
		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure += IM_HANGOUT_IMRECVLEAVEROOM_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLeaveHangoutRoomNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvLeaveHangoutRoomNotice() callback now");
				env->CallVoidMethod(gListener, jCallback, jItem);
				FileLog(TAG, "OnRecvLeaveHangoutRoomNotice() callback ok");
			} else {
				FileLog(TAG, "OnRecvLeaveHangoutRoomNotice( callback : %p, signure : %s )",
						jCallback, signure.c_str());
			}
		}
		if (jItem != NULL) {
			env->DeleteLocalRef(jItem);
		}

		ReleaseEnv(isAttachThread);
	}

/**
  *  10.7.发送多人互动直播间礼物消息接口 回调
  *
  *  @param success          操作是否成功
  *  @param reqId            请求序列号
  *  @param errMsg           结果描述
  *
  */
    virtual void OnSendHangoutGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnSendHangoutGift() callback, env:%p, isAttachThread:%d credit:%f", env, isAttachThread, credit);

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(IZILjava/lang/String;D";
            signure += ")V";

            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendHangoutGift", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnSendHangoutGift() callback now");
                int errType = IMErrorTypeToInt(err);
                jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
                env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, credit);
                env->DeleteLocalRef(jerrMsg);

                FileLog(TAG, "OnSendHangoutGift() callback ok");
            } else {
                FileLog(TAG, "OnSendHangoutGift( callback : %p, signure : %s )",
                        jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

/**
 *  10.8.接收多人互动直播间礼物通知接口 回调
 *
 *  @param item         接收多人互动直播间礼物信息
 *
 */
    virtual void OnRecvHangoutGiftNotice(const IMRecvHangoutGiftItem& item) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvHangoutGiftNotice() callback, env:%p, isAttachThread:%d", env, isAttachThread);

        jobject jItem = getRecvHangoutGiftItem(env, item);
        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(L";
            signure += IM_HANGOUT_IMRECVHANGOUTGIFT_ITEM_CLASS;
            signure += ";";
            signure += ")V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvHangoutGiftNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvHangoutGiftNotice() callback now");
                env->CallVoidMethod(gListener, jCallback, jItem);
                FileLog(TAG, "OnRecvHangoutGiftNotice() callback ok");
            } else {
                FileLog(TAG, "OnRecvHangoutGiftNotice( callback : %p, signure : %s )",
                        jCallback, signure.c_str());
            }
        }
		if (jItem != NULL) {
			env->DeleteLocalRef(jItem);
		}

        ReleaseEnv(isAttachThread);
    }
/**
 *  10.9.接收主播敲门通知接口 回调
 *
 *  @param item         接收主播发起的敲门信息
 *
 */
    virtual void OnRecvKnockRequestNotice(const IMKnockRequestItem& item) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvKnockRequestNotice() callback, env:%p, isAttachThread:%d", env, isAttachThread);

        jobject jItem = getKnockRequestItem(env, item);
        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(L";
            signure += IM_HANGOUT_IMRECVKNOCKREQUEST_ITEM_CLASS;
            signure += ";";
            signure += ")V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvKnockRequestNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvKnockRequestNotice() callback now");
                env->CallVoidMethod(gListener, jCallback, jItem);
                FileLog(TAG, "OnRecvKnockRequestNotice() callback ok");
            } else {
                FileLog(TAG, "OnRecvKnockRequestNotice( callback : %p, signure : %s )",
                        jCallback, signure.c_str());
            }
        }

		if (jItem != NULL) {
			env->DeleteLocalRef(jItem);
		}

        ReleaseEnv(isAttachThread);
    }

    /**
 *  10.10.接收多人互动余额不足导致主播将要离开的通知接口 回调
 *
 *  @param item         观众账号余额不足信息
 *
 */
    virtual void OnRecvLackCreditHangoutNotice(const IMLackCreditHangoutItem& item) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnRecvLackCreditHangoutNotice() callback, env:%p, isAttachThread:%d", env, isAttachThread);

        jobject jItem = getLackCreditHangoutItem(env, item);
        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(L";
            signure += IM_HANGOUT_IMRECVLEAVEROOM_ITEM_CLASS;
            signure += ";";
            signure += ")V";
            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLackCreditHangoutNotice", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnRecvLackCreditHangoutNotice() callback now");
                env->CallVoidMethod(gListener, jCallback, jItem);
                FileLog(TAG, "OnRecvLackCreditHangoutNotice() callback ok");
            } else {
                FileLog(TAG, "OnRecvLackCreditHangoutNotice( callback : %p, signure : %s )",
                        jCallback, signure.c_str());
            }
        }
		if (jItem != NULL) {
			env->DeleteLocalRef(jItem);
		}

        ReleaseEnv(isAttachThread);
    }

    /**
     *  10.11.多人互动观众开始/结束视频互动接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param manPushUrl       观众视频流url
     *
     */
    virtual void OnControlManPushHangout(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnControlManPushHangout() callback, env:%p, isAttachThread:%d", env, isAttachThread);

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(IZILjava/lang/String;";
            signure += "[Ljava/lang/String;";
            signure += ")V";

            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnControlManPushHangout", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnControlManPushHangout() callback now");
                int errType = IMErrorTypeToInt(err);
                jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
                jobjectArray jmanPushUrl = getJavaStringArray(env, manPushUrl);
                env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg, jmanPushUrl);
                env->DeleteLocalRef(jerrMsg);

                if (NULL != jmanPushUrl) {
                    env->DeleteLocalRef(jmanPushUrl);
                }

                FileLog(TAG, "OnControlManPushHangout() callback ok");
            } else {
                FileLog(TAG, "OnControlManPushHangout( callback : %p, signure : %s )",
                        jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

    /**
 *  10.12.发送多人互动直播间文本消息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *
 */
    virtual void OnSendHangoutLiveChat(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override{
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(TAG, "OnSendHangoutRoomMsg() callback, env:%p, isAttachThread:%d", env, isAttachThread);

        //callback 回调
        if(NULL != gListener){
            jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(IZILjava/lang/String;";
            signure += ")V";

            jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendHangoutRoomMsg", signure.c_str());
            if(NULL != jCallback){
                FileLog(TAG, "OnSendHangoutRoomMsg() callback now");
                int errType = IMErrorTypeToInt(err);
                jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
                env->CallVoidMethod(gListener, jCallback, reqId, success, errType, jerrMsg);
                env->DeleteLocalRef(jerrMsg);

                FileLog(TAG, "OnSendHangoutRoomMsg() callback ok");
            } else {
                FileLog(TAG, "OnSendHangoutRoomMsg( callback : %p, signure : %s )",
                        jCallback, signure.c_str());
            }
        }

        ReleaseEnv(isAttachThread);
    }

	/**
 *  10.13.接收直播间文本消息接口 回调
 *
 *  @param item         接收直播间文本消息
 *
 */
	virtual void OnRecvHangoutChatNotice(const IMRecvHangoutChatItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvHangoutRoomMsg() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		jobject jItem = getHangoutChatItem(env, item);
		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure += IM_HANGOUT_IMHANGOUTMSG_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvHangoutRoomMsg", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvHangoutRoomMsg() callback now");
				env->CallVoidMethod(gListener, jCallback, jItem);
				FileLog(TAG, "OnRecvHangoutRoomMsg() callback ok");
			} else {
				FileLog(TAG, "OnRecvHangoutRoomMsg( callback : %p, signure : %s )",
						jCallback, signure.c_str());
			}
		}

		if (jItem != NULL) {
			env->DeleteLocalRef(jItem);
		}

		ReleaseEnv(isAttachThread);
	}

	/**
  *  10.14.接收进入多人互动直播间倒数通知接口 回调
  *
  *  @param roomId         待进入的直播间ID
  *  @param anchorId       主播ID
  *  @param leftSecond     进入直播间的剩余秒数
  *
  */
	virtual void OnRecvAnchorCountDownEnterHangoutRoomNotice(const string& roomId, const string& anchorId, int leftSecond) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvAnchorCountDownEnterHangoutRoomNotice() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		jobject jItem = getHangoutCountDownItem(env, roomId, anchorId, leftSecond);
		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure += IM_HANGOUT_IMHANGOUTCOUNTDOWN_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvAnchorCountDownEnterHangoutRoomNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvAnchorCountDownEnterHangoutRoomNotice() callback now");
				env->CallVoidMethod(gListener, jCallback, jItem);
				FileLog(TAG, "OnRecvAnchorCountDownEnterHangoutRoomNotice() callback ok");
			} else {
				FileLog(TAG, "OnRecvAnchorCountDownEnterHangoutRoomNotice( callback : %p, signure : %s )",
						jCallback, signure.c_str());
			}
		}

		if (jItem != NULL) {
			env->DeleteLocalRef(jItem);
		}

		ReleaseEnv(isAttachThread);
	}

    // 10.15.接收主播Hang-out邀请通知
	virtual void OnRecvHandoutInviteNotice(const IMHangoutInviteItem& item) override {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvHandoutInviteNotice() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		jobject jItem = getIMHangoutInviteItem(env, item);
		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(L";
			signure += IM_HANGOUT_IMHANGOUTINVITE_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvHandoutInviteNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvHandoutInviteNotice() callback now");
				env->CallVoidMethod(gListener, jCallback, jItem);
				FileLog(TAG, "OnRecvHandoutInviteNotice() callback ok");
			} else {
				FileLog(TAG, "OnRecvHandoutInviteNotice( callback : %p, signure : %s )",
						jCallback, signure.c_str());
			}
		}

		if (jItem != NULL) {
			env->DeleteLocalRef(jItem);
		}

		ReleaseEnv(isAttachThread);
	}

	// 10.16.接收Hangout直播间男士信用点不足两个周期通知
	virtual void OnRecvHangoutCreditRunningOutNotice(const string& roomId, LCC_ERR_TYPE errNo, const string& errMsg) override {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvHandoutInviteNotice() callback, env:%p, isAttachThread:%d, roomId:%s, errNo:%d, errMsg:%s", env, isAttachThread, roomId.c_str(), errNo, errMsg.c_str());

		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(";
			signure += "Ljava/lang/String;ILjava/lang/String;";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvHangoutCreditRunningOutNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvHangoutCreditRunningOutNotice() callback now");
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				int errType = IMErrorTypeToInt(errNo);
                jstring jerrMsg = env->NewStringUTF(errMsg.c_str());
				env->CallVoidMethod(gListener, jCallback, jroomId, errType, jerrMsg);
				FileLog(TAG, "OnRecvHangoutCreditRunningOutNotice() callback ok");
				env->DeleteLocalRef(jroomId);
				env->DeleteLocalRef(jerrMsg);
			} else {
				FileLog(TAG, "OnRecvHangoutCreditRunningOutNotice( callback : %p, signure : %s )",
						jCallback, signure.c_str());
			}
		}

		ReleaseEnv(isAttachThread);
	}

// ------------- 节目 -------------
	/**
     *  11.1.接收节目开播通知接口 回调
     *

     *  @param item       节目信息
     *  @param type       通知类型（1：已购票的开播通知，2：仅关注的开播通知）
     *  @param msg        消息提示文字
     *
     */
	virtual void OnRecvProgramPlayNotice(const IMProgramItem& item, IMProgramNoticeType type, const string& msg) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvProgramPlayNotice() callback, env:%p, isAttachThread:%d, type:%d msg:%s", env, isAttachThread, type, msg.c_str());

        jobject jItem = getIMProgramInfoItem(env,item);
		//callback 回调
		if(NULL != gListener){
			jclass jCallbackCls = env->GetObjectClass(gListener);
            string signure = "(";
            signure += "L";
            signure += IM_PROGRAM_PROGRAMINFO_ITEM_CLASS;
            signure += ";ILjava/lang/String;";
            signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvProgramPlayNotice", signure.c_str());
			if(NULL != jCallback){
				jint jtype = IMProgramNoticeTypeToInt(type);
                jstring jmsg = env->NewStringUTF(msg.c_str());
				FileLog(TAG, "OnRecvProgramPlayNotice() callback now");
				env->CallVoidMethod(gListener, jCallback, jItem, jtype, jmsg);
                env->DeleteLocalRef(jmsg);
				FileLog(TAG, "OnRecvProgramPlayNotice() callback ok");
			}
		}

        if(NULL != jItem){
            env->DeleteLocalRef(jItem);
        }

		ReleaseEnv(isAttachThread);
	}

	/**
     *  11.2.节目取消通知接口 回调
     *
     *  @param item         接收多人互动直播间礼物信息
     *
     */
	virtual void OnRecvCancelProgramNotice(const IMProgramItem& item) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvCancelProgramNotice() callback, env:%p, isAttachThread:%d", env, isAttachThread);

		jobject jItem = getIMProgramInfoItem(env,item);
		//callback 回调
		if(NULL != gListener){

			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(";
			signure += "L";
			signure += IM_PROGRAM_PROGRAMINFO_ITEM_CLASS;
			signure += ";";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvCancelProgramNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvCancelProgramNotice() callback now");
				env->CallVoidMethod(gListener, jCallback, jItem);
				FileLog(TAG, "OnRecvCancelProgramNotice() callback ok");
			}
		}

		if(NULL != jItem){
			env->DeleteLocalRef(jItem);
		}
		ReleaseEnv(isAttachThread);
	}

	/**
     *  11.3.接收节目已退票通知接口 回调
     *
     *  @param item         节目
     *  @param leftCredit   当前余额
     *
     */
	virtual void OnRecvRetTicketNotice(const IMProgramItem& item, double leftCredit) override{
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvRetTicketNotice() callback, env:%p, isAttachThread:%d leftCredit:%f", env, isAttachThread, leftCredit);

		jobject jItem = getIMProgramInfoItem(env,item);
		//callback 回调
		if(NULL != gListener){

			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(";
			signure += "L";
			signure += IM_PROGRAM_PROGRAMINFO_ITEM_CLASS;
			signure += ";D";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvRetTicketNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvRetTicketNotice() callback now");
				env->CallVoidMethod(gListener, jCallback, jItem, leftCredit);
				FileLog(TAG, "OnRecvRetTicketNotice() callback ok");
			}
		}

		if(NULL != jItem){
			env->DeleteLocalRef(jItem);
		}
		ReleaseEnv(isAttachThread);
	}

	/**
     *  13.1.接收意向信通知 接口 回调
     *
     *  @param anchorId         主播ID
     *  @param loiId            信件ID
     *
     */
	virtual void OnRecvLoiNotice(const string& anchorId, const string& loiId) override {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvLoiNotice() callback, env:%p, isAttachThread:%d anchorId:%s loiId:%s", env, isAttachThread, anchorId.c_str(), loiId.c_str());

		//callback 回调
		if(NULL != gListener){

			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(";
			signure += "Ljava/lang/String;Ljava/lang/String;";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvLoiNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvLoiNotice() callback now");
				jstring janchorId = env->NewStringUTF(anchorId.c_str());
				jstring jloiId = env->NewStringUTF(loiId.c_str());
				env->CallVoidMethod(gListener, jCallback, janchorId, jloiId);
				env->DeleteLocalRef(janchorId);
				env->DeleteLocalRef(jloiId);
				FileLog(TAG, "OnRecvLoiNotice() callback ok");
			}
		}


		ReleaseEnv(isAttachThread);
	}

	/**
 	*  13.2.接收意向信通知 接口 回调
 	*
 	*  @param anchorId         主播ID
 	*  @param emfId            信件ID
 	*
 	*/
	virtual void OnRecvEMFNotice(const string& anchorId, const string& emfId) override {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);
		FileLog(TAG, "OnRecvEMFNotice() callback, env:%p, isAttachThread:%d anchorId:%s emfId:%s", env, isAttachThread, anchorId.c_str(), emfId.c_str());

		//callback 回调
		if(NULL != gListener){

			jclass jCallbackCls = env->GetObjectClass(gListener);
			string signure = "(";
			signure += "Ljava/lang/String;Ljava/lang/String;";
			signure += ")V";
			jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvEMFNotice", signure.c_str());
			if(NULL != jCallback){
				FileLog(TAG, "OnRecvEMFNotice() callback now");
				jstring janchorId = env->NewStringUTF(anchorId.c_str());
				jstring jemfId = env->NewStringUTF(emfId.c_str());
				env->CallVoidMethod(gListener, jCallback, janchorId, jemfId
				);
				env->DeleteLocalRef(janchorId);
				env->DeleteLocalRef(jemfId);
				FileLog(TAG, "OnRecvEMFNotice() callback ok");
			}
		}

		ReleaseEnv(isAttachThread);
	}
};

static IMClientListener g_listener;


/******************************* 用户请求入口   ***********************************/
/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    IMSetLogDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_IMSetLogDirectory
	(JNIEnv *env, jclass cls, jstring directory) {
	string cpDirectory = JString2String(env, directory);

	KLog::SetLogDirectory(cpDirectory);


	FileLog(TAG, "IMSetLogDirectory ( directory : %s ) ", cpDirectory.c_str());

}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    init
 * Signature: ([Ljava/lang/String;Lcom/qpidnetwork/livemodule/im/listener/IMClientListener;)V
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_init
  (JNIEnv *env, jclass cls, jobjectArray urlArray, jobject listener){
	bool result  = false;


	FileLog(TAG, "Init() listener:%p, urlArray:%p ", listener, urlArray);

	FileLog(TAG, "Init() IImClient::ReleaseClient(g_ImClient) g_ImClient:%p", g_ImClient);

	// 释放旧的ImClient

    if (g_ImClient != NULL) {

        IImClient::ReleaseClient(g_ImClient);
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
 * Method:    ControlManPush
 * Signature: (ILjava/lang/String;I)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_ControlManPush
  (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jint controlType) {
	bool result = false;
	if(NULL != g_ImClient){
		string strRoomId = JString2String(env, roomId);
		IMControlType type = IntToIMControlType(controlType);
		FileLog(TAG, "ControlManPush() reqId: %d, strRoomId:%s", reqId, strRoomId.c_str());
		result = g_ImClient->ControlManPush(reqId, strRoomId, type);
	}
	return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    GetInviteInfo
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_GetInviteInfo
  (JNIEnv *env, jclass cls, jint reqId, jstring invitationId) {
	bool result = false;
	if(NULL != g_ImClient){
		string strInvitationId = JString2String(env, invitationId);
		FileLog(TAG, "GetInviteInfo() reqId: %d, strInvitationId:%s", reqId, strInvitationId.c_str());
		result = g_ImClient->GetInviteInfo(reqId, strInvitationId);
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
 * Method:    CancelImmediatePrivateInvite
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_InstantInviteUserReport
        (JNIEnv *env, jclass cls, jint reqId, jstring inviteId, jboolean isShow){
    bool result = false;
    if(NULL != g_ImClient){
        string strInviteId = JString2String(env, inviteId);
        FileLog(TAG, "InstantInviteUserReport() reqId: %d, inviteId:%s", reqId, strInviteId.c_str());
        result = g_ImClient->SendInstantInviteUserReport(reqId, strInviteId, isShow);
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

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    EnterHangoutRoom
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_EnterHangoutRoom
        (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jboolean isCreateOnly) {
    bool result = false;
    if(NULL != g_ImClient){
        string strRoomId = JString2String(env, roomId);
        FileLog(TAG, "EnterHangoutRoom() reqId: %d, strRoomId:%s, isCreateOnly:%d", reqId, strRoomId.c_str(), isCreateOnly);
        result = g_ImClient->EnterHangoutRoom(reqId, strRoomId, isCreateOnly);
    }
    return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    LeaveHangoutRoom
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_LeaveHangoutRoom
        (JNIEnv *env, jclass cls, jint reqId, jstring roomId) {
    bool result = false;
    if(NULL != g_ImClient){
        string strRoomId = JString2String(env, roomId);
        FileLog(TAG, "LeaveHangoutRoom() reqId: %d, strRoomId:%s", reqId, strRoomId.c_str());
        result = g_ImClient->LeaveHangoutRoom(reqId, strRoomId);
    }
    return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    SendHangoutGift
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZZIZIII)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_SendHangoutGift
        (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jstring nickName, jstring toUid, jstring giftId, jstring giftName, jboolean isBackpack, jboolean isPrivate, jint giftNum, jboolean isMultiClick, jint multiStart, jint multiEnd, jint multiClickId) {
    bool result = false;
    if(NULL != g_ImClient){
        string strRoomId = JString2String(env, roomId);
        string strNickName = JString2String(env, nickName);
        string strToUid = JString2String(env, toUid);
        string strGiftId = JString2String(env, giftId);
        string strGiftName = JString2String(env, giftName);
        FileLog(TAG, "SendHangoutGift() reqId: %d, strRoomId:%s", reqId, strRoomId.c_str());
        result = g_ImClient->SendHangoutGift(reqId, strRoomId, strNickName, strToUid, strGiftId, strGiftName, isBackpack, giftNum, isMultiClick, multiStart, multiEnd, multiClickId, isPrivate);
    }
    return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    ControlManPushHangout
 * Signature: (ILjava/lang/String;I)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_ControlManPushHangout
        (JNIEnv *env, jclass cls, jint reqId, jstring roomId, jint controlType) {
    bool result = false;
    if(NULL != g_ImClient){
        string strRoomId = JString2String(env, roomId);
        IMControlType type = IntToIMControlType(controlType);
        FileLog(TAG, "ControlManPushHangout() reqId: %d, strRoomId:%s", reqId, strRoomId.c_str());
        result = g_ImClient->ControlManPushHangout(reqId, strRoomId, type);
    }
    return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    SendHangoutRoomMsg
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_SendHangoutRoomMsg
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

        FileLog(TAG, "SendHangoutRoomMsg() reqId: %d, roomId:%s, nickName:%s, message:%s",
                reqId, strRoomId.c_str(), strNickName.c_str(), strMessage.c_str());
        result = g_ImClient->SendHangoutLiveChat(reqId, strRoomId, strNickName, strMessage, targetIdList);
    }
    return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    GetIMClient
 * Signature: ()Z
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_im_IMClient_GetIMClient
		(JNIEnv *env, jclass cls) {
	jlong result = -1;
	FileLog(TAG, "GetIMClient() result: %lld begin",
			result);

	if(NULL != g_ImClient){
		long long task = (long long)g_ImClient;
		result = task;
	}
	FileLog(TAG, "GetIMClient() result: %lld end",
			result);
	return result;
}

