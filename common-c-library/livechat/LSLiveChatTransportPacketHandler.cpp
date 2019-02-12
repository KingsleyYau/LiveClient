/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatTransportPacketHandler.cpp
 *   desc: 传输包处理实现类
 */

#include "LSLiveChatTransportPacketHandler.h"
#include "ILSLiveChatTask.h"
#include "zlib.h"
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

// 使用 ntohl 需要include跨平台socket头文件
#include "ILSLiveChatSocketHandler.h"

CLSLiveChatTransportPacketHandler::CLSLiveChatTransportPacketHandler(void)
{
	m_buffer = NULL;
	m_bufferLen = 0;
}

CLSLiveChatTransportPacketHandler::~CLSLiveChatTransportPacketHandler(void)
{
	delete []m_buffer;
}

// 组包
bool CLSLiveChatTransportPacketHandler::Packet(ILSLiveChatTask* task, void* data, unsigned int dataSize, unsigned int& dataLen)
{
	//printf("CTransportPacketHandler::Packet() task:%p, data:%p, dataLen:%d\n", task, data, dataLen);

	FileLog("LiveChatClient", "CTransportPacketHandler::Packet() begin");

	bool result = false;

	if (task->GetSendDataProtocolType() == NOHEAD_PROTOCOL) {
		if (dataSize > sizeof(LSLiveChatNoHeadTransportProtocol)) {
			LSLiveChatNoHeadTransportProtocol* protocol = (LSLiveChatNoHeadTransportProtocol*)data;

			// 获取数据
			unsigned int bodyLen = 0;
			result = task->GetSendData((void*)&(protocol->data), dataSize, bodyLen);
			if  (result)
			{
				dataLen = protocol->GetAllDataLength();
			}
		}
	}
	else {
		if (dataSize > sizeof(LSLiveChatTransportHeader)) {
			LSLiveChatTransportProtocol* protocol = (LSLiveChatTransportProtocol*)data;
			protocol->header.shiftKey = 0;
			protocol->header.remote = 0;
			protocol->header.request = 0;
			protocol->header.cmd = ntohl(task->GetCmdCode());
			protocol->header.seq = ntohl(task->GetSeq());
			protocol->header.zip = 0;	// 不压缩
			protocol->header.protocolType = (unsigned char)task->GetSendDataProtocolType();

			unsigned int bodyLen = 0;
			result = task->GetSendData(protocol->data, dataSize - sizeof(LSLiveChatTransportHeader), bodyLen);
			if (result)
			{
				dataLen = sizeof(LSLiveChatTransportHeader) + bodyLen;

				protocol->header.length = dataLen - sizeof(protocol->header.length);
				protocol->header.length = ntohl(protocol->header.length);

				FileLog("LiveChatClient", "CLSLiveChatTransportPacketHandler::Packet() cmd:%d, seq:%d, dataLen:%d"
						, task->GetCmdCode(), task->GetSeq(), dataLen);
			}
		}
	}

	FileLog("LiveChatClient", "CLSLiveChatTransportPacketHandler::Packet() end, result:%d", result);

	return result;
}
	
