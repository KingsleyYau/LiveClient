/*
 * LMEnumJniConvert.cpp
 *
 *  Created on: 2018-6-26
 *      Author: Hunter Mun
 */

#include "LMEnumJniConvert.h"

int HTTPErrorTypeToInt(HTTP_LCC_ERR_TYPE errType)
{
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(HTTPErrorTypeArray); i++)
    {
        if (errType == HTTPErrorTypeArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

int IMErrorTypeToInt(LCC_ERR_TYPE errType)
{
	int value = 1;
	int i = 0;
	for (i = 0; i < _countof(IMErrorTypeArray); i++)
	{
		if (errType == IMErrorTypeArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}



// 底层状态转换JAVA坐标
int LMOnLineStatusToInt(OnLineStatus status) {
    int value = 0;
	int i = 0;
	for (i = 0; i < _countof(LMOnLineStatusArray); i++)
	{
		if (status == LMOnLineStatusArray[i]) {
			value = i;
			break;
		}
	}
	return value;
}


// 底层状态转换JAVA坐标
int LMMessageTypeToInt(LMMessageType type) {
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(LMMessageTypeArray); i++)
    {
        if (type == LMMessageTypeArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

// 底层状态转换JAVA坐标
int LMSendTypeToInt(LMSendType type) {
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(LMSendTypeArray); i++)
    {
        if (type == LMSendTypeArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

// 底层状态转换JAVA坐标
int LMStatusTypeToInt(LMStatusType type) {
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(LMStatusTypeArray); i++)
    {
        if (type == LMStatusTypeArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

// 底层状态转换JAVA坐标
int LMWarningTypeToInt(LMWarningType type) {
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(LMWarningTypeArray); i++)
    {
        if (type == LMWarningTypeArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

LMPrivateMsgSupportType IntToLMPrivateMsgSupportType(int value) {
    return (LMPrivateMsgSupportType)(value < _countof(LMPrivateMsgSupportTypeArray) ? LMPrivateMsgSupportTypeArray[value] : LMPrivateMsgSupportTypeArray[0]);
}

// 底层状态转换JAVA坐标
int LMSystemTypeToInt(LMSystemType type) {
    int value = 0;
    int i = 0;
    for (i = 0; i < _countof(LMSystemTypeArray); i++)
    {
        if (type == LMSystemTypeArray[i]) {
            value = i;
            break;
        }
    }
    return value;
}

jobject getContactItem(JNIEnv *env, LMUserItem* item) {
    jobject jItem = NULL;
    jclass  jItemCls = GetJClass(env, LM_PRIVATE_PRIVATEMSGCONTACT_ITEM_CLASS);
    if (NULL != jItemCls && NULL != item) {
        string signature = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;";
        signature += "ILjava/lang/String;I";
        signature += "IZ";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {

            //item->Lock();
            jstring juserId = env->NewStringUTF(item->m_userId.c_str());
            jstring jnickName = env->NewStringUTF(item->m_userName.c_str());
            jstring javatarImg = env->NewStringUTF(item->m_imageUrl.c_str());
            jint status = LMOnLineStatusToInt(item->m_onlineStatus);
            jstring jlastMsg = env->NewStringUTF(item->m_lastMsg.c_str());
            jint jupdateTime = item->m_updateTime;
            jint junreadNum = item->m_unreadNum;
            jboolean jisAnchor = item->m_isAnchor;
            //item->Unlock();
            jItem = env->NewObject(jItemCls, init,
                                   juserId,
                                   jnickName,
                                   javatarImg,
                                   status,
                                   jlastMsg,
                                   jupdateTime,
                                   junreadNum,
                                   jisAnchor);
			env->DeleteLocalRef(juserId);
			env->DeleteLocalRef(jnickName);
            env->DeleteLocalRef(javatarImg);
            env->DeleteLocalRef(jlastMsg);
        }
    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
    return  jItem;
}

jobjectArray getContactListArray(JNIEnv *env, const LMUserList& list) {
    jobjectArray  jItemArray = NULL;
    jclass  jItemCls = GetJClass(env, LM_PRIVATE_PRIVATEMSGCONTACT_ITEM_CLASS);
    if (NULL != jItemCls && list.size() > 0) {
        jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
        int i = 0;
        for(LMUserList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
            jobject  item = getContactItem(env, *itr);
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

    return jItemArray;

}

jobject getPrivateMsgItem(JNIEnv *env, LMPrivateMsgItem* item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, LM_PRIVATE_PRIVATEMSG_ITEM_CLASS);
    if (NULL != jItemCls && NULL != item) {
        string signature = "(Ljava/lang/String;";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jmessage = env->NewStringUTF(item->m_message.c_str());
            jItem = env->NewObject(jItemCls, init,
                                   jmessage);
            env->DeleteLocalRef(jmessage);
        }

    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
    return jItem;
}

jobject getSystemItem(JNIEnv *env, LMSystemItem* item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, LM_PRIVATE_SYSTEMNOTICE_ITEM_CLASS);
    if (NULL != jItemCls && NULL != item) {
        string signature = "(Ljava/lang/String;I";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jstring jmessage = env->NewStringUTF(item->m_message.c_str());
            jint type = LMSystemTypeToInt(item->m_systemType);
            jItem = env->NewObject(jItemCls, init,
                                       jmessage, type);
            env->DeleteLocalRef(jmessage);
        }

     }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
    return jItem;
}

jobject getWarningItem(JNIEnv *env, LMWarningItem* item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, LM_PRIVATE_WARNING_ITEM_CLASS);
    if (NULL != jItemCls && NULL != item) {
        string signature = "(I";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jint type = LMWarningTypeToInt(item->m_warnType);
            jItem = env->NewObject(jItemCls, init,
                                   type);
        }

    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
    return jItem;
}

jobject getTimeMsgItem(JNIEnv *env, LMTimeMsgItem* item) {
    jobject jItem = NULL;
    jclass jItemCls = GetJClass(env, LM_PRIVATE_TIMEMSG_ITEM_CLASS);
    if (NULL != jItemCls && NULL != item) {
        string signature = "(I";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jItem = env->NewObject(jItemCls, init,
                                   item->m_msgTime);
        }

    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }
    return jItem;
}

jobject getLiveMessageItem(JNIEnv *env, LiveMessageItem* item) {
    jobject jItem = NULL;
    jclass  jItemCls = GetJClass(env, LM_PRIVATE_LIVEMESSAGE_ITEM_CLASS);
    if (NULL != jItemCls && item != NULL) {
        string signature = "(III";
        signature += "Ljava/lang/String;Ljava/lang/String;I";
        signature += "III";
        signature += "L";
        signature += LM_PRIVATE_PRIVATEMSGCONTACT_ITEM_CLASS;
        signature += ";";
        signature += "L";
        signature += LM_PRIVATE_PRIVATEMSG_ITEM_CLASS;
        signature += ";";
        signature += "L";
        signature += LM_PRIVATE_SYSTEMNOTICE_ITEM_CLASS;
        signature += ";";
        signature += "L";
        signature += LM_PRIVATE_WARNING_ITEM_CLASS;
        signature += ";";
        signature += "L";
        signature += LM_PRIVATE_TIMEMSG_ITEM_CLASS;
        signature += ";";
        signature += ")V";
        jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
        if (NULL != init) {
            jint jsendType = LMSendTypeToInt(item->m_sendType);
            jstring jfromId = env->NewStringUTF(item->m_fromId.c_str());
            jstring jtoId = env->NewStringUTF(item->m_toId.c_str());
            jint jstatusType = LMStatusTypeToInt(item->m_statusType);
            jint jmsgType = LMMessageTypeToInt(item->m_msgType);
            jint jerr = IMErrorTypeToInt(item->m_sendErr);
            jobject juserItem = getContactItem(env, item->GetUserItem());
            jobject jprivateItem = NULL;
            jobject jsystemItem = NULL;
            jobject jwarningItem = NULL;
            jobject jtimeMsgItem = NULL;
            if (item->m_msgType == LMMT_Text) {
                jprivateItem = getPrivateMsgItem(env, item->GetPrivateMsgItem());
            } else if(item->m_msgType == LMMT_SystemWarn) {
                jsystemItem = getSystemItem(env, item->GetSystemItem());
            } else if(item->m_msgType == LMMT_Warning) {
                jwarningItem = getWarningItem(env, item->GetWarningItem());
            } else if(item->m_msgType == LMMT_Time) {
                jtimeMsgItem = getTimeMsgItem(env, item->GetTimeMsgItem());
            }
            jItem = env->NewObject(jItemCls, init,
                                   item->m_sendMsgId,
                                   item->m_msgId,
                                   jsendType,
                                   jfromId,
                                   jtoId,
                                   item->m_createTime,
                                   jstatusType,
                                   jmsgType,
                                   jerr,
                                   juserItem,
                                   jprivateItem,
                                   jsystemItem,
                                   jwarningItem,
                                   jtimeMsgItem);
            env->DeleteLocalRef(jfromId);
            env->DeleteLocalRef(jtoId);
            if (NULL != juserItem) {
                env->DeleteLocalRef(juserItem);
            }
            if (NULL != jprivateItem) {
                env->DeleteLocalRef(jprivateItem);
            }
            if (NULL != jsystemItem) {
                env->DeleteLocalRef(jsystemItem);
            }
            if (NULL != jwarningItem) {
                env->DeleteLocalRef(jwarningItem);
            }
            if (NULL != jtimeMsgItem) {
                env->DeleteLocalRef(jtimeMsgItem);
            }
        }

    }

    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

    return jItem;
}

jobjectArray getLiveMessageListArray(JNIEnv *env, const LMMessageList& list) {
    jobjectArray jItemArray = NULL;

    jclass jItemCls = GetJClass(env, LM_PRIVATE_LIVEMESSAGE_ITEM_CLASS);
    if (NULL != jItemCls && list.size() > 0) {
        jItemArray = env->NewObjectArray(list.size(), jItemCls, NULL);
        int i = 0;
        for(LMMessageList::const_iterator itr = list.begin(); itr != list.end(); itr++, i++) {
            jobject item = getLiveMessageItem(env, *itr);
            env->SetObjectArrayElement(jItemArray, i, item);
            env->DeleteLocalRef(item);
        }
//        jItemArray = env->NewObjectArray(10000, jItemCls, NULL);
//        LMMessageList::const_iterator itr = list.begin();
//        for (int i = 0; i < 10000; i ++) {
//            FileLog("alext", "JniLMClient::getLiveMessageListArray() i:%d", i);
//            jobject item = getLiveMessageItem(env, *itr);
//            env->SetObjectArrayElement(jItemArray, i, item);
//            env->DeleteLocalRef(item);
//        }
    }
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

    return jItemArray;
}