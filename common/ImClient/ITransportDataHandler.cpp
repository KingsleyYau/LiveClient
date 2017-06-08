/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ITransportDataHandler.cpp
 *   desc: 传输数据处理接口类
 */


#include "ITransportDataHandler.h"
#include "TransportDataHandler.h"
#include <common/CheckMemoryLeak.h>

ITransportDataHandler* ITransportDataHandler::Create()
{
	ITransportDataHandler* handler = NULL;
	handler = new CTransportDataHandler();
	return handler;
}

void ITransportDataHandler::Release(ITransportDataHandler* handler)
{
	delete handler;
}
