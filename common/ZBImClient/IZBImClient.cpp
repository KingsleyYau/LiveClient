 /*
 * author: alex
 *   date: 2018-03-02
 *   file: IZBImClient.h
 *   desc: 主播IM客户端接口类
 */

#include "IZBImClient.h"
#include "ZBImClient.h"
#include <common/CheckMemoryLeak.h>

// 生成IM客户端实现类
IZBImClient* IZBImClient::CreateClient()
{
	IZBImClient* client = new ZBImClient();
	return client;
}

// 释放IM客户端实现类
void IZBImClient::ReleaseClient(IZBImClient* client)
{
	delete client;
}
