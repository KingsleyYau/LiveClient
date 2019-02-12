/*
 * com_qpidnetwork_livemodule_livemessage_LMClient.cpp
 *
 *  Created on: 2017-05-31
 *      Author: Hunter.Mun
 * Description:	直播端消息相关接口
 */
#include "com_qpidnetwork_livemodule_livemessage_LMClient.h"
//include <ImClient/ImClient.h>
#include "LMGlobalFunc.h"
#include "LMEnumJniConvert.h"
#include <LiveMessageManManager.h>
#include "../httprequest/com_qpidnetwork_livemodule_httprequest_RequestJniPrivateMsg.h"

/******************** IMClient 相关全局变量    ***************************/
//#define TAG "LMClientJni"

/* java listener object */
static jobject gListener = NULL;

static ILiveMessageManManager* g_lmMessageManager = NULL;


long long HandlePrivateMsgFriendListRequest(IRequestGetPrivateMsgFriendListCallback* callback);
long long HandleFollowPrivateMsgFriendListRequest(IRequestGetFollowPrivateMsgFriendListCallback* callback);
void HandlePrivateMsgWithUserIdRequest(const string& userId, const string& startMsgId, PrivateMsgOrderType order, int limit, int reqId, IRequestGetPrivateMsgHistoryByIdCallback* callback);
long long HandleSetPrivateMsgReaded(const string& userId, const string& msgId,IRequestSetPrivateMsgReadedCallback* callback);
static IHttpRequestPrivateMsgControllerHandler gHttpRequestPrivateMsgControllerHandler {
        HandlePrivateMsgFriendListRequest,
        HandleFollowPrivateMsgFriendListRequest,
        HandlePrivateMsgWithUserIdRequest,
        HandleSetPrivateMsgReaded
};

long long HandlePrivateMsgFriendListRequest(IRequestGetPrivateMsgFriendListCallback* callback)
{
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::HandleRequestPrivateMsgFriendList() begin");

    jlong taskId = -1;

    /* turn object to java object here */
    JNIEnv* env = NULL;
    bool isAttachThread = false;
    GetEnv(&env, &isAttachThread);

    jlong jcallback = (jlong)callback;
    taskId = Java_com_qpidnetwork_livemodule_httprequest_RequestJniPrivateMsg_GetPrivateMsgFriendList(env, NULL, jcallback);


    ReleaseEnv(isAttachThread);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::HandleRequestPrivateMsgFriendList() end");
    return (long long)taskId;
}

long long HandleFollowPrivateMsgFriendListRequest(IRequestGetFollowPrivateMsgFriendListCallback* callback)
{
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::HandleFollowPrivateMsgFriendListRequest( ) begin");

    jlong taskId = -1;
    /* turn object to java object here */
    JNIEnv* env = NULL;
    bool isAttachThread = false;
    GetEnv(&env, &isAttachThread);
    jlong jcallback = (jlong)callback;
    taskId = Java_com_qpidnetwork_livemodule_httprequest_RequestJniPrivateMsg_GetFollowPrivateMsgFriendList(env, NULL, jcallback);

    ReleaseEnv(isAttachThread);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::HandleFollowPrivateMsgFriendListRequest(taskId:%ld ) end", taskId);

    return taskId;
}


void HandlePrivateMsgWithUserIdRequest(const string& userId, const string& startMsgId, PrivateMsgOrderType order, int limit, int reqId, IRequestGetPrivateMsgHistoryByIdCallback* callback)
{
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::HandleRequestPrivateMsgWithUserId() begin");

    /* turn object to java object here */

    JNIEnv* env = NULL;
    bool isAttachThread = false;
    GetEnv(&env, &isAttachThread);

    jstring juserId = env->NewStringUTF(userId.c_str());
    jstring jstartMsgId = env->NewStringUTF(startMsgId.c_str());
    jlong jcallback = (jlong)callback;
    Java_com_qpidnetwork_livemodule_httprequest_RequestJniPrivateMsg_GetPrivateMsgHistoryById(env, NULL, juserId, jstartMsgId, (int)order, limit, reqId, jcallback);
    env->DeleteLocalRef(juserId);
    env->DeleteLocalRef(jstartMsgId);

    ReleaseEnv(isAttachThread);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::HandleRequestPrivateMsgWithUserId() end");
}

