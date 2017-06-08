/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: TransportPacketHandler.h
 *   desc: 传输包处理实现类
 */

#pragma once

#include "ITransportPacketHandler.h"

class CTransportPacketHandler : public ITransportPacketHandler
{
public:
	CTransportPacketHandler(void);
	virtual ~CTransportPacketHandler(void);

public:
	// 组包
	virtual bool Packet(ITask* task, void* data, size_t dataSize, size_t& dataLen);
	// 解包
	virtual UNPACKET_RESULT_TYPE Unpacket(const void* data, size_t dataLen, TransportProtocol& tp);
};
