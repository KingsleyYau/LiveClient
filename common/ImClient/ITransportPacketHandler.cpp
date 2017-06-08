/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ITransportPacketHandler.cpp
 *   desc: 传输包处理接口类
 */

#include <stdio.h>
#include "ITransportPacketHandler.h"
#include "TransportPacketHandler.h"
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

ITransportPacketHandler* ITransportPacketHandler::Create()
{
	ITransportPacketHandler* handler = NULL;
	handler = new CTransportPacketHandler();
	return handler;
}

void ITransportPacketHandler::Release(ITransportPacketHandler* handler)
{
	delete handler;
}