long long HandleSetPrivateMsgReaded(const string& userId, const string& msgId,IRequestSetPrivateMsgReadedCallback* callback) {
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::HandleSetPrivateMsgReaded(userId:%s, msgId:%s ) begin", userId.c_str(), msgId.c_str());

    jlong taskId = -1;
    /* turn object to java object here */
    JNIEnv* env = NULL;
    bool isAttachThread = false;
    GetEnv(&env, &isAttachThread);


    jstring juserId = env->NewStringUTF(userId.c_str());
    jstring jmsgId = env->NewStringUTF(msgId.c_str());
    jlong jcallback = (jlong)callback;
    taskId = Java_com_qpidnetwork_livemodule_httprequest_RequestJniPrivateMsg_SetPrivateMsgReaded(env, NULL, juserId, jmsgId, jcallback);
    env->DeleteLocalRef(juserId);
    env->DeleteLocalRef(jmsgId);
    ReleaseEnv(isAttachThread);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::HandleSetPrivateMsgReaded(taskId:%lld, userId:%s, msgId:%s ) end", taskId, userId.c_str(), msgId.c_str());

    return taskId;
}

/******************************* 底层Client Listener **************************/
class LMClientListener : public ILiveMessageManManagerListener{
public:
	LMClientListener() {};
	virtual ~LMClientListener() {}
public:
    // ------- 私信联系人 listener(http接口的返回) -------
	// 调用私信联系人列表的回调
	virtual void OnUpdateFriendListNotice(bool success, int errnum, const string& errmsg) override {
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnUpdateFriendListNotice() begin ");
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        if(gListener != NULL) {
            // callback 回调
                jclass jCallbackCls = env->GetObjectClass(gListener);
                if (NULL != jCallbackCls) {
                    string signature = "(ZILjava/lang/String;";
                    signature += ")V";
                    jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnUpdateFriendListNotice", signature.c_str());
                    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnUpdateFriendListNotice() jCallback: %p  jCallbackCls:%p, ignature: %s",
                            jCallback, jCallbackCls, signature.c_str());
                    if (NULL != jCallback) {
                        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
                        jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                        env->CallVoidMethod(gListener, jCallback, success, errType, jerrmsg);
                        //env->CallVoidMethod(gListener, jCallback, success, errType, jerrmsg);
                        env->DeleteLocalRef(jerrmsg);
                    }
                }
            if (NULL != jCallbackCls) {
                env->DeleteLocalRef(jCallbackCls);
            }
        }

        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMGetPrivateMsgFriendList() end");
        ReleaseEnv(isAttachThread);

    }
