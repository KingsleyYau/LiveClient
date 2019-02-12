/*
 * KUdpSocket.cpp
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "KUdpSocket.h"
#include "Arithmetic.h"
#include "KLog.h"

KUdpSocket::KUdpSocket() {
	// TODO Auto-generated constructor stub
	m_iPort = -1;
	m_bBlocking = false;
}

KUdpSocket::~KUdpSocket() {
	// TODO Auto-generated destructor stub
}
int KUdpSocket::Bind(unsigned int iPort, string ip, bool bBlocking) {
	int iRet = -1;
	if((m_Socket = socket(AF_INET, SOCK_DGRAM, 0/*IPPROTO_UDP*/)) < 0){
		// create socket error;
	    return false;
	}

	int iBuffer;
	iRet = getsockopt(m_Socket, SOL_SOCKET, SO_RCVBUF, &iBuffer, NULL);
	if(iRet != 0) {
	}

	iRet = getsockopt(m_Socket, SOL_SOCKET, SO_SNDBUF, &iBuffer, NULL);
	if(iRet != 0) {
	}

	m_bBlocking = bBlocking;
	if(m_bBlocking) {
		// set to blocking
		int iFlag = 1;
		if ((iFlag = fcntl(m_Socket, F_GETFL, 0)) == -1) {
			return iRet;
		}
		if (fcntl(m_Socket, F_SETFL, iFlag & ~O_NONBLOCK) == -1) {
			return iRet;
		}
	}
	else {
		// set to nonblocking
		int iFlag = 1;
		if ((iFlag = fcntl(m_Socket, F_GETFL, 0)) == -1) {
			return iRet;
		}
		if (fcntl(m_Socket, F_SETFL, iFlag | O_NONBLOCK) == -1) {
			return iRet;
		}
	}

	struct sockaddr_in localAddr;
	bzero(&localAddr, sizeof(localAddr));
	localAddr.sin_family = AF_INET;
	if(ip.length() > 0) {
		inet_aton(ip.c_str(), &localAddr.sin_addr);
	}
	else {
		localAddr.sin_addr.s_addr = htonl(INADDR_ANY);
	}

	localAddr.sin_port = htons(iPort);
	if(::bind(m_Socket, (struct sockaddr *)&localAddr, sizeof(localAddr)) < 0) {
		// bind socket error
		return false;
	}

	m_iPort = iPort;

	return true;
}
int KUdpSocket::SendData(string ip, unsigned int iPort, char* pBuffer, unsigned int uiSendLen) {
	int iRet = -1, iRetS = -1, iSendedLen = 0;
	int iOrgLen = uiSendLen;
	fd_set wset;

	struct sockaddr_in remoteAddr;
	bzero(&remoteAddr, sizeof(remoteAddr));
	socklen_t iremoteAddrLen = sizeof(struct sockaddr_in);
	remoteAddr.sin_family = AF_INET;
	inet_aton(ip.c_str(), &remoteAddr.sin_addr);
	remoteAddr.sin_port = htons(iPort);

	string log = Arithmetic::AsciiToHexWithSep((unsigned char*)pBuffer, uiSendLen);

	socket_type sendSocket;
	if(m_Socket > 0) {
		sendSocket = m_Socket;
	}
	else {
		if((sendSocket = socket(AF_INET, SOCK_DGRAM, 0/*IPPROTO_UDP*/)) < 0){
			// create socket error;
		    return iRet;
		}
	}
	iRet = sendto(sendSocket, pBuffer, uiSendLen, 0, (struct sockaddr *)&remoteAddr, iremoteAddrLen);


//	int iLeft;
//	iRet = ioctl(m_Socket, SIOCOUTQ, &iLeft);
//	if(iRet == JNI_OK) {
//		showLog("Jni.KUdpSocket.SendData", "缓冲区剩余包:%d", iLeft);
//	}

	return iRet;
}
int KUdpSocket::RecvData(char* pBuffer, unsigned int uiRecvLen, unsigned int uiTimeout, struct sockaddr_in* remoteAddr) {
	int iRet = -1, iRetS = -1;
	int iOrgLen = uiRecvLen;
	fd_set rset;

	if(-1 == m_Socket) {
		return iRet;
	}

	struct sockaddr_in sendAddr;
	bzero(&sendAddr, sizeof(sendAddr));
	int iSendAddrLen = sizeof(struct sockaddr_in);

	if(NULL != remoteAddr) {
		if(sizeof(*remoteAddr) != iSendAddrLen) {
			return iRet;
		}
	}

	if(m_bBlocking) {
		// blocking recv
		bzero(pBuffer, sizeof(pBuffer));
		iRet = recvfrom(m_Socket, pBuffer, uiRecvLen, 0, (struct sockaddr *)&sendAddr , &iSendAddrLen);
		memcpy((void *)remoteAddr, &sendAddr, iSendAddrLen);

		string ip = KSocket::IpToString(sendAddr.sin_addr.s_addr);
		int iPort = ntohs(sendAddr.sin_port);
		string log = Arithmetic::AsciiToHexWithSep((unsigned char*)pBuffer, iRet);
	}
	else {
		// nonblocking recv
		timeval tout;
		tout.tv_sec = uiTimeout / 1000;
		tout.tv_usec = (uiTimeout % 1000) * 1000;

		FD_ZERO(&rset);
		FD_SET(m_Socket, &rset);
		iRetS = select(m_Socket + 1, &rset, NULL, NULL, &tout);

		if(iRetS > 0) {
			bzero(pBuffer, sizeof(pBuffer));
			iRet = recvfrom(m_Socket, pBuffer, uiRecvLen, 0, (struct sockaddr *)&sendAddr , &iSendAddrLen);
			memcpy((void *)remoteAddr, &sendAddr, iSendAddrLen);

			string ip = KSocket::IpToString(sendAddr.sin_addr.s_addr);
			int iPort = ntohs(sendAddr.sin_port);
			string log = Arithmetic::AsciiToHexWithSep((unsigned char*)pBuffer, iRet);
		}
		else if(iRetS == 0){
		}
		else {
		}
	}

	return iRet;
}
