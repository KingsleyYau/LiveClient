/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: ILSLiveChatSocketHandler.cpp
 *   desc: 跨平台socket处理接口类
 */

#include "ILSLiveChatSocketHandler.h"
//#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>
//#include <netinet6/in6.h>
#include <string.h>
#include "common/IPAddress.h"
//#ifndef WIN32
//#include <sys/signal.h>
//#endif

typedef enum IPStack {
    V4IP_IPV4_ONLY,
    V4IP_IPV4_IPV6,
    V4IP_IPV6_ONLY,
} IPSTACK;

#ifdef WIN32
class WinTcpSocketHandler : public ILSLiveChatSocketHandler
{
public:
	WinTcpSocketHandler() {
		m_socket = INVALID_SOCKET;
		m_block = false;
		m_connStatus = CONNECTION_STATUS_DISCONNECT;
	}
	virtual ~WinTcpSocketHandler() {
		Close();
	}

public:
	// 创建socket
	virtual bool Create(bool supportIpv6) {
		m_socket = socket(AF_INET, SOCK_STREAM, 0);
		return INVALID_SOCKET != m_socket;
	}
	
	// 停止socket
	virtual void Shutdown()
	{
		if (INVALID_SOCKET != m_socket)
		{
			shutdown(m_socket, 2);
		}
	}

	// 关闭socket
	virtual void Close() {
		closesocket(m_socket);
		m_socket = INVALID_SOCKET;

		m_block = false;
	}
	
	// 绑定ip
	virtual bool Bind(const string& ip, unsigned int port) {
		sockaddr_in service;
		service.sin_family = AF_INET;
		service.sin_addr.s_addr = inet_addr(ip.c_str());
		service.sin_port = htons(port);

		return SOCKET_ERROR != bind(m_socket, (SOCKADDR*)&service, sizeof(service));
	}
	
	// 连接（msTimeout：超时时间(毫秒)，不大于0表示使用默认超时）
	virtual SOCKET_RESULT_CODE Connect(const string& ip, unsigned int port, int msTimeout) {
		SOCKET_RESULT_CODE result = SOCKET_RESULT_FAIL;

		// 定义socketaddr
		sockaddr_in server;
		server.sin_family = AF_INET;
		server.sin_addr.s_addr = inet_addr(ip.c_str());
		server.sin_port = htons(port);

		// 连接
		m_connStatus = CONNECTION_STATUS_CONNECTING;
		if (msTimeout > 0) {
			SetBlock(false);
			if (connect(m_socket, (SOCKADDR*)&server, sizeof(server)) == SOCKET_ERROR) {
				if (WSAGetLastError() == WSAEWOULDBLOCK) {
					timeval timeout;  
					timeout.tv_sec = msTimeout / 1000;
					timeout.tv_usec = msTimeout % 1000;
					fd_set writeset, exceptset;
					FD_ZERO(&writeset);
					FD_SET(m_socket, &writeset);
					FD_ZERO(&exceptset);
					FD_SET(m_socket, &exceptset);
		  
					int ret = select(FD_SETSIZE, NULL, &writeset, &exceptset, &timeout);
					if (ret == 0) {
						result = SOCKET_RESULT_TIMEOUT;
					}
					else if (ret > 0 && 0 != FD_ISSET(m_socket, &exceptset)) {
						result  = SOCKET_RESULT_SUCCESS;
					}
				}
				else if (WSAGetLastError() == 0) {
					result = SOCKET_RESULT_SUCCESS;
				}
			}
			else {
				result = SOCKET_RESULT_SUCCESS;
			}
			SetBlock(true);
		}
		else {
			SetBlock(true);
			if (connect(m_socket, (SOCKADDR*)&server, sizeof(server)) == 0) {
				result = SOCKET_RESULT_SUCCESS;
			}
		}

        if (SOCKET_RESULT_SUCCESS == result) {
            m_connStatus = CONNECTION_STATUS_CONNECTED;
        }
        else {
            m_connStatus = CONNECTION_STATUS_DISCONNECT;
        }
		return result;
	}
	
	// 发送
	virtual HANDLE_RESULT Send(void* data, unsigned int dataLen) {
		HANDLE_RESULT result = HANDLE_FAIL;

		int total = 0;
		while (true) {
			int iSent = send(m_socket, (const char*)data, dataLen, 0);
			if (iSent > 0) {
				total += iSent;
			}
			else {
				break;
			}

			if (total == dataLen) {
				result = HANDLE_SUCCESS;
				break;
			}
		}
		return result;
	}
	
