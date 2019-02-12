/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: LSLiveChatTransportPacketHandler.h
 *   desc: 传输包处理实现类
 */

#pragma once

#include "ILSLiveChatTransportPacketHandler.h"

class CLSLiveChatTransportPacketHandler : public ILSLiveChatTransportPacketHandler
{
public:
	CLSLiveChatTransportPacketHandler(void);
	virtual ~CLSLiveChatTransportPacketHandler(void);

public:
	// 组包
	virtual bool Packet(ILSLiveChatTask* task, void* data, unsigned int dataSize, unsigned int& dataLen);
	// 解包
	virtual UNPACKET_RESULT_TYPE Unpacket(void* data, unsigned int dataLen, unsigned int maxLen, LSLiveChatTransportProtocol** ppTp, unsigned int& useLen);

private:
	// 移位解密
	void ShiftRight(unsigned char *data, int length, unsigned char bit) ;
	// 解压
	bool Unzip(LSLiveChatTransportProtocol* tp, LSLiveChatTransportProtocol** ppTp);
	// 重建buffer
	bool RebuildBuffer();

private:
	unsigned char* m_buffer;
	unsigned int m_bufferLen;
};
