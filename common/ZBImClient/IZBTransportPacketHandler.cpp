/*
 * author: alex
 *   date: 2018-03-02
 *   file: IZBTransportPacketHandler.cpp
 *   desc: 传输包处理接口类
 */

#include <stdio.h>
#include "IZBTransportPacketHandler.h"
#include "ZBTransportPacketHandler.h"
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

IZBTransportPacketHandler* IZBTransportPacketHandler::Create()
{
	IZBTransportPacketHandler* handler = NULL;
	handler = new ZBCTransportPacketHandler();
	return handler;
}

void IZBTransportPacketHandler::Release(IZBTransportPacketHandler* handler)
{
	delete handler;
}
