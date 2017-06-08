/*
 * author: Samson.Fan
 *   date: 2017-05-18
 *   file: ITransportClient.cpp
 *   desc: 传输数据客户端接口类(负责与服务器之间的基础通讯，如Tcp、WebSocket等)
 */

#include "ITransportClient.h"
#include "TransportClient.h"
#include <stdio.h>

ITransportClient* ITransportClient::Create()
{
    ITransportClient* client = NULL;
    client = new TransportClient;
    return client;
}

void ITransportClient::Release(ITransportClient* client)
{
    delete client;
}
