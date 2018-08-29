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
    m_isShutdownConnecting = false;
    m_isWebConnected = false;
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
    FileLog("ImClient", "ZBTransportClient::Connect()m_isShutdownConnecting:%d begin",m_isShutdownConnecting);
    m_isWebConnected = false;
    m_isShutdownConnecting = false;
    if (NULL != url && url[0] != '\0') {
        // 释放mgr
        ReleaseMgrProc();
        m_connStateLock->Lock();
        if (DISCONNECT == m_connState) {

            // 创建mgr
            mg_mgr_init(&m_mgr, NULL);
            m_isInitMgr = true;
            
            // 连接url
            m_url = url;
            struct mg_connect_opts opt = {0};
            opt.user_data = (void*)this;
            m_conn = mg_connect_ws_opt(&m_mgr, ev_handler, opt, m_url.c_str(), "", NULL);
            FileLog("ImClient", "ZBTransportClient::Connect() m_conn->err:%d start", m_conn->err);
            if (NULL != m_conn && m_conn->err == 0 && !m_isShutdownConnecting) {
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
    FileLog("ImClient", "ZBTransportClient::Connect()m_isShutdownConnecting:%d end",m_isShutdownConnecting);
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
    FileLog("ImClient", "ZBTransportClient::DisconnectProc() m_conn:%p  m_connState:%d m_isShutdownConnecting:%d begin", m_conn, m_connState, m_isShutdownConnecting);
    // 当m_connState == CONNECTING时，im的socket还没有connect（可能是连socket都没有（因为ip为域名时mg_connect_ws_opt不去socket，都放到mg_mgr_poll去做，导致socketid没有，mg_shutdown 没有用，就设置DISCONNECT，使mg_mgr_poll结束））
    if (m_connState == CONNECTING || m_connState == DISCONNECT) {
        m_connState = DISCONNECT;
    }
    if (NULL != m_conn) {
        FileLog("ImClient", "ZBTransportClient::DisconnectProc() m_conn:%p m_conn->err:%d m_conn->sock:%d m_connState:%d", m_conn, m_conn->err, m_conn->sock, m_connState);
        mg_shutdown(m_conn);
        m_conn = NULL;
    }
    m_isShutdownConnecting = true;
    FileLog("ImClient", "ZBTransportClient::DisconnectProc() m_conn:%p  m_connState:%d m_isOnDisConnect:%d end", m_conn, m_connState, m_isShutdownConnecting);
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
    // 如果im是连接中logout，没有走OnDisconnect，现在就走
    if (!m_isWebConnected) {
        FileLog("ImClient", "ZBTransportClient::Loop() m_conn:%p m_connState:%d m_isShutdownConnecting:%d", m_conn, m_connState, m_isShutdownConnecting);
        // 状态为已连接(返回断开连接)
        if (NULL != m_callback) {
            m_callback->OnDisconnect();
        }
    }
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
            m_isWebConnected = false;
            m_isShutdownConnecting = false;
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