	// 接收
	virtual HANDLE_RESULT Recv(void* data, unsigned int dataSize, unsigned int& dataLen, bool bRecvAll) {
		HANDLE_RESULT result = HANDLE_FAIL;

		dataLen = 0;
		int length = recv(m_socket, (char*)data, dataSize, 0);
		if (length > 0) {
			dataLen = length;
			result = HANDLE_SUCCESS;
		}

		return result;
	}

	// 获取当前连接状态
    virtual CONNNECTION_STATUS GetConnectionStatus() const
    {
        return m_connStatus;
    }

	virtual int GetSocket() {
		return m_socket;
	}

private:
	// blocking设置
	bool SetBlock(bool block) {
		bool result = true;
		if (m_block != block) {
			unsigned long mode = block ? 0 : 1;
			result = ioctlsocket(m_socket, FIONBIO, &mode) == 0;

			if (result) {
				m_block = block;
			}
		}
		return result;
	}

private:
	SOCKET	m_socket;
	bool	m_block;
	CONNNECTION_STATUS m_connStatus;
};

#else
class LinuxTcpSocketHandler : public ILSLiveChatSocketHandler
{
public:
	LinuxTcpSocketHandler() {
		m_socket = INVALID_SOCKET;
		m_block = true;
		m_supportIpv6 = false;
		m_connStatus = CONNECTION_STATUS_DISCONNECT;
	}
	virtual ~LinuxTcpSocketHandler() {
		Shutdown();
		Close();
	}

public:
	// 创建socket
	virtual bool Create(bool supportIpv6)
	{
		if (INVALID_SOCKET == m_socket)
		{
            m_supportIpv6 = supportIpv6;
            m_socket = socket(m_supportIpv6?AF_INET6:AF_INET, SOCK_STREAM, 0);
            #ifdef IOS
            int value = 1;
            setsockopt(m_socket, SOL_SOCKET, SO_NOSIGPIPE, &value, sizeof(value));
            #else
            signal(SIGPIPE, SIG_IGN);
            #endif
            
		}
		return INVALID_SOCKET != m_socket;
	}
	
	// 停止socket
	virtual void Shutdown()
	{
		if (INVALID_SOCKET != m_socket)
		{
			shutdown(m_socket, SHUT_RDWR);
		}
	}

	// 关闭socket
	virtual void Close()
	{
		if (INVALID_SOCKET != m_socket)
		{
			close(m_socket);
			m_socket = INVALID_SOCKET;
		}

	}
	
	// 绑定ip
	virtual bool Bind(const string& ip, unsigned int port)
	{
		bool result = false;
		if (INVALID_SOCKET != m_socket)
		{
            struct sockaddr* server = NULL;
            if( m_supportIpv6 ) {
                sockaddr_in6 iddr;
                iddr.sin6_family = AF_INET6;
                iddr.sin6_port = htons(port);
                char ipv6_buf[1024] = {0};
                sprintf(ipv6_buf, "::ffff:%s", ip.c_str());
                inet_pton(AF_INET6, ipv6_buf, &iddr.sin6_addr);
                server = (struct sockaddr*)&iddr;
                
            } else {
                sockaddr_in iddr;
                iddr.sin_family = AF_INET;
                iddr.sin_port = htons(port);
                inet_pton(AF_INET, ip.c_str(), &iddr.sin_addr);
                server = (struct sockaddr*)&iddr;
            }

			result =  SOCKET_ERROR != bind(m_socket, server, sizeof(*server));
		}
		return result;
	}

