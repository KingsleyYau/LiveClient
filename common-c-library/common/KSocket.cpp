/*
 * KSocket.cpp
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "KSocket.h"
#ifndef _WIN32  /* _WIN32 */
#include <unistd.h>
#endif  /* _WIN32 */

KSocket::KSocket() {
	// TODO Auto-generated constructor stub
	m_Socket = -1;
	m_bBlocking = false;
//	m_pSocketMutex = new DrMutex();
}

KSocket::~KSocket() {
	// TODO Auto-generated destructor stub
//	if(m_pSocketMutex != NULL) {
//		delete m_pSocketMutex;
//		m_pSocketMutex = NULL;
//	}
}

socket_type KSocket::getSocket() {
	return m_Socket;
}
void KSocket::setScoket(socket_type socket) {
	m_Socket = socket;
}
bool KSocket::setBlocking(bool bBlocking) {
	bool bFlag = false;
	int iFlag = 1;
	if(m_Socket != -1) {
		if ((iFlag = fcntl(m_Socket, F_GETFL, 0)) != -1) {
			DLog("common", "KSocket::setBlocking( fcntl socket(%d) : 0x%x ) \n", m_Socket, iFlag);
			if (!bBlocking) {
				// set nonblocking
				if (fcntl(m_Socket, F_SETFL, iFlag | O_NONBLOCK) != -1) {
					DLog("common", "KSocket::setBlocking( fcntl set socket(%d) nonblocking ) \n", m_Socket);
					m_bBlocking = bBlocking;
					bFlag = true;
				}
				else {
					ELog("common", "KSocket::setBlocking( fcntl set socket(%d) nonblocking fail ) \n", m_Socket);
					bFlag = false;
				}
			}
			else {
				// set blocking
				if (fcntl(m_Socket, F_SETFL, iFlag & ~O_NONBLOCK) != -1) {
					DLog("common", "KSocket::setBlocking( fcntl set socket(%d) blocking ) \n", m_Socket);
					m_bBlocking = bBlocking;
					bFlag = true;
				}
				else {
					ELog("common", "KSocket::setBlocking( fcntl set socket(%d) blocking ) \n", m_Socket);
					bFlag = false;
				}
			}

		}
		else {
			ELog("common", "KSocket::setBlocking( fcntl get socket(%d) fail ) \n", m_Socket);
			bFlag = false;
		}
	}
	else {
		ELog("common", "KSocket::setBlocking( no socket create ) \n");
		bFlag = false;
	}

	if ((iFlag = fcntl(m_Socket, F_GETFL, 0)) != -1) {
		DLog("common", "KSocket::setBlocking( fcntl get socket(%d) : 0x%x ) \n", m_Socket, iFlag);
	}

	return bFlag;
}
bool KSocket::IsBlocking() {
	return m_bBlocking;
}
void KSocket::Close() {
	if (m_Socket != -1) {
		DLog("common", "KSocket::Close( close socket:(%d) ) \n", m_Socket);
		shutdown(m_Socket, SHUT_RDWR);
		close(m_Socket);
		m_Socket = -1;
	}
}

unsigned int KSocket::StringToIp(const char* string_ip) {
    unsigned int dwIPAddress = inet_addr(string_ip);

    if (dwIPAddress != INADDR_NONE &&
            dwIPAddress != INADDR_ANY)
    {
        return dwIPAddress;
    }

    return dwIPAddress;
}
string KSocket::IpToString(unsigned int ip_addr) {
    struct in_addr in_ip;
    string stringip = "";
    in_ip.s_addr = ip_addr;
    stringip =  inet_ntoa(in_ip);
    return stringip;
}
unsigned int KSocket::GetTick()
{
	timeval tNow;
	gettimeofday(&tNow, NULL);
	if (tNow.tv_usec != 0){
		return (tNow.tv_sec * 1000 + (unsigned int)(tNow.tv_usec / 1000));
	}else{
		return (tNow.tv_sec * 1000);
	}
}

bool KSocket::IsTimeout(unsigned int uiStart, unsigned int uiTimeout)
{
	DLog("common", "KSocket::IsTimeout( uiStart : %d, uiTimeout:%d ) \n", uiStart, uiTimeout);
	unsigned int uiCurr = GetTick();
	unsigned int uiDiff;

	if (uiTimeout == 0)
		return false;
	if (uiCurr >= uiStart) {
		uiDiff = uiCurr - uiStart;
	}else{
		uiDiff = (0xFFFFFFFF - uiStart) + uiCurr;
	}
	if(uiDiff >= uiTimeout){
		return true;
	}
	return false;
}
