/*
 * author: alex
 *   date: 2018-03-03
 *   file: ZBTransportClient.cpp
 *   desc: 传输数据客户端接口类(负责与服务器之间的基础通讯，如Tcp、WebSocket等)
 */

#include "ZBTransportClient.h"
#include <common/KLog.h>

ZBTransportClient::ZBTransportClient(void)
{
    m_connStateLock = IAutoLock::CreateAutoLock();
    m_connStateLock->Init();
    
    m_isInitMgr = false;
    
    m_connState = DISCONNECT;
    m_conn = NULL;
}

ZBTransportClient::~ZBTransportClient(void)
{
    // 释放mgr
    ReleaseMgrProc();
    
    IAutoLock::ReleaseAutoLock(m_connStateLock);
    m_connStateLock = NULL;
}

// -- IZBTransportClient
// 初始化
bool ZBTransportClient::Init(IZBTransportClientCallback* callback)
{
    m_callback = callback;
    return true;
}

// 连接
bool ZBTransportClient::Connect(const char* url)
{
    bool result = false;
    
    if (NULL != url && url[0] != '\0') {
        m_connStateLock->Lock();
        if (DISCONNECT == m_connState) {
            // 释放mgr
            ReleaseMgrProc();
            
            // 创建mgr
            mg_mgr_init(&m_mgr, NULL);
            m_isInitMgr = true;
            
            // 连接url
            m_url = url;
            struct mg_connect_opts opt = {0};
            opt.user_data = (void*)this;
            m_conn = mg_connect_ws_opt(&m_mgr, ev_handler, opt, m_url.c_str(), "", NULL);
            FileLog("ImClient", "ZBTransportClient::Connect() m_conn->err:%d start", m_conn->err);
            if (NULL != m_conn && m_conn->err == 0) {
                m_connState = CONNECTING;
                result = true;
            }
            
        }
        m_connStateLock->Unlock();
        
        // 连接失败, 不放在m_connStateLock锁里面，因为mg_connect_ws_opt已经ev_handler了，导致ReleaseMgrProc关闭websocket回调ev_handler 的关闭 调用OnDisconnect的m_connStateLock锁
        if (!result) {
            if (NULL != m_conn) {
                // 释放mgr
                ReleaseMgrProc();
            }
            else {
                // 仅重置标志
                m_isInitMgr = false;
            }
        }
    }
    
    return result;
}

// 断开连接
void ZBTransportClient::Disconnect()
{
    m_connStateLock->Lock();
    DisconnectProc();
    m_connStateLock->Unlock();
}

// 断开连接处理(不锁)
void ZBTransportClient::DisconnectProc()
{
    if (NULL != m_conn) {
        mg_shutdown(m_conn);
        m_conn = NULL;
    }
}

// 释放mgr
void ZBTransportClient::ReleaseMgrProc()
{
    if (m_isInitMgr) {
        mg_mgr_free(&m_mgr);
        m_isInitMgr = false;
    }
}

// 获取连接状态
IZBTransportClient::ConnectState ZBTransportClient::GetConnectState()
{
    ConnectState state = DISCONNECT;
    
    m_connStateLock->Lock();
    state = m_connState;
    m_connStateLock->Unlock();
    return state;
}

// 发送数据
bool ZBTransportClient::SendData(const unsigned char* data, size_t dataLen)
{
    bool result = false;
    if (NULL != data && dataLen > 0) {
        if (CONNECTED == m_connState && NULL != m_conn) {
            mg_send_websocket_frame(m_conn, WEBSOCKET_OP_TEXT, data, dataLen);
            result = true;
        }
    }
    return result;
}

// 循环
void ZBTransportClient::Loop()
{
    while (DISCONNECT != m_connState) {
        mg_mgr_poll(&m_mgr, 100);
    }
    Disconnect();
}

// -- mongoose处理函数
void ZBTransportClient::ev_handler(struct mg_connection *nc, int ev, void *ev_data)
{
    struct websocket_message *wm = (struct websocket_message *) ev_data;
    ZBTransportClient* client = (ZBTransportClient*)nc->user_data;
    
    switch (ev) {
        case MG_EV_WEBSOCKET_HANDSHAKE_DONE: {
            // Connected
            client->OnConnect(true);
            break;
        }
        case MG_EV_WEBSOCKET_FRAME: {
            // Receive Data
            client->OnRecvData(wm->data, wm->size);
            break;
        }
        case MG_EV_CLOSE: {
            // Disconnect
            client->OnDisconnect();
            break;
        }
    }
}

void ZBTransportClient::OnConnect(bool success)
{
    // 连接成功(修改连接状态)
    if (success) {
        m_connState = CONNECTED;
        
        // 返回连接成功(若连接失败，则在OnDisconnect统一返回)
        if (NULL != m_callback) {
            m_callback->OnConnect(true);
        }
    }
    
    // 连接失败(断开连接)
    if (!success) {
        Disconnect();
    }
}

void ZBTransportClient::OnDisconnect()
{
    // 重置连接
    m_connStateLock->Lock();
    m_conn = NULL;
    m_connStateLock->Unlock();
    
    if (CONNECTED == m_connState) {
        // 状态为已连接(返回断开连接)
        if (NULL != m_callback) {
            m_callback->OnDisconnect();
        }
    }
    else if (CONNECTING == m_connState || DISCONNECT == m_connState) {
        // 状态为连接中(返回连接失败)
        if (NULL != m_callback) {
            m_callback->OnConnect(false);
        }
    }
    
    // 修改状态为断开连接
    m_connState = DISCONNECT;
}

void ZBTransportClient::OnRecvData(const unsigned char* data, size_t dataLen)
{
    // 返回收到的数据
    if (NULL != m_callback) {
        m_callback->OnRecvData(data, dataLen);
    }
}

