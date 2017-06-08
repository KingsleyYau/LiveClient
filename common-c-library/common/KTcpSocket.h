/*
 * KTcpSocket.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef KTcpSocket_H_
#define KTcpSocket_H_

#include "KSocket.h"

#include <netdb.h>
#include <netinet/tcp.h>
#include <netinet/in.h>

class KTcpSocket: public KSocket {
public:
	KTcpSocket();
	virtual ~KTcpSocket();
	KTcpSocket operator=(const KTcpSocket &obj);

	void SetAddress(struct sockaddr_in addr);
	string GetIP();
	int GetPort();

	bool IsConnected();
	void SetConnnected();
	/*
	 * Client
	 */
	/*
	 * Connect一般用法都是阻塞(可以不阻塞)，所以bBlock意思是连接成功后的socket发送和接收数据是否阻塞
	 * uiTimeout:仅设置了nonblocking时候有效
	 */
	virtual int Connect(string strAddress, unsigned int uiPort, bool bBlocking = false);
	virtual int SendData(char* pBuffer, unsigned int uiSendLen, unsigned int uiTimeout = 3000);
	virtual int RecvData(char* pBuffer, unsigned int uiRecvLen, bool bRecvAll = true, bool* pbAlive = NULL, unsigned int uiTimeout = 1000);

	/*
	 * Server
	 */
    virtual bool Bind(unsigned int iPort, string ip = "");

    /*
     * maxSocketCount:最大可等待Accpet的连接数
     * bBlocking:Accept是否阻塞
     */
    virtual bool Listen(int maxSocketCount, bool bBlocking = false);
    /*
     * bBlocking:Accept后的socket是否阻塞
     * uiTimeout:仅设置了nonblocking时候有效
     */
    virtual KTcpSocket Accept(unsigned int uiTimeout = 3000, bool bBlocking = false);

	virtual void Close();

protected:
	int m_iPort;
	string m_sAddress;
	bool m_bConnected;
};

#endif /* KTcpSocket_H_ */