	// 连接（msTimeout：超时时间(毫秒)，不大于0表示使用默认超时）
	virtual SOCKET_RESULT_CODE Connect(const string& ip, unsigned int port, int msTimeout)
	{
		SOCKET_RESULT_CODE result = SOCKET_RESULT_FAIL;

        if( m_supportIpv6 ) {
            // 判断是否IPV6环境
            struct addrinfo hints, *res, *res0;
            bzero(&hints, sizeof(hints));
            hints.ai_family = PF_UNSPEC;
            hints.ai_socktype = SOCK_STREAM;
            hints.ai_flags = AI_DEFAULT;
            
            int error = getaddrinfo(ip.c_str(), "http", &hints, &res0);
            if( !error ) {
                for (res = res0; res; res = res->ai_next) {
                    if(res->ai_family == AF_INET6) {
                        // ipv6
                        char ipv6_buf[INET6_ADDRSTRLEN] = { 0 };
                        sockaddr_in6 *iddr = (sockaddr_in6 *)res->ai_addr;
                        inet_ntop(res->ai_family, &(iddr->sin6_addr), ipv6_buf, sizeof(ipv6_buf));
                        iddr->sin6_port = htons(port);
                        
//                        string ipv6 = ipv6_buf;
//                        string ipv6Prev = "";
//                        string::size_type index = ipv6.find("::");
//                        if( string::npos != index ) {
//                            ipv6Prev = ipv6.substr(0, index);
//                        }
//                        
//                        char ipv_buf[INET6_ADDRSTRLEN] = { 0 };
//                        sprintf(ipv_buf, "%s::%s", ipv6Prev.c_str(), IPAddress::Ipv42Ipv6(ip).c_str());
//                        sockaddr_in6 iddr6;
//                        iddr6.sin6_family = AF_INET6;
//                        inet_pton(AF_INET6, ipv_buf, (void *)&iddr6.sin6_addr);
//                        iddr6.sin6_port = htons(port);
                        
                        result = Connect((struct sockaddr*)iddr, sizeof(sockaddr_in6), msTimeout);

                    } else {
                        // ipv4
                        char ipv4_buf[INET_ADDRSTRLEN] = { 0 };
                        sockaddr_in *iddr = (sockaddr_in *)res->ai_addr;
                        inet_ntop(res->ai_family, &(iddr->sin_addr), ipv4_buf, sizeof(ipv4_buf));
                        iddr->sin_port = htons(port);
                        
                        char ipv_buf[INET6_ADDRSTRLEN] = { 0 };
                        sprintf(ipv_buf, "::FFFF:%s", IPAddress::Ipv42Ipv6(ipv4_buf).c_str());
                        sockaddr_in6 iddr6;
                        iddr6.sin6_family = AF_INET6;
                        inet_pton(AF_INET6, ipv_buf, (void *)&iddr6.sin6_addr);
                        iddr6.sin6_port = htons(port);
                        
                        result = Connect((struct sockaddr*)&iddr6, sizeof(sockaddr_in6), msTimeout);
                    }
                    
                    if( result == SOCKET_RESULT_SUCCESS ) {
                        break;
					} else {
						// 当res多个时，而且前面连接不成功，socket需要close，下面用socket才能连接成功
						if (res->ai_next != NULL) {
							Close();
#ifdef IOS
							Create(true);
#else
							Create(false);
#endif
						}
					}
                }
                
            }
            
            freeaddrinfo(res0);
        } else {
            // ipv4
            sockaddr_in iddr;
            iddr.sin_family = AF_INET;
            iddr.sin_addr.s_addr = inet_addr(ip.c_str());
            iddr.sin_port = htons(port);
            
            result = Connect((struct sockaddr*)&iddr, sizeof(sockaddr_in), msTimeout);
        }

		return result;
	}
    SOCKET_RESULT_CODE Connect(struct sockaddr* server, int socketLen, int msTimeout) {
        SOCKET_RESULT_CODE result = SOCKET_RESULT_FAIL;
        
        if (INVALID_SOCKET != m_socket )
        {
			// 获取当前block状态
			bool block = IsBlock();

			SetBlock(true);

            m_connStatus = CONNECTION_STATUS_CONNECTING;
			if( msTimeout > 0 ) {
                timeval timeout;
                timeout.tv_sec = msTimeout / 1000;
                timeout.tv_usec = msTimeout % 1000;
                socklen_t len = sizeof(timeout);
                setsockopt(m_socket, SOL_SOCKET, SO_SNDTIMEO, &timeout, len);
            }

            if (connect(m_socket, (struct sockaddr*)server, socketLen) == 0) {
                result = SOCKET_RESULT_SUCCESS;
            }

            if (SOCKET_RESULT_SUCCESS == result) {
                m_connStatus = CONNECTION_STATUS_CONNECTED;
            }
            else {
                m_connStatus = CONNECTION_STATUS_DISCONNECT;
            }
            
            // 回复block状态
			SetBlock(block);
        }
        return result;
    }
    
    // 发送
    virtual HANDLE_RESULT Send(void* data, unsigned int dataLen)
	{
		HANDLE_RESULT result = HANDLE_FAIL;

		if (INVALID_SOCKET != m_socket)
		{
			if ( IsBlock() )
			{
				// blocking send
				int total = 0;
				while (true) {
					int iSent = send(m_socket, (const char*)data, dataLen, 0);
					if (iSent > 0) {
						total += iSent;
					}
					else {
                        break;
					}

					if (total == dataLen) {
						result = HANDLE_SUCCESS;
						break;
					}
				}
			}
			else
			{
				// non blocking send
				int iSent = send(m_socket, (const char*)data, dataLen, 0);
				if (iSent > 0
					|| (iSent < 0 && (EWOULDBLOCK == errno || EINTR == errno)))
				{
					result = HANDLE_SUCCESS;
				}
			}
		}
		return result;
	}
	
