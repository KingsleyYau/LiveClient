/*
 * KUdpSocket.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef KUdpSocket_H_
#define KUdpSocket_H_

#include "KSocket.h"

class KUdpSocket : public KSocket {
public:
	KUdpSocket();
	virtual ~KUdpSocket();

	int Bind(unsigned int iPort, string ip = "", bool bBlocking = false);
	int SendData(string ip, unsigned int iPort, char* pBuffer, unsigned int uiSendLen);
	int RecvData(char* pBuffer, unsigned int uiRecvLen, unsigned int uiTimeout = 1000, struct sockaddr_in* remoteAddr = NULL);

private:
	int m_iPort;
};

#endif /* KUdpSocket_H_ */
