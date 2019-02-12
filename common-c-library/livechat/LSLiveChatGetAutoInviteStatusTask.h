/*
 * author:Alex shem
 *   date:2016-8-23
 *   file:LSLiveChatGetAutoInviteStatusTask.h
 *   desc:��ȡ�����Զ�������Ϣ״̬����Ůʿ��
*/

#pragma once
#include "ILSLiveChatTask.h"
#include <string>


class LSLiveChatGetAutoInviteStatusTask: public ILSLiveChatTask
{
public:
	LSLiveChatGetAutoInviteStatusTask(void);
	virtual ~LSLiveChatGetAutoInviteStatusTask(void);

//ITask�ӿں���
public:
	// ��ʼ��
	virtual bool Init(ILSLiveChatClientListener* listener);
	// �����ѽ�������
	virtual bool Handle(const LSLiveChatTransportProtocol* tp);
	// ��ȡ�����͵����ݣ����Ȼ�ȡdata���ȣ��磺GetSendData(NULL, 0, dataLen);
	virtual bool GetSendData(void* data, unsigned int dataSize, unsigned int& dataLen);
	// ��ȡ���������ݵ�����
	virtual TASK_PROTOCOL_TYPE GetSendDataProtocolType();
    // ��ȡ�����
	virtual int GetCmdCode();
    // ����seq
	virtual void SetSeq(unsigned int seq);
	// ��ȡseq
	virtual unsigned int GetSeq();
    // �Ƿ���Ҫ�ȴ��ظ�����false���ͺ��ͷţ�delete�����������ͺ�ᱻ��������ظ��б����յ��ظ����ͷ�
	virtual bool IsWaitToRespond();
    // ��ȡ������
	virtual void GetHandleResult(LSLIVECHAT_LCC_ERR_TYPE& errType, string& errMsg);
    // δ�������Ķ���֪ͨ
	virtual void OnDisconnect();

public:
	// ��ʼ������
	bool InitParam(const string& version);

private:
	ILSLiveChatClientListener*        m_listener;

	unsigned int     m_seq;         //seq
	LSLIVECHAT_LCC_ERR_TYPE     m_errType;     //���������صĴ�����
	string           m_errMsg;      //���������صĽ������

	bool             m_isOpenStatus;

};