// 解包
UNPACKET_RESULT_TYPE CLSLiveChatTransportPacketHandler::Unpacket(void* data, unsigned int dataLen, unsigned int maxLen, LSLiveChatTransportProtocol** ppTp, unsigned int& useLen)
{
	UNPACKET_RESULT_TYPE result = UNPACKET_FAIL;
	useLen = 0;
	*ppTp = NULL;
	LSLiveChatTransportProtocol* tp = (LSLiveChatTransportProtocol*)data;
	unsigned int length = 0;

	FileLog("LiveChatClient", "CLSLiveChatTransportPacketHandler::Unpacket() begin");

	if (dataLen >= sizeof(tp->header.length))
	{
		length = ntohl(tp->header.length);
		if (length == 0)
		{
			// 心跳包
			useLen = sizeof(tp->header.length);
		}
		else
		{
			if (dataLen >= length + sizeof(length))
			{
				tp->header.length = length;
				useLen = tp->header.length + sizeof(tp->header.length);
				ShiftRight((unsigned char*)data + sizeof(tp->header.length) + sizeof(tp->header.shiftKey), tp->header.length - sizeof(tp->header.shiftKey), tp->header.shiftKey);
				tp->header.cmd = ntohl(tp->header.cmd);
				tp->header.seq = ntohl(tp->header.seq);

				if (tp->header.zip == 1
					&& tp->GetDataLength() > 0)
				{
					// 需要解压
					result = Unzip(tp, ppTp) ? UNPACKET_SUCCESS : result;
				}
				else {
					*ppTp = tp;
					result = UNPACKET_SUCCESS;
				}
			}
			else if (maxLen >= length + sizeof(length))
			{
				// 需要更多数据，且有足够buffer接收
				result = UNPACKET_MOREDATA;
			}
			else {
				// 严重错误，需要重新连接
				result = UNPACKET_ERROR;
			}
		}
	}
	else {
		result = UNPACKET_MOREDATA;
	}

	if (result == UNPACKET_SUCCESS) {
		FileLog("LiveChatClient", "CLSLiveChatTransportPacketHandler::Unpacket() end, result:%d, cmd:%d, seq:%d, length:%d"
				, result, tp->header.cmd, tp->header.seq, tp->header.length);
	}
	else {
		FileLog("LiveChatClient", "CLSLiveChatTransportPacketHandler::Unpacket() end, result:%d", result);
	}

	return result;
}


// 移位解密
void CLSLiveChatTransportPacketHandler::ShiftRight(unsigned char *data, int length, unsigned char bit)
{
	if (length == 0) {
		return;
	}
	unsigned char b = bit % 8;
	if (b == 8) {
		return;
	}
	unsigned char mask = 0xff >> (8 - b);
	unsigned char last = data[length - 1];
	unsigned char *p;
	for (p = data; p < data + length; ++p) {
		unsigned char hight = (last & mask) << (8 - b);
		last = *p;		// & 0xff;
		*p = (last >> b) | hight;
	}
}

// 解压
bool CLSLiveChatTransportPacketHandler::Unzip(LSLiveChatTransportProtocol* tp, LSLiveChatTransportProtocol** ppTp)
{
	// 初始化
	bool result = false;
	*ppTp = NULL;
	if (m_bufferLen == 0) {
		RebuildBuffer();
	}

	// 解压
	int unret = Z_OK;
//	uLongf needBuffLen = 0;
	do {

		if (NULL != m_buffer && m_bufferLen > sizeof(tp->header)) {
			uLongf needBuffLen = m_bufferLen - sizeof(tp->header);
			uLong dataLen = tp->GetDataLength();
			unret = uncompress(m_buffer + sizeof(tp->header), &needBuffLen, tp->data, dataLen);
			if (Z_BUF_ERROR == unret) {
				// 缓冲不足
				RebuildBuffer();
				continue;
			}
			else {
				if (Z_OK == unret) {
					// 解压成功
					*ppTp = (LSLiveChatTransportProtocol*)m_buffer;
					(*ppTp)->header = tp->header;
					(*ppTp)->SetDataLength(needBuffLen);

					result = true;
				}
				break;
			}
		}
		else {
			// 缓冲出错
			break;
		}
	} while (true);

	return result;
}

// 重建buffer
bool CLSLiveChatTransportPacketHandler::RebuildBuffer()
{
	if (m_bufferLen == 0) {
		const unsigned int initBufferLen = 1024;
		m_buffer = new unsigned char[initBufferLen];
		if (NULL != m_buffer) {
			m_bufferLen = initBufferLen;
		}
	}
	else {
		delete []m_buffer;
		unsigned int reLen = m_bufferLen * 2;
		m_buffer = new unsigned char[reLen];
		if (NULL != m_buffer) {
			m_bufferLen = reLen;
			FileLog("LiveChatClient", "CTransportPacketHandler::RebuildBuffer() rebuild buffer, m_bufferLen:%d", m_bufferLen);
		}
	}

	return NULL != m_buffer;
}
