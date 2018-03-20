/*
 * author: alex
 *   date: 2018-03-03
 *   file: IZBTransportDataHandler.cpp
 *   desc: 传输数据处理接口类
 */


#include "IZBTransportDataHandler.h"
#include "ZBTransportDataHandler.h"
#include <common/CheckMemoryLeak.h>

IZBTransportDataHandler* IZBTransportDataHandler::Create()
{
	IZBTransportDataHandler* handler = NULL;
	handler = new ZBCTransportDataHandler();
	return handler;
}

void IZBTransportDataHandler::Release(IZBTransportDataHandler* handler)
{
	delete handler;
}
