/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: ILSLiveChatSocketHandler.h
 *   desc: 跨平台socket处理接口类
 */

#pragma once

#ifdef WIN32
#include <windows.h>
#include <WinSock.h>
#else
#include <sys/socket.h>
#include <fcntl.h>
#include <errno.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netdb.h>

#define SOCKET int
#define SOCKET_ERROR -1
#define INVALID_SOCKET -1
#endif

#include <string>
using namespace std;

typedef enum {
	SOCKET_RESULT_SUCCESS = 0,
	SOCKET_RESULT_TIMEOUT = -1,
	SOCKET_RESULT_FAIL = -2,
} SOCKET_RESULT_CODE;

class ILSLiveChatSocketHandler
{
public:
	typedef enum {
		TCP_SOCKET,
		UDP_SOCKET
	} SOCKET_TYPE;

	typedef enum {
		HANDLE_SUCCESS,	// 处理成功
		HANDLE_FAIL,	// 处理失败
		HANDLE_TIMEOUT	// 处理超时
	} HANDLE_RESULT;
    
    // 连接状态
    typedef enum  {
        CONNECTION_STATUS_DISCONNECT,   // 未连接
        CONNECTION_STATUS_CONNECTING,   // 连接中
        CONNECTION_STATUS_CONNECTED,    // 已连接
    } CONNNECTION_STATUS;

public:
	static bool InitEnvironment();
	static void ReleaseEnvironment();

public:
	static ILSLiveChatSocketHandler* CreateSocketHandler(SOCKET_TYPE type);
	static void ReleaseSocketHandler(ILSLiveChatSocketHandler* handler);

public:
	ILSLiveChatSocketHandler(void) {};
	virtual ~ILSLiveChatSocketHandler(void) {};

public:
	// 创建socket
	virtual bool Create(bool supportIpv6 = false) = 0;
	// 停止socket
	virtual void Shutdown() = 0;
	// 关闭socket
	virtual void Close() = 0;
	// 绑定ip及端口
	virtual bool Bind(const string& ip, unsigned int port) = 0;
	// 设置blocking
	virtual bool SetBlock(bool block) = 0;
	// 连接（msTimeout：超时时间(毫秒)，不大于0表示使用默认超时）
	virtual SOCKET_RESULT_CODE Connect(const string& ip, unsigned int port, int msTimeout) = 0;
	// 发送
	virtual HANDLE_RESULT Send(void* data, unsigned int dataLen) = 0;
	// 接收
	virtual HANDLE_RESULT Recv(void* data, unsigned int dataSize, unsigned int& dataLen, bool bRecvAll = false) = 0;
    // 获取当前连接状态
    virtual CONNNECTION_STATUS GetConnectionStatus() const = 0;
    // 获取原始socket
    virtual int GetSocket() = 0;
};