//	// 调用私信follow联系人的回调
//    virtual void OnLMGetFollowPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const LMUserList& followList) override {
//        FileLog("LiveMessageManManager", "alextest:OnLMGetFollowPrivateMsgFriendList() start");
//        JNIEnv* env = NULL;
//        bool isAttachThread = false;
//        GetEnv(&env, &isAttachThread);
//        // callback 回调
//        /*callback object*/
//        jobject callBackObject = getCallbackObjectByTask((long)requestId);
//        if (NULL != callBackObject) {
//            jclass jCallbackCls = env->GetObjectClass(callBackObject);
//            string signature = "(ZILjava/lang/String;";
//            signature += "[L";
//            signature += LM_PRIVATE_PRIVATEMSGCONTACT_ITEM_CLASS;
//            signature += ";";
//            signature += ")V";
//            jmethodID jCallback = env->GetMethodID(jCallbackCls, "onGetPrivateMsgFriendList", signature.c_str());
//            FileLog("LiveMessageManManager", "alextest:OnLMGetFollowPrivateMsgFriendList() jCallback: %p  jCallbackCls:%p, ignature: %s start",
//                    jCallback, jCallbackCls, signature.c_str());
//            if (NULL != jCallback) {
//                int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
//                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
//                jobjectArray  jItemArray = getContactListArray(env, followList);
//                env->CallVoidMethod(callBackObject, jCallback, success, errType, jerrmsg, jItemArray);
//                env->DeleteLocalRef(jerrmsg);
//                if (NULL != jItemArray) {
//                    env->DeleteLocalRef(jItemArray);
//                }
//            }
//        }
//        FileLog("LiveMessageManManager", "alextest:OnLMGetFollowPrivateMsgFriendList() end");
//
//        ReleaseEnv(isAttachThread);
//    }

    // ------- 公共操作 listener -------
	// 这个是上层调用的返回，获取指定用户Id的用户的私信消息（不能直接返回的，需要考虑刷新消息标记,都是异步返回的。一般用于刚进私信间和重连后调用GetLocalPrivateMsgWithUserId后再使用这个）,返回是全部还是增量呢？(userId 为接收者的用户id，用于上层判断是否为当前的聊天用户)
    virtual void OnLMRefreshPrivateMsgWithUserId(const string& userId, bool success, int errnum, const string& errmsg, const LMMessageList& msgList, int reqId) override {
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMRefreshPrivateMsgWithUserId(userId:%s success:%d) begin ", userId.c_str(), success);
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        // callback 回调
        if (NULL != gListener) {
            jclass jCallbackCls = env->GetObjectClass(gListener);
            if (NULL != jCallbackCls) {
                string signature = "(ZILjava/lang/String;";
                signature += "Ljava/lang/String;";
                signature += "[L";
                signature += LM_PRIVATE_LIVEMESSAGE_ITEM_CLASS;
                signature += ";";
                signature += "I";
                signature += ")V";
                jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRefreshPrivateMsgWithUserId", signature.c_str());
                FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMRefreshPrivateMsgWithUserId() jCallback: %p  jCallbackCls:%p, ignature: %s",
                        jCallback, jCallbackCls, signature.c_str());
                if (NULL != jCallback) {
                    int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
                    jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                    jstring juserId = env->NewStringUTF(userId.c_str());
                    jobjectArray  jItemArray = getLiveMessageListArray(env, msgList);
                    env->CallVoidMethod(gListener, jCallback, success, errType, jerrmsg, juserId, jItemArray, reqId);
                    env->DeleteLocalRef(jerrmsg);
                    env->DeleteLocalRef(juserId);
                    if (NULL != jItemArray) {
                        env->DeleteLocalRef(jItemArray);
                    }
                }
            }
            if (NULL != jCallbackCls) {
                env->DeleteLocalRef(jCallbackCls);
            }
        }

        ReleaseEnv(isAttachThread);
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMRefreshPrivateMsgWithUserId() end ");
    }
	// 这个是上层调用的返回，获取指定用户Id的用户更多私信消息（不能直接返回的，需要考虑刷新消息标记和是否有本地数据），返回是以前的的数据，插在数据前面，不是全部(userId 为接收者的用户id，用于上层判断是否为当前的聊天用户)
    virtual void OnLMGetMorePrivateMsgWithUserId(const string& userId, bool success, int errnum, const string& errmsg, const LMMessageList& msgList, int reqId, bool isMuchMore, bool isInsertHead) override {
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMGetMorePrivateMsgWithUserId(userId:%s success:%d) begin ", userId.c_str(), success);
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        // callback 回调
        if (NULL != gListener) {
            jclass jCallbackCls = env->GetObjectClass(gListener);
            if (NULL != jCallbackCls) {
                string signature = "(ZILjava/lang/String;";
                signature += "Ljava/lang/String;";
                signature += "[L";
                signature += LM_PRIVATE_LIVEMESSAGE_ITEM_CLASS;
                signature += ";";
                signature += "IZ";
                signature += ")V";
                jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnGetMorePrivateMsgWithUserId", signature.c_str());
                FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMGetMorePrivateMsgWithUserId() jCallback: %p  jCallbackCls:%p, ignature: %s",
                        jCallback, jCallbackCls, signature.c_str());
                if (NULL != jCallback) {
                    int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
                    jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                    jstring juserId = env->NewStringUTF(userId.c_str());
                    jobjectArray  jItemArray = getLiveMessageListArray(env, msgList);
                    env->CallVoidMethod(gListener, jCallback, success, errType, jerrmsg, juserId, jItemArray, reqId, isMuchMore);
                    env->DeleteLocalRef(jerrmsg);
                    env->DeleteLocalRef(juserId);
                    if (NULL != jItemArray) {
                        env->DeleteLocalRef(jItemArray);
                    }
                }
            }

            if (NULL != jCallbackCls) {
                env->DeleteLocalRef(jCallbackCls);
            }
        }

        ReleaseEnv(isAttachThread);
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMGetMorePrivateMsgWithUserId() end ");
    }

    // 这个不是上层调用回调过来的，是c层接收都数据或发送前判断需要更新数据后，将回调新增的数据到上层
	virtual void OnLMUpdatePrivateMsgWithUserId(const string& userId, const LMMessageList& msgList) override {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMUpdatePrivateMsgWithUserId() gListener:%p, userId:%s, msgList.size():%d start", gListener, userId.c_str(), msgList.size());
        // callback 回调
        if (NULL != gListener) {
            jclass jCallbackCls = env->GetObjectClass(gListener);
            if (NULL != jCallbackCls) {
                string signature = "(Ljava/lang/String;";
                signature += "[L";
                signature += LM_PRIVATE_LIVEMESSAGE_ITEM_CLASS;
                signature += ";";
                signature += ")V";
                jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnUpdatePrivateMsgWithUserId", signature.c_str());
                FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMUpdatePrivateMsgWithUserId() jCallback: %p  jCallbackCls:%p, ignature: %s",
                        jCallback, jCallbackCls, signature.c_str());
                if (NULL != jCallback) {
                    jstring juserId = env->NewStringUTF(userId.c_str());
                    jobjectArray  jItemArray = getLiveMessageListArray(env, msgList);
                    env->CallVoidMethod(gListener, jCallback, juserId, jItemArray);
                    env->DeleteLocalRef(juserId);
                    if (NULL != jItemArray) {
                        env->DeleteLocalRef(jItemArray);
                    }
                }
            }

            if (NULL != jCallbackCls) {
                env->DeleteLocalRef(jCallbackCls);
            }
        }
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMUpdatePrivateMsgWithUserId() gListener:%p, userId:%s, msgList.size():%d end", gListener, userId.c_str(), msgList.size());
        ReleaseEnv(isAttachThread);
	}

    // 提交阅读私信（用于私信聊天间，向服务器提交已读私信）回调
    virtual void OnLMSetPrivateMsgReaded(long long requestId, bool success, int errnum, const string& errmsg, bool isModify, const string& toId) override {

        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMSetPrivateMsgReaded() g_lmMessageManager:%p, success:%d isModify:%d, toId:%s start", g_lmMessageManager, success, isModify, toId.c_str());
        // callback 回调
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)requestId);
        if (NULL != callBackObject) {
            jclass jCallbackCls = env->GetObjectClass(callBackObject);
            if (NULL != jCallbackCls) {
                string signature = "(ZILjava/lang/String;";
                signature += "ZLjava/lang/String;)V";
                jmethodID jCallback = env->GetMethodID(jCallbackCls, "onSetPrivateMsgReaded", signature.c_str());
                FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMSetPrivateMsgReaded() jCallback: %p  jCallbackCls:%p, ignature: %s",
                        jCallback, jCallbackCls, signature.c_str());
                if (NULL != jCallback) {

                    int errType = IMErrorTypeToInt((LCC_ERR_TYPE)errnum);
                    jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                    jstring jtoId = env->NewStringUTF(toId.c_str());
                    env->CallVoidMethod(callBackObject, jCallback, success, errType, jerrmsg, isModify, jtoId);
                    env->DeleteLocalRef(jerrmsg);
                    env->DeleteLocalRef(jtoId);

                }
            }

            if (NULL != jCallbackCls) {
                env->DeleteLocalRef(jCallbackCls);
            }
        }

        ReleaseEnv(isAttachThread);
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMSetPrivateMsgReaded() g_lmMessageManager:%p, success:%d end", g_lmMessageManager, success);
    }

    // -------  私信listener(成功，一般再调用GetLocatPrivateMsgWithUserId) -------
	virtual void OnLMSendPrivateMessage(const string& userId, bool success, int errnum, const string& errmsg, LiveMessageItem* item) override {

        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMSendPrivateMessage() g_lmMessageManager:%p, success:%d  errnum:%d errmsg:%s start", g_lmMessageManager, success, errnum, errmsg.c_str());
        // callback 回调
        if (NULL != gListener) {
            jclass jCallbackCls = env->GetObjectClass(gListener);
            if (NULL != jCallbackCls) {
                string signature = "(ZILjava/lang/String;";
                signature += "Ljava/lang/String;";
                signature += "L";
                signature += LM_PRIVATE_LIVEMESSAGE_ITEM_CLASS;
                signature += ";";
                signature += ")V";
                jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnSendPrivateMessage", signature.c_str());
                FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMSendPrivateMessage() jCallback: %p  jCallbackCls:%p, ignature: %s",
                        jCallback, jCallbackCls, signature.c_str());
                if (NULL != jCallback) {
                    int errType = IMErrorTypeToInt((LCC_ERR_TYPE)errnum);
                    jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                    jstring juserId = env->NewStringUTF(userId.c_str());
                    jobject  jItem = getLiveMessageItem(env, item);
                    env->CallVoidMethod(gListener, jCallback, success, errType, jerrmsg, juserId, jItem);
                    env->DeleteLocalRef(jerrmsg);
                    env->DeleteLocalRef(juserId);
                    if (NULL != jItem) {
                        env->DeleteLocalRef(jItem);
                    }
                }
            }

            if (NULL != jCallbackCls) {
                env->DeleteLocalRef(jCallbackCls);
            }
        }

        ReleaseEnv(isAttachThread);
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMSendPrivateMessage() g_lmMessageManager:%p, success:%d end", g_lmMessageManager, success);

    }

    virtual void OnLMRecvPrivateMessage(LiveMessageItem* item) override {

        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnRecvUnReadPrivateMsg() g_lmMessageManager:%p  start", g_lmMessageManager);
        // callback 回调
        if (NULL != gListener) {
            jclass jCallbackCls = env->GetObjectClass(gListener);
            if (NULL != jCallbackCls) {
                string signature = "(";
                signature += "L";
                signature += LM_PRIVATE_LIVEMESSAGE_ITEM_CLASS;
                signature += ";";
                signature += ")V";
                jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRecvUnReadPrivateMsg", signature.c_str());
                FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnLMSendPrivateMessage() jCallback: %p  jCallbackCls:%p, ignature: %s",
                        jCallback, jCallbackCls, signature.c_str());
                if (NULL != jCallback) {
                    jobject  jItem = getLiveMessageItem(env, item);
                    env->CallVoidMethod(gListener, jCallback, jItem);
                    if (NULL != jItem) {
                        env->DeleteLocalRef(jItem);
                    }
                }
            }

            if (NULL != jCallbackCls) {
                env->DeleteLocalRef(jCallbackCls);
            }
        }

        ReleaseEnv(isAttachThread);
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnRecvUnReadPrivateMsg() g_lmMessageManager:%p end", g_lmMessageManager);
    }

    // 重发通知（上层按了重发，c层删除所有时间item（android不好删除可能有时间item），把所有发送给上层）
    virtual void OnRepeatSendPrivateMsgNotice(const string& userId, const LMMessageList& msgList) override {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnRepeatSendPrivateMsgNotice() gListener:%p, userId:%s, msgList.size():%d start", gListener, userId.c_str(), msgList.size());
        // callback 回调
        if (NULL != gListener) {
            jclass jCallbackCls = env->GetObjectClass(gListener);
            if (NULL != jCallbackCls) {
                string signature = "(Ljava/lang/String;";
                signature += "[L";
                signature += LM_PRIVATE_LIVEMESSAGE_ITEM_CLASS;
                signature += ";";
                signature += ")V";
                jmethodID jCallback = env->GetMethodID(jCallbackCls, "OnRepeatSendPrivateMsgNotice", signature.c_str());
                FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnRepeatSendPrivateMsgNotice() jCallback: %p  jCallbackCls:%p, ignature: %s",
                        jCallback, jCallbackCls, signature.c_str());
                if (NULL != jCallback) {
                    jstring juserId = env->NewStringUTF(userId.c_str());
                    jobjectArray  jItemArray = getLiveMessageListArray(env, msgList);
                    env->CallVoidMethod(gListener, jCallback, juserId, jItemArray);
                    env->DeleteLocalRef(juserId);
                    if (NULL != jItemArray) {
                        env->DeleteLocalRef(jItemArray);
                    }
                }
            }

            if (NULL != jCallbackCls) {
                env->DeleteLocalRef(jCallbackCls);
            }
        }
        FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::OnRepeatSendPrivateMsgNotice() gListener:%p, userId:%d, msgList.size():%d end", gListener, userId.c_str(), msgList.size());
        ReleaseEnv(isAttachThread);
    }

};

