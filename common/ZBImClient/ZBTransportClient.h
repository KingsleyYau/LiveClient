/*
 * author: alex
 *   date: 2018-03-03
 *   file: ZbTransportClient.h
 *   desc: 传输数据客户端实现类(负责与服务器之间的基础通讯，如Tcp、WebSocket等)
 */

#pragma once

#include "IZBTransportClient.h"
#include <mongoose/mongoose.h>
#include <common/IAutoLock.h>
#include <string>

using namespace std;

class ZBTransportClient : public IZBTransportClient
{
public:
    ZBTransportClient(void);
    virtual ~ZBTransportClient(void);
    
// -- ITransportClient
public:
    virtual bool Init(IZBTransportClientCallback* callback);
    virtual bool Connect(const char* url);
    virtual void Disconnect();
    virtual ConnectState GetConnectState();
    virtual bool SendData(const unsigned char* data, size_t dataLen);
    virtual void Loop();
    
// -- mongoose处理函数
private:
    static void ev_handler(struct mg_connection *nc, int ev, void *ev_data);
    void OnConnect(bool success);
    void OnDisconnect();
    void OnRecvData(const unsigned char* data, size_t dataLen);
    
private:
    void DisconnectProc();
	void ReleaseMgrProc();
    
private:
    IZBTransportClientCallback*    m_callback;     // Callback
    
    mg_mgr  m_mgr;              // mongoose管理器
    mg_connection*  m_conn;     // mongoose连接器
    bool m_isInitMgr;           // 是否已初始化mgr
    
    IAutoLock*      m_connStateLock;    // 连接状态锁
    ConnectState    m_connState;        // 连接状态
    
    string  m_url;  // 连接url
};
