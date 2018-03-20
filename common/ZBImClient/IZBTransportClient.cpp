/*
 * author: alex
 *   date: 2018-03-03
 *   file: IZBTransportClient.cpp
 *   desc: 传输数据客户端接口类(负责与服务器之间的基础通讯，如Tcp、WebSocket等)
 */

#include "IZBTransportClient.h"
#include "ZBTransportClient.h"
#include <stdio.h>

IZBTransportClient* IZBTransportClient::Create()
{
    IZBTransportClient* client = NULL;
    client = new ZBTransportClient;
    return client;
}

void IZBTransportClient::Release(IZBTransportClient* client)
{
    delete client;
}
