/*
 * author: alex
 *   date: 2018-03-3
 *   file: IZBTransportClient.h
 *   desc: 传输数据客户端接口类(负责与服务器之间的基础通讯，如Tcp、WebSocket等)
 */

#pragma once

#include <stdio.h>

class IZBTransportClient;
class IZBTransportClientCallback
{
public:
    IZBTransportClientCallback() {};
    virtual ~IZBTransportClientCallback() {};
    
public:
    virtual void OnConnect(bool success) = 0;
    virtual void OnRecvData(const unsigned char* data, size_t dataLen) = 0;
    virtual void OnDisconnect() = 0;
};

class IZBTransportClient
{
public:
    static IZBTransportClient* Create();
    static void Release(IZBTransportClient* client);
    
public:
    // 连接状态
    typedef enum _tConnectState {
        CONNECTING,     // 连接中
        CONNECTED,      // 已连接
        DISCONNECT,     // 已断开连接
    } ConnectState;
    
public:
    IZBTransportClient(void) {};
    virtual ~IZBTransportClient(void) {};

public:
    virtual bool Init(IZBTransportClientCallback* callback) = 0;
    virtual bool Connect(const char* url) = 0;
    virtual void Disconnect() = 0;
    virtual ConnectState GetConnectState() = 0;
    virtual bool SendData(const unsigned char* data, size_t dataLen) = 0;
    virtual void Loop() = 0;
};
