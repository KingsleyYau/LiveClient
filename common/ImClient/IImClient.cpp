/*
 * author: Samson.Fan
 *   date: 2017-05-09
 *   file: IImClient.h
 *   desc: IM客户端接口类
 */

#include "IImClient.h"
#include "ImClient.h"
#include <common/CheckMemoryLeak.h>

// 生成IM客户端实现类
IImClient* IImClient::CreateClient()
{
	IImClient* client = new ImClient();
	return client;
}

// 释放IM客户端实现类
void IImClient::ReleaseClient(IImClient* client)
{
	delete client;
}
