/*
 * author: Hunter Mun
 *   date: 2017-03-02
 *   file: LSLiveChatRecvManJoinOrExitConferenceTask.cpp
 *   desc: 男士加入或退出Camshare会议室更新通知
 */

#include "LSLiveChatRecvManJoinOrExitConferenceTask.h"
#include "ILSLiveChatTaskManager.h"
#include "ILSLiveChatClient.h"
#include "LSLiveChatAmfPublicParse.h"
#include <json/json/json.h>
#include <common/CheckMemoryLeak.h>

// 请求参数定义
#define FROMID_PARAM	"fromId"
#define MSG_PARAM		"msg"
#define MSG_CMD_PARAM   "cmd"
#define MSG_DATA_PARAM  "data"
#define MSG_TOID_PARAM  "toId"
#define MSG_USRLIST_PARAM "userlist"

LSLiveChatRecvManJoinOrExitConferenceTask::LSLiveChatRecvManJoinOrExitConferenceTask(void)
{
	m_listener = NULL;

	m_seq = 0;
	m_errType = LSLIVECHAT_LCC_ERR_FAIL;
	m_errMsg = "";
}

LSLiveChatRecvManJoinOrExitConferenceTask::~LSLiveChatRecvManJoinOrExitConferenceTask(void)
{
}

// 初始化
bool LSLiveChatRecvManJoinOrExitConferenceTask::Init(ILSLiveChatClientListener* listener)
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
bool LSLiveChatRecvManJoinOrExitConferenceTask::Handle(const LSLiveChatTransportProtocol* tp)
{
	bool result = false;
	string fromId = "";
	string toId = "";
	MAN_CONFERENCE_EVENT_TYPE event = MAN_CONFERENCE_EVENT_UNKNOW;
	list<string> userlist;

	AmfParser parser;
	amf_object_handle amfRoot = parser.Decode((char*)tp->data, tp->GetDataLength());
	if (!amfRoot.isnull()
		&& amfRoot->type == DT_OBJECT)
	{
		//fromId
		amf_object_handle fromIdObject = amfRoot->get_child(FROMID_PARAM);
		result = !fromIdObject.isnull() && fromIdObject->type == DT_STRING;
		if (result) {
			fromId = fromIdObject->strValue;
		}

		// msg
		amf_object_handle msgObject = amfRoot->get_child(MSG_PARAM);
		result = !msgObject.isnull() && msgObject->type == DT_STRING;
		if (result) {
            Json::Value root;
            Json::Reader reader;
            if( reader.parse(msgObject->strValue, root) ) {
                if( root[MSG_CMD_PARAM].isInt() ) {
                	event = GetConferenceEventType(root[MSG_CMD_PARAM].asInt());
                }
                if(!root[MSG_DATA_PARAM].isNull()
                		&& root[MSG_DATA_PARAM].isObject()){
                	Json::Value data = root[MSG_DATA_PARAM];
                	if(data[MSG_TOID_PARAM].isString()){
                		toId = data[MSG_TOID_PARAM].asString();
                	}

                	//datalist
                	Json::Value datalistJson = data[MSG_USRLIST_PARAM];
                	if(!datalistJson.isNull()
                			&& datalistJson.isArray()){
                		int arraySize = datalistJson.size();
                		for (int i = 0; i < arraySize; i++){
                			Json::Value jsonItem = datalistJson[i];
                			if(jsonItem.isString()){
                				userlist.push_back(jsonItem.asString());
                			}
                		}
                	}
                }
            }
		}
	}

	// 通知listener
	if (NULL != m_listener
		&& result)
	{
		m_listener->OnRecvManJoinOrExitConference(event, fromId, toId, userlist);
	}

	return result;
}

// 获取待发送的数据，可先获取data长度，如：GetSendData(NULL, 0, dataLen);
bool LSLiveChatRecvManJoinOrExitConferenceTask::GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen)
{
	bool result = false;
	// 本协议没有返回
	return result;
}

// 获取待发送数据的类型
TASK_PROTOCOL_TYPE LSLiveChatRecvManJoinOrExitConferenceTask::GetSendDataProtocolType()
{
	return JSON_PROTOCOL;
}

// 获取命令号
int LSLiveChatRecvManJoinOrExitConferenceTask::GetCmdCode()
{
	return TCMD_RECVMANCAMJOINOREXITCONF;
}

// 设置seq
void LSLiveChatRecvManJoinOrExitConferenceTask::SetSeq(unsigned int seq)
{
	m_seq = seq;
}

// 获取seq
unsigned int LSLiveChatRecvManJoinOrExitConferenceTask::GetSeq()
{
	return m_seq;
}

// 是否需要等待回复。若false则发送后释放(delete掉)，否则发送后会被添加至待回复列表，收到回复后释放
bool LSLiveChatRecvManJoinOrExitConferenceTask::IsWaitToRespond()
{
	return false;
}

// 获取处理结果
void LSLiveChatRecvManJoinOrExitConferenceTask::GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg)
{
	errType = m_errType;
	errMsg = m_errMsg;
}

// 未完成任务的断线通知
void LSLiveChatRecvManJoinOrExitConferenceTask::OnDisconnect()
{
	// 不用回调
}