	// 接收
	virtual HANDLE_RESULT Recv(void* data, unsigned int dataSize, unsigned int& dataLen, bool bRecvAll)
	{
		HANDLE_RESULT result = HANDLE_FAIL;

		if (INVALID_SOCKET != m_socket)
		{
			if ( IsBlock() )
			{
				// blocking receive
				int length = 0;
				dataLen = 0;
				while( dataLen < dataSize ) {
					length = recv(m_socket, (char*)data + dataLen, dataSize - dataLen, 0);
                    if (length > 0) {
                        dataLen += length;
                        if( !bRecvAll ) {
                            // 如果不需要全部接收, 直接返回
                            break;
                        }
                    } else {
                        break;
                    }
                }
                
				if ( (bRecvAll && (dataLen == dataSize)) || (!bRecvAll && dataLen > 0) ) {
                    // 1.标记为全部接收并且接收足够数据
                    // 2.没有标记全部接收并且接收到数据
					result = HANDLE_SUCCESS;
                }
			}
			else
			{
				// non blocking receive

				// 初始化超时时间(300ms)
				unsigned int uiTimeout = 300;
				// 初始化超时时间
				timeval tout;
				tout.tv_sec = uiTimeout / 1000;
				tout.tv_usec = (uiTimeout % 1000) * 1000;

				// 初始化fd_set
				fd_set rset;
				FD_ZERO(&rset);
				FD_SET(m_socket, &rset);
				int iRetS = select(m_socket + 1, &rset, NULL, NULL, &tout);

				//FileLog("LiveChatClient", "ILSLiveChatSocketHandler::Recv() iRetS:%d", iRetS);

				if (iRetS == 0) {
					// 超时
					result = HANDLE_TIMEOUT;
				}
	            else if (iRetS > 0)
	            {
	            	// 有数据可以接收
	                int iRet = recv(m_socket, data, dataLen, 0);
	                //FileLog("LiveChatClient", "ILSLiveChatSocketHandler::Recv() iRet:%d", iRet);
					if (iRet > 0)
					{
						result = HANDLE_SUCCESS;
					}
					else if (iRet <= 0
							&& (EWOULDBLOCK == errno || EINTR == errno))
					{
						result = HANDLE_TIMEOUT;
					}
	            }
			}
		}

		return result;
	}
    
    // 获取当前连接状态
    virtual CONNNECTION_STATUS GetConnectionStatus() const
    {
        return m_connStatus;
    }

    // 设置是否blocking
	virtual bool SetBlock(bool block)
	{
		bool result = false;
		if (INVALID_SOCKET != m_socket)
		{
			result = true;
			if (m_block != block) {
				int flags = fcntl(m_socket, F_GETFL, 0);
				if (block) {
					flags = flags & ~O_NONBLOCK;
				}
				else {
					flags = flags | O_NONBLOCK;
				}

				result = fcntl(m_socket, F_SETFL, flags) == 0;
				if (result) {
					m_block = block;
				}
			}
		}
		return result;
	}
    
    int GetSocket() {
        return m_socket;
    }
    
private:
	// 判断当前是否blocking状态
	bool IsBlock()
	{
		bool result = false;
		if (INVALID_SOCKET != m_socket)
		{
			int flags = fcntl(m_socket, F_GETFL, 0);
			result = (flags & O_NONBLOCK) == 0;
		}
		return result;
	}

private:
	SOCKET	m_socket;
	bool	m_block;
    bool    m_supportIpv6;
    CONNNECTION_STATUS m_connStatus;
};

#endif

bool ILSLiveChatSocketHandler::InitEnvironment()
{
#ifdef WIN32
	WSADATA wsaData;
	return WSAStartup(MAKEWORD(2,2), &wsaData) == NO_ERROR;
#else
	return true;
#endif
}
	
void ILSLiveChatSocketHandler::ReleaseEnvironment()
{
#ifdef WIN32
	WSACleanup();
#else

#endif
}

ILSLiveChatSocketHandler* ILSLiveChatSocketHandler::CreateSocketHandler(SOCKET_TYPE type)
{
	ILSLiveChatSocketHandler* handler = NULL;

	if (TCP_SOCKET == type) {
#ifdef WIN32
		handler = new WinTcpSocketHandler();
#else
		handler = new LinuxTcpSocketHandler();
#endif
	}
	else if (UDP_SOCKET == type) {
		
	}

	return handler;
}
	
void ILSLiveChatSocketHandler::ReleaseSocketHandler(ILSLiveChatSocketHandler* handler)
{
	delete handler;
}