static LMClientListener g_listener;


/******************************* 用户请求入口   ***********************************/
/*
 * Class:     com_qpidnetwork_livemodule_im_IMClient
 * Method:    IMSetLogDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_LMSetLogDirectory
	(JNIEnv *env, jclass cls, jstring directory) {
	const char *cpDirectory = env->GetStringUTFChars(directory, 0);

	KLog::SetLogDirectory(cpDirectory);


	FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::LMSetLogDirectory ( directory : %s ) ", cpDirectory);

	env->ReleaseStringUTFChars(directory, cpDirectory);
}

JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_InitLMManager
(JNIEnv *env, jclass cls, jstring userId, jintArray supportArray, jlong imClient, jobject listener, jstring privateNotice)  {
    string strUserId = JString2String(env, userId);
    int len = env->GetArrayLength(supportArray);
    string strPrivateNotice = JString2String(env, privateNotice);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::InitLMManager()g_ImMessageClient:%p userId:%s supportArray.size():%d beging", g_lmMessageManager, strUserId.c_str(), len);
    bool result  = false;

    // 获取支持私信类型
    PrivateSupportTypeList supportList;
    jint *tempArray;
    tempArray = env->GetIntArrayElements(supportArray, NULL); 
    if (NULL != supportArray) {
        for (int i = 0; i < len; i++) {
            LMPrivateMsgSupportType type = IntToLMPrivateMsgSupportType(tempArray[i]);
            if (type != LMPMSType_Unknow) {
                supportList.push_back(type);
            }
        }
    }
    env->ReleaseIntArrayElements(supportArray, tempArray, 0);
    // 释放旧的ImClient

    if ( g_lmMessageManager == NULL ||  (g_lmMessageManager != NULL && g_lmMessageManager->GetUserId() != strUserId)) {

        ILiveMessageManManager::Release(g_lmMessageManager);
        g_lmMessageManager = NULL;

        g_lmMessageManager = ILiveMessageManManager::Create();
        if (g_lmMessageManager != NULL) {
            result  = g_lmMessageManager->InitUserInfo(strUserId, supportList, strPrivateNotice);
            IImClient* jimClient = (IImClient*)imClient;

            // 释放旧的listener
            if (NULL != gListener) {
                env->DeleteGlobalRef(gListener);
                gListener = NULL;
            }

            gListener = env->NewGlobalRef(listener);
            result = g_lmMessageManager->Init(jimClient, gHttpRequestPrivateMsgControllerHandler, &g_listener);

        }

    }

    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::InitLMManager() g_ImMessageClient:%p result:%d end", g_lmMessageManager, result);
    return result;
}

JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_ReleaseLMManager
        (JNIEnv *env, jclass cls)  {
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::ReleaseLMManager() g_ImMessageClient:%p begin", g_lmMessageManager);
    bool result  = false;
    // 释放旧的ImClient

    if (g_lmMessageManager != NULL) {

        ILiveMessageManManager::Release(g_lmMessageManager);
        result  = true;
    }

    g_lmMessageManager = NULL;

    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::ReleaseLMManager()r g_ImMessageClient:%p end", g_lmMessageManager);
    return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClien
 * Method:    init
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/livemessage/item/LMClientListener;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_Init
  (JNIEnv *env, jclass cls, jlong imClient, jobject listener){
	bool result  = false;

	FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::Init() listener:%p, imClient:%ld", listener, imClient);
	IImClient* jimClient = (IImClient*)imClient;

	FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::Init() LiveMessageManManager::ReleaseClient(g_ImMessageClient) g_ImMessageClient:%p", g_lmMessageManager);


    if (g_lmMessageManager != NULL) {

        // 释放旧的listener
        if (NULL != gListener) {
            env->DeleteGlobalRef(gListener);
            gListener = NULL;
        }

        gListener = env->NewGlobalRef(listener);
        result = g_lmMessageManager->Init(jimClient, gHttpRequestPrivateMsgControllerHandler, &g_listener);
    }




	FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::Init() result: %d end", result);
	return result;
}



/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:    GetLocalPrivateMsgFriendList
 * Signature: ()[Lcom/qpidnetwork/livemodule/livemessage/item/LMPrivateMsgContactItem;
 */
