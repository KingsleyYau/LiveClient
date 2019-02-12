/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ILSLiveChatTransportDataHandler.cpp
 *   desc: 传输包处理接口类
 */

#include <stdio.h>
#include "ILSLiveChatTransportDataHandler.h"
#include "LSLiveChatTransportDataHandler.h"
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

ILSLiveChatTransportDataHandler* ILSLiveChatTransportDataHandler::Create()
{
	ILSLiveChatTransportDataHandler* handler = NULL;
	handler = new CLSLiveChatTransportDataHandler();
	return handler;
}

void ILSLiveChatTransportDataHandler::Release(ILSLiveChatTransportDataHandler* handler)
{
	delete handler;
}
