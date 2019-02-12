/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ILSLiveChatTransportPacketHandler.cpp
 *   desc: 传输包处理接口类
 */

#include <stdio.h>
#include "ILSLiveChatTransportPacketHandler.h"
#include "LSLiveChatTransportPacketHandler.h"
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

ILSLiveChatTransportPacketHandler* ILSLiveChatTransportPacketHandler::Create()
{
	ILSLiveChatTransportPacketHandler* handler = NULL;
	handler = new CLSLiveChatTransportPacketHandler();
	return handler;
}

void ILSLiveChatTransportPacketHandler::Release(ILSLiveChatTransportPacketHandler* handler)
{
	delete handler;
}
