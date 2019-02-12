/*
 * author: Samson.Fan
 *   date: 2015-08-03
 *   file: LSLiveChatGetLadyChatInfoTask.cpp
 *   desc: 获取女士聊天信息（包括在聊及邀请的男士列表等）Task实现类
 */

#include "LSLiveChatGetLadyChatInfoTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include "LSLiveChatCommonParsing.h"
#include <json/json/json.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define CHATTING_PARAM          "chatting"          // 在聊男士的用户ID列表
#define CHATTING_INVITEID_PARAM "chattingIds"       // 在聊男士的邀请ID列表
#define MISSING_PARAM           "missing"           // 未回男士邀请消息的用户ID列表
#define MISSING_INVITEID_PARAM  "missingIds"        // 未回男士邀请消息的邀请ID列表
#define ID_DELIMITED		","					    // ID分隔符

LSLiveChatGetLadyChatInfoTask::LSLiveChatGetLadyChatInfoTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatGetLadyChatInfoTask::~LSLiveChatGetLadyChatInfoTask(void)
{
}

// 初始化
bool LSLiveChatGetLadyChatInfoTask::Init(ILSLiveChatClientListener* listener)
{
	bool result = false;
	if (NULL != listener)
	{
		m_listener = listener;
		result = true;
	}
	return result;
}

// 处理已接收数据
bool LSLiveChatGetLadyChatInfoTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	// 服务器有可能返回空，因此默认为成功
	bool result = true;
	m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
	m_errMsg = "";


	list<string> chattingList;
	list<string> chattingInviteIdList;
	list<string> missingList;
	list<string> missingInviteIdList;

	AmfParser parser;
	amf_object_handle root = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!root.isnull()) {
        // 解析失败协议
		int errType = 0;
		string errMsg = "";
		if (GetAMFProtocolError(root, errType, errMsg)) {
			m_errType = (LSLIVECHAT_LCC_ERR_TYPE)errType;
			m_errMsg = errMsg;
		}
		else {
			// 解析成功协议
            if (root->type == DT_OBJECT) {
                // Chatting
                amf_object_handle objChatting = root->get_child(CHATTING_PARAM);
                if (!objChatting.isnull()
                    && DT_STRING == objChatting->type)
                {
                    chattingList = ParsingId(objChatting->strValue);
                }

                // ChattingInviteId
                amf_object_handle objChattingInviteId = root->get_child(CHATTING_INVITEID_PARAM);
                if (!objChattingInviteId.isnull()
                    && DT_STRING == objChattingInviteId->type)
                {
                    chattingInviteIdList = ParsingId(objChattingInviteId->strValue);
                }

                // Missing
                amf_object_handle objMissing = root->get_child(MISSING_PARAM);
                if (!objMissing.isnull()
                    && DT_STRING == objMissing->type)
                {
                    missingList = ParsingId(objMissing->strValue);
                }

                // MissingInviteId
                amf_object_handle objMissingInviteId = root->get_child(MISSING_INVITEID_PARAM);
                if (!objMissingInviteId.isnull()
                    && DT_STRING == objMissingInviteId->type)
                {
                    missingInviteIdList = ParsingId(objMissingInviteId->strValue);
                }
            }
		}
	}

	FileLog("LiveChatClient", "LSLiveChatGetLadyChatInfoTask::Handle() result:%d, chattingList.size:%d, chattingInviteIdList.size:%d, missingList.size:%d, missingInviteIdList.size:%d"
         , result, chattingList.size(), chattingInviteIdList.size(), missingList.size(), missingInviteIdList.size());

	// 通知listener
	if (NULL != m_listener) {
		m_listener->OnGetLadyChatInfo(m_errType, m_errMsg, chattingList, chattingInviteIdList, missingList, missingInviteIdList);
	}

	return result;
}

// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatGetLadyChatInfoTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	// 没有参数
	dataLen = 0;
	return true;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatGetLadyChatInfoTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}

// 获取命令号
int LSLiveChatGetLadyChatInfoTask::GetCmdCode()
{
	return TCMD_GETLADYCHATINFO;
}

// 设置seq
void LSLiveChatGetLadyChatInfoTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatGetLadyChatInfoTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatGetLadyChatInfoTask::IsWaitToRespond()
{
	return true;
}

// 获取处理结果
void LSLiveChatGetLadyChatInfoTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatGetLadyChatInfoTask::OnDisconnect()
{
	if (NULL != m_listener) {
        list<string> chattingList;
        list<string> chattingInviteIdList;
        list<string> missingList;
        list<string> missingInviteIdList;
		m_listener->OnGetLadyChatInfo(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", chattingList, chattingInviteIdList, missingList, missingInviteIdList);
	}
}

// 把解析协议为ID列表
list<string> LSLiveChatGetLadyChatInfoTask::ParsingId(const string& protocal)
{
    list<string> strList;

    string str = protocal;
    size_t pos = 0;
    do {
        size_t cur = str.find(ID_DELIMITED, pos);
        if (cur != string::npos) {
            string temp = str.substr(pos, cur - pos);
            if (!temp.empty()) {
                strList.push_back(temp);
            }
            pos = cur + 1;
        }
        else {
            string temp = str.substr(pos);
            if (!temp.empty()) {
                strList.push_back(temp);
            }
            break;
        }
    } while(true);

    return strList;
}
