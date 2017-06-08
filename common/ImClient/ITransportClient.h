/*
 * author: Samson.Fan
 *   date: 2017-05-18
 *   file: ITransportClient.h
 *   desc: 传输数据客户端接口类(负责与服务器之间的基础通讯，如Tcp、WebSocket等)
 */

#pragma once

#include <stdio.h>

class ITransportClient;
class ITransportClientCallback
{
public:
    ITransportClientCallback() {};
    virtual ~ITransportClientCallback() {};
    
public:
    virtual void OnConnect(bool success) = 0;
    virtual void OnRecvData(const unsigned char* data, size_t dataLen) = 0;
    virtual void OnDisconnect() = 0;
};

class ITransportClient
{
public:
    static ITransportClient* Create();
    static void Release(ITransportClient* client);
    
public:
    // 连接状态
    typedef enum _tConnectState {
        CONNECTING,     // 连接中
        CONNECTED,      // 已连接
        DISCONNECT,     // 已断开连接
    } ConnectState;
    
public:
    ITransportClient(void) {};
    virtual ~ITransportClient(void) {};

public:
    virtual bool Init(ITransportClientCallback* callback) = 0;
    virtual bool Connect(const char* url) = 0;
    virtual void Disconnect() = 0;
    virtual ConnectState GetConnectState() = 0;
    virtual bool SendData(const unsigned char* data, size_t dataLen) = 0;
    virtual void Loop() = 0;
};
