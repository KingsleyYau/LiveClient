/*
 * author: Samson.Fan
 *   date: 2015-03-19
 *   file: ILSLiveChatClient.h
 *   desc: LiveChat客户端接口类
 */

#include "ILSLiveChatClient.h"
#include "LSLiveChatClient.h"
#include <common/CheckMemoryLeak.h>

// 生成LiveChat客户端实现类
ILSLiveChatClient* ILSLiveChatClient::CreateClient()
{
	ILSLiveChatClient* client = new CLSLiveChatClient();
	return client;
}

// 释放LiveChat客户端实现类
void ILSLiveChatClient::ReleaseClient(ILSLiveChatClient* client) 
{
	delete client;
}