JNIEXPORT jobjectArray JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_GetLocalPrivateMsgFriendList
        (JNIEnv *env, jclass cls) {
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::GetLocalPrivateMsgFriendList()  g_lmMessageManager:%p start", g_lmMessageManager);
    jobjectArray  jItemArray = NULL;
    if (NULL != g_lmMessageManager) {
        jItemArray = getContactListArray(env, g_lmMessageManager->GetLocalPrivateMsgFriendList());
    }
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJni::GetLocalPrivateMsgFriendList()  g_lmMessageManager:%p end", g_lmMessageManager);
    return jItemArray;
}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:   GetPrivateMsgFriendList
 * Signature: ()J
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_GetPrivateMsgFriendList
        (JNIEnv *env, jclass cls) {

    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::GetPrivateMsgFriendList() begin");
    jboolean result = false;
    jlong taskId = -1;
    if (NULL != g_lmMessageManager) {
        taskId = g_lmMessageManager->GetPrivateMsgFriendList();
    }

    result = (taskId == -1 ? false : true);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::GetPrivateMsgFriendList() end taskId:%ld", taskId);

    return result;

}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:    GetLocalPrivateMsgFriendList
 * Signature: ()[Lcom/qpidnetwork/livemodule/livemessage/item/LMPrivateMsgContactItem;
 */
JNIEXPORT jobjectArray JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_GetLocalFollowPrivateMsgFriendList
        (JNIEnv *env, jclass cls) {
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::GetLocalFollowPrivateMsgFriendList() begin");
    jobjectArray  jItemArray = NULL;
    if (NULL != g_lmMessageManager) {
        jItemArray = getContactListArray(env, g_lmMessageManager->GetLocalFollowPrivateMsgFriendList());
    }
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::GetLocalFollowPrivateMsgFriendList() end");
    return jItemArray;
}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:   GetPrivateMsgFriendList
 * Signature: ()Z
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_GetFollowPrivateMsgFriendList
        (JNIEnv *env, jclass cls, jobject callback) {
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::GetFollowPrivateMsgFriendList() begin");
    jlong taskId = -1;
    if (NULL != g_lmMessageManager) {
        taskId = g_lmMessageManager->GetFollowPrivateMsgFriendList();
    }

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::GetFollowPrivateMsgFriendList() end");
    return taskId;

}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:    AddPrivateMsgLiveChatList
 * Signature: (Ljava/lang/String;)Z;
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_AddPrivateMsgLiveChatList
        (JNIEnv *env, jclass cls, jstring userId) {
    jboolean result = false;
    string strUserId = JString2String(env, userId);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::AddPrivateMsgLiveChatList(userId:%s) begin", strUserId.c_str());

    if (NULL != g_lmMessageManager) {

        result = g_lmMessageManager->AddPrivateMsgLiveChat(strUserId);
    }
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::AddPrivateMsgLiveChatList(userId:%s result:%d) end", strUserId.c_str(), result);
    return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:    RemovePrivateMsgLiveChatList
 * Signature: (Ljava/lang/String;)Z;
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_RemovePrivateMsgLiveChatList
        (JNIEnv *env, jclass cls, jstring userId) {
    jboolean result = false;
    string strUserId = JString2String(env, userId);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::RemovePrivateMsgLiveChatList(userId:%s) begin", strUserId.c_str());

    if (NULL != g_lmMessageManager) {

        result = g_lmMessageManager->RemovePrivateMsgLiveChat(strUserId);
    }
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::RemovePrivateMsgLiveChatList(userId:%s result:%d) end", strUserId.c_str(), result);
    return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:    GetLocalPrivateMsgWithUserId
 * Signature: (Ljava/lang/String;)[Lcom/qpidnetwork/livemodule/livemessage/item/LiveMessageItem;
 */
JNIEXPORT jobjectArray JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_GetLocalPrivateMsgWithUserId
        (JNIEnv *env, jclass cls, jstring userId) {
    jobjectArray jItemArray = NULL;
    string strUserId = JString2String(env, userId);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::GetLocalPrivateMsgWithUserId(userId:%s) begin", strUserId.c_str());

    if (NULL != g_lmMessageManager) {

        jItemArray = getLiveMessageListArray(env, g_lmMessageManager->GetLocalPrivateMsgWithUserId(strUserId));
    }
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::GetLocalPrivateMsgWithUserId(userId:%s) end", strUserId.c_str());
    return jItemArray;
}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:   RefreshPrivateMsgWithUserId
 * Signature: (Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_RefreshPrivateMsgWithUserId
        (JNIEnv *env, jclass cls, jstring userId) {
    jint reqId = -1;
    string strUserId = JString2String(env, userId);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::RefreshPrivateMsgWithUserId(userId:%s) begin", strUserId.c_str());
    if (NULL != g_lmMessageManager) {

        reqId = g_lmMessageManager->RefreshPrivateMsgWithUserId(strUserId);
    }
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::RefreshPrivateMsgWithUserId(userId:%s) end", strUserId.c_str());
    return reqId;
}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:    GetMorePrivateMsgWithUserId
 * Signature: (Ljava/lang/String;)Z
 */
JNIEXPORT jint JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_GetMorePrivateMsgWithUserId
        (JNIEnv *env, jclass cls, jstring userId) {
    jint reqId = -1;
    string strUserId = JString2String(env, userId);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::GetMorePrivateMsgWithUserId(userId:%s) begin", strUserId.c_str());
    if (NULL != g_lmMessageManager) {

        reqId = g_lmMessageManager->GetMorePrivateMsgWithUserId(strUserId);
    }
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::GetMorePrivateMsgWithUserId(userId:%s) end", strUserId.c_str());
    return reqId;
}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:    SendPrivateMessage
 * Signature: (Ljava/lang/String;Ljava/lang/String;)Lcom/qpidnetwork/livemodule/livemessage/item/LiveMessageItem;
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_SendPrivateMessage
        (JNIEnv *env, jclass cls, jstring userId, jstring message) {
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::SendPrivateMessage(userId:%s message:%s) begin", JString2String(env, userId).c_str(), JString2String(env, message).c_str());
    jboolean result = false;

    if (NULL != g_lmMessageManager) {
        string strUserId = JString2String(env, userId);
        string strMessage = JString2String(env, message);
        result = g_lmMessageManager->SendPrivateMessage(strUserId, strMessage);
    }
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::SendPrivateMessage(userId:%s message:%s result:%d) end", JString2String(env, userId).c_str(), JString2String(env, message).c_str(), result);
    return result;
}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:    SetPrivateMsgReaded
 * Signature: (Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_SetPrivateMsgReaded
        (JNIEnv *env, jclass cls, jstring userId, jobject callback) {
    jboolean result = false;

    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::SetPrivateMsgReaded() begin");
    jlong taskId = -1;
    if (NULL != g_lmMessageManager) {
        string strUserId = JString2String(env, userId);
        taskId = g_lmMessageManager->SetPrivateMsgReaded(strUserId);
    }

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::SetPrivateMsgReaded() end");
    return taskId;
}

/*
 * Class:     com_qpidnetwork_livemodule_livemessage_LMClient
 * Method:    RepeatSendPrivateMsg
 * Signature: (I)Lcom/qpidnetwork/livemodule/livemessage/item/LiveMessageItem;
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_livemodule_livemessage_LMClient_RepeatSendPrivateMsg
        (JNIEnv *env, jclass cls, jstring userId, jint sendMsgId) {
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::RepeatSendPrivateMsg(userId:%s sendMsgId:%d) begin", JString2String(env, userId).c_str(), sendMsgId);
    jboolean result = false;

    if (NULL != g_lmMessageManager) {
        string strUserId = JString2String(env, userId);
        result = g_lmMessageManager->RepeatSendPrivateMsg(strUserId, sendMsgId);
    }
    FileLog(LIVESHOW_LIVEMESSAGE_LOG, "LMClientJNI::RepeatSendPrivateMsg(userId:%s sendMsgId:%d result:%d) end", JString2String(env, userId).c_str(), sendMsgId, result);
    return result;
}

