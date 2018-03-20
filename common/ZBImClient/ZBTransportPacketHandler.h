/*
 * author: alex
 *   date: 2018-03-03
 *   file: ZBTransportPacketHandler.h
 *   desc: 传输包处理实现类
 */

#pragma once

#include "IZBTransportPacketHandler.h"

class ZBCTransportPacketHandler : public IZBTransportPacketHandler
{
public:
	ZBCTransportPacketHandler(void);
	virtual ~ZBCTransportPacketHandler(void);

public:
	// 组包
	virtual bool Packet(IZBTask* task, void* data, size_t dataSize, size_t& dataLen);
	// 解包
	virtual ZBUNPACKET_RESULT_TYPE Unpacket(const void* data, size_t dataLen, ZBTransportProtocol& tp);
};
