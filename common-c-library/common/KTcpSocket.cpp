/*
 * KTcpSocket.cpp
 *
 *  Created on: 2014-12-24
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "KTcpSocket.h"
#include "Arithmetic.h"
#include "config.h"

#ifndef _WIN32  /* _WIN32 */
#include <unistd.h>
#endif  /* _WIN32 */

KTcpSocket::KTcpSocket() {
	// TODO Auto-generated constructor stub
	m_sAddress = "";
	m_iPort = 0;
	m_bConnected = false;
}

KTcpSocket::~KTcpSocket() {
	// TODO Auto-generated destructor stub
}

KTcpSocket KTcpSocket::operator=(const KTcpSocket &obj) {
	DLog("jni.KTcpSocket::operator=", "obj:(%p) \n", &obj);
	this->m_Socket = obj.m_Socket;
	this->m_sAddress = obj.m_sAddress;
	this->m_iPort = obj.m_iPort;
	this->m_bConnected = obj.m_bConnected;
	this->m_bBlocking = obj.m_bBlocking;
	return *this;
}

void KTcpSocket::SetConnnected() {
	m_bConnected = true;
}

bool KTcpSocket::IsConnected() {
	return m_bConnected;
}
void KTcpSocket::SetAddress(struct sockaddr_in addr) {
	m_sAddress = KSocket::IpToString(addr.sin_addr.s_addr);
	m_iPort = ntohs(addr.sin_port);
}
string KTcpSocket::GetIP() {
	return m_sAddress;
}
int KTcpSocket::GetPort() {
	return m_iPort;
}

/*
 * Client
 */
/*
 *
 */
int KTcpSocket::Connect(string strAddress, unsigned int uiPort, bool bBlocking) {
	m_sAddress = strAddress;
	m_iPort = uiPort;

	int iRet = -1, iFlag = 1;
	struct sockaddr_in dest;
	hostent* hent = NULL;
	if ((m_Socket = socket(AF_INET, SOCK_STREAM, 0)) >= 0) {
		DLog("common", "KTcpSocket::Connect( create socket(%d) ok ) \n", m_Socket);

		bool bCanSelect = (m_Socket > 1023)?false:true;
		DLog("common", "KTcpSocket::Connect( bCanSelect : %s ) \n", bCanSelect?"true":"false");

		if( !bCanSelect  && !bBlocking ) {
			ELog("common", "KTcpSocket::Connect( nonblocking and can not be select : %s ) \n", bCanSelect?"true":"false");
			iRet = -1;
			goto EXIT_ERROR_TCP;
		}

		bzero(&dest, sizeof(dest));
		dest.sin_family = AF_INET;
		dest.sin_port = htons(uiPort);

		dest.sin_addr.s_addr = inet_addr((const char*)strAddress.c_str());
		if (dest.sin_addr.s_addr == 0xffffffff) {
			if ((hent = gethostbyname((const char*)strAddress.c_str())) != NULL) {
				dest.sin_family = hent->h_addrtype;
				memcpy((char*)&dest.sin_addr, hent->h_addr, hent->h_length);
				m_sAddress = KSocket::IpToString(dest.sin_addr.s_addr);
				DLog("common", "KTcpSocket::Connect( gethostbyname address : %s, ip : %s ) \n",
										(const char*)strAddress.c_str(), m_sAddress.c_str());
			} else {
				ELog("common", "KTcpSocket::Connect( gethostbyname address : %s fail, %s ) \n",
						(const char*)strAddress.c_str(), hstrerror(h_errno));
				iRet = -1;
				goto EXIT_ERROR_TCP;
			}
		}


		setsockopt(m_Socket, IPPROTO_TCP, TCP_NODELAY, (const char *)&iFlag, sizeof(iFlag));

		iFlag = 1500;
		setsockopt(m_Socket, SOL_SOCKET, SO_RCVBUF, (const char *)&iFlag, sizeof(iFlag));

		iFlag = 1;
		setsockopt(m_Socket, SOL_SOCKET, SO_REUSEADDR, (const char *)&iFlag, sizeof(iFlag));

		if(setBlocking(!bCanSelect)) {

		}
		else {
			iRet = -1;
			ELog("common", "KTcpSocket::Connect( setBlocking : %d fail ) \n", !bCanSelect);
			goto EXIT_ERROR_TCP;
		}

		DLog("common", "KTcpSocket::Connect( start connect [%s:%d] ) \n", m_sAddress.c_str(), uiPort);
		if (connect(m_Socket, (struct sockaddr *)&dest, sizeof(dest)) != -1) {
			iRet = 1;
		}
		else {
			fd_set wset;
			struct timeval tout;
			tout.tv_sec = 10;
			tout.tv_usec = 0;
			FD_ZERO(&wset);
			FD_SET(m_Socket, &wset);
			int iRetS = select(m_Socket + 1, NULL, &wset, NULL, &tout);
			if (iRetS > 0) {
				int error, len;
				getsockopt(m_Socket, SOL_SOCKET, SO_ERROR, &error, (socklen_t *)&len);
				if(error == 0) {
					iRet = 1;
				}
				else {
					iRet = -1;
					ELog("common", "KTcpSocket::Connect( connect timeout ) \n");
					goto EXIT_ERROR_TCP;
				}

			} else {
				ELog("common", "KTcpSocket::Connect( connect timeout ) \n");
				iRet = -1;
				goto EXIT_ERROR_TCP;
			}
		}

		DLog("common", "KTcpSocket::Connect( connect ok ) \n");
		if(setBlocking(bBlocking)) {

		}
		else {
			iRet = -1;
			ELog("common", "KTcpSocket::Connect( set blocking fail ) \n");
			goto EXIT_ERROR_TCP;
		}


	    /*deal with the tcp keepalive
	      iKeepAlive = 1 (check keepalive)
	      iKeepIdle = 600 (active keepalive after socket has idled for 10 minutes)
	      KeepInt = 60 (send keepalive every 1 minute after keepalive was actived)
	      iKeepCount = 3 (send keepalive 3 times before disconnect from peer)
	     */
	    int iKeepAlive = 1, iKeepIdle = 15, KeepInt = 15, iKeepCount = 2;
	    if (setsockopt(m_Socket, SOL_SOCKET, SO_KEEPALIVE, (void*)&iKeepAlive, sizeof(iKeepAlive)) < 0) {
	    	iRet = -1;
	    	ELog("common", "KTcpSocket::Connect( setsockopt SO_KEEPALIVE fail ) \n");
	    	goto EXIT_ERROR_TCP;
	    }
	    if (setsockopt(m_Socket, IPPROTO_TCP, TCP_KEEPIDLE, (void*)&iKeepIdle, sizeof(iKeepIdle)) < 0) {
	    	iRet = -1;
	    	ELog("common", "KTcpSocket::Connect( setsockopt TCP_KEEPIDLE fail ) \n");
	    	goto EXIT_ERROR_TCP;
	    }
	    if (setsockopt(m_Socket, IPPROTO_TCP, TCP_KEEPINTVL, (void *)&KeepInt, sizeof(KeepInt)) < 0) {
	    	iRet = -1;
	    	ELog("common", "KTcpSocket::Connect( setsockopt TCP_KEEPINTVL fail ) \n");
	    	goto EXIT_ERROR_TCP;
	    }
	    if (setsockopt(m_Socket, IPPROTO_TCP, TCP_KEEPCNT, (void *)&iKeepCount, sizeof(iKeepCount)) < 0) {
	    	iRet = -1;
	    	ELog("common", "KTcpSocket::Connect( setsockopt TCP_KEEPCNT fail ) \n");
	    	goto EXIT_ERROR_TCP;
	    }
	    DLog("common", "KTcpSocket::Connect( setsockopt ok, KeepInt : %d, iKeepCount : %d, iKeepIdle : %d ) \n", \
	    		KeepInt, iKeepCount, iKeepIdle);

	    iRet = 1;
	}
	else {
		ELog("common", "KTcpSocket::Connect( create socket fail ) \n");
	}

EXIT_ERROR_TCP:
	if ( iRet != 1 ) {
		Close();
		ELog("common", "KTcpSocket::Connect( connect fail )\n");
	}
	else {
		m_bConnected = true;
	}
	return iRet;
}
int KTcpSocket::SendData(char* pBuffer, unsigned int uiSendLen, unsigned int uiTimeout) {
	unsigned int uiBegin = GetTick();
	string log = "";
	int iOrgLen = uiSendLen;
	int iRet = -1, iRetS = -1;
	int iSendedLen = 0;
	fd_set wset;

    if(!IsConnected()) {
        goto EXIT_TCP_SEND;
    }

//	log = Arithmetic::AsciiToHexWithSep(pBuffer, uiSendLen);
//	DLog("common", "KTcpSocket::SendData( ready send socket(%d) [%s:%d] ( %d bytes ) HEX:\n%s ) \n",
//			m_Socket, m_sAddress.c_str(), m_iPort, uiSendLen, log.c_str() );

	if(m_bBlocking) {
		iRet = send(m_Socket, pBuffer, uiSendLen, 0);
		goto EXIT_TCP_SEND;
	}
	else {
		while (true) {
			struct timeval tout;
			tout.tv_sec = uiTimeout / 1000;
			tout.tv_usec = (uiTimeout % 1000) * 1000;
			FD_ZERO(&wset);
			FD_SET(m_Socket, &wset);
			iRetS = select(m_Socket + 1, NULL, &wset, NULL, &tout);
			if (iRetS == -1) {
				iRet = -1;
				goto EXIT_TCP_SEND;
			} else if (iRetS == 0) {
				iRet = iSendedLen;
				goto EXIT_TCP_SEND;
			}

			iRet = send(m_Socket, pBuffer, uiSendLen, 0);
			if (iRet == -1 || (iRetS == 1 && iRet == 0)) {
				usleep(100);
				if (EWOULDBLOCK == errno) {
					if (IsTimeout(uiBegin, uiTimeout)) {
						iRet = iSendedLen;
						goto EXIT_TCP_SEND;
					}
					continue;
				} else {
					if (iSendedLen == 0){
						iRet = -1;
						goto EXIT_TCP_SEND;
					}
					iRet = iSendedLen;
					goto EXIT_TCP_SEND;
				}
			} else if (iRet == 0) {
				iRet = iSendedLen;
				goto EXIT_TCP_SEND;
			}
			pBuffer += iRet;
			iSendedLen += iRet;
			uiSendLen -= iRet;
			if (iSendedLen >= iOrgLen) {
				iRet = iSendedLen;
				goto EXIT_TCP_SEND;
			}
			if (IsTimeout(uiBegin, uiTimeout)) {
				iRet = iSendedLen;
				goto EXIT_TCP_SEND;
			}
		}
	}

EXIT_TCP_SEND:
	if(iRet == -1) {
		DLog("common", "KTcpSocket::SendData( send fail ) \n");
		Close();
	}
	else {
		DLog("common", "KTcpSocket::SendData( send ( %d bytes ) ) \n", iRet);
	}
	return iRet;
}

int KTcpSocket::RecvData(char* pBuffer, unsigned int uiRecvLen, bool bRecvAll, bool* pbAlive, unsigned int uiTimeout) {
	unsigned int uiBegin = GetTick();
	int iOrgLen = uiRecvLen;
	int iRet = -1, iRetS = -1;
	int iRecvedLen = 0;
	bool bAlive = true;
	fd_set rset;

    if(!IsConnected()) {
    	bAlive = false;
        goto EXIT_TCP_RECV;
    }

	if(m_bBlocking) {
		iRet = recv(m_Socket, pBuffer, uiRecvLen, 0);
		if(iRet > 0) {
//			string log = Arithmetic::AsciiToHexWithSep(pBuffer, iRet);
//			DLog("common", "KTcpSocket::RecvData( recv blocking socket(%d) [%s:%d] ( %d bytes ) bytes Hex:\n%s ) \n",
//					m_Socket, m_sAddress.c_str(), m_iPort, iRet, log.c_str());
		}
		else {
			bAlive = false;
		}
		goto EXIT_TCP_RECV;
	}
	else {
		while (true) {
			timeval tout;
			tout.tv_sec = uiTimeout / 1000;
			tout.tv_usec = (uiTimeout % 1000) * 1000;
			FD_ZERO(&rset);
			FD_SET(m_Socket, &rset);
			iRetS = select(m_Socket + 1, &rset, NULL, NULL, &tout);

			if (iRetS == -1) {
				ELog("common", "KTcpSocket::RecvData( socket(%d) noting to recv break ) \n", m_Socket);
				iRet = -1;
				bAlive = false;
				goto EXIT_TCP_RECV;
			} else if (iRetS == 0) {
//				DLog("common", "KTcpSocket::RecvData( (socket:%d) %d timeout break already recv %d bytes) ) \n", m_Socket,  uiTimeout / 1000, iRecvedLen);
				iRet = iRecvedLen;
				goto EXIT_TCP_RECV;
			}
            else {
                iRet = recv(m_Socket, pBuffer, uiRecvLen, 0);
                if(iRet == 0) {
                    DLog("common", "KTcpSocket::RecvData( remote close break )\n");
                    iRet = iRecvedLen;
                    bAlive = false;
                    goto EXIT_TCP_RECV;
                }
                else if (iRet == -1){
                    // ����Ƿ񱻶��Ͽ�����
                    usleep(1000);
                    DLog("common", "KTcpSocket::RecvData( errno : %d ) \n", errno);
                    if (EWOULDBLOCK == errno || EINTR == errno){
                        DLog("common", "KTcpSocket::RecvData(  EWOULDBLOCK || EINTR ) \n");
                        if (IsTimeout(uiBegin, uiTimeout)){
                            iRet = iRecvedLen;
                            goto EXIT_TCP_RECV;
                        }
                        continue;
                    } else {
                        ELog("common", "KTcpSocket::RecvData( local close break ) \n");
                        iRet = iRecvedLen;
                        bAlive = false;
                        goto EXIT_TCP_RECV;
                    }
                }

//                string log = Arithmetic::AsciiToHexWithSep(pBuffer, iRet);
//                DLog("common", "KTcpSocket::RecvData( recv nonblocking socket(%d) [%s:%d] ( %d bytes ) Hex :\n%s ) \n",
//                		m_Socket, m_sAddress.c_str(), m_iPort, iRet, log.c_str());

                pBuffer += iRet;
                iRecvedLen += iRet;
                uiRecvLen -= iRet;
                if (iRecvedLen >= iOrgLen) {
                    iRet = iRecvedLen;
                    goto EXIT_TCP_RECV;
                }
                if (!bRecvAll) {
                    iRet = iRecvedLen;
                    goto EXIT_TCP_RECV;
                }
                if (IsTimeout(uiBegin, uiTimeout)){
                    iRet = iRecvedLen;
                    goto EXIT_TCP_RECV;
                }
            }
		}
	}

EXIT_TCP_RECV:
	if(m_bBlocking && bAlive == false) {
		DLog("common", "KTcpSocket::RecvData( blocking tcp socket(%d) [%s:%d] break ) \n",
				m_Socket, m_sAddress.c_str(), m_iPort);
		Close();
	}
	else if(iRet == -1 || bAlive == false) {
		DLog("common", "KTcpSocket::RecvData( nonblocking tcp socket(%d) [%s:%d] break ) \n",
				m_Socket, m_sAddress.c_str(), m_iPort);
		Close();
	}

    if(pbAlive != NULL) {
        *pbAlive = bAlive;
    }
	return iRet;
}

/*
 * Server
 */
bool KTcpSocket::Bind(unsigned int iPort, string ip) {
	bool bFlag = false;
	if((m_Socket = socket(AF_INET, SOCK_STREAM, 0)) < 0){
		// create socket error;
		ELog("common", "KTcpSocket::Bind( create socket fail ) \n");
		bFlag = false;
		goto EXIT_TCP_BIND;
	}
	else {
		DLog("common", "KTcpSocket::Bind( create socket(%d) ok ) \n", m_Socket);
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
	if(bind(m_Socket, (struct sockaddr *)&localAddr, sizeof(localAddr)) < 0) {
		// bind socket error
		ELog("common", "KTcpSocket::Bind( bind (%s:%d) fail ) \n", KSocket::IpToString(localAddr.sin_addr.s_addr).c_str(), iPort);
		bFlag = false;
		goto EXIT_TCP_BIND;
	}
	else {
		DLog("common", "KTcpSocket::Bind( bind (%s:%d) ok ) \n", KSocket::IpToString(localAddr.sin_addr.s_addr).c_str(), iPort);
		bFlag = true;
	}

EXIT_TCP_BIND:
	if(!bFlag) {
		Close();
	}
    return bFlag;
}

bool KTcpSocket::Listen(int maxSocketCount, bool bBlocking) {
	bool bFlag = false;
    if (listen(m_Socket, maxSocketCount) == -1) {
        ELog("common", "KTcpSocket::Listen( listen socket fail ) \n");
		bFlag = false;
		goto EXIT_TCP_LISTEN;
    }
    else {
		DLog("common", "KTcpSocket::Listen( listen socket ok, max queun (%d) ) \n", maxSocketCount);
		bFlag = true;
	}

    m_bBlocking = bBlocking;
EXIT_TCP_LISTEN:
	if(!bFlag) {
		Close();
	}
	return bFlag;
}
KTcpSocket KTcpSocket::Accept(unsigned int uiTimeout, bool bBlocking) {
    KTcpSocket clientSocket;
    socket_type accpetSocket = -1;

    struct sockaddr_in remoteAddr;
	bzero(&remoteAddr, sizeof(remoteAddr));
	socklen_t iRemoteAddrLen = sizeof(struct sockaddr_in);

	int iRet = -1;
	if(m_bBlocking) {
		// ����
	}
	else {
		// ������
		struct timeval tout;
		tout.tv_sec = uiTimeout / 1000;
		tout.tv_usec = (uiTimeout % 1000) * 1000;
		fd_set rset;
		FD_ZERO(&rset);
		FD_SET(m_Socket, &rset);
		int iRetS = select(m_Socket + 1, &rset, NULL, NULL, &tout);
		if (iRetS == -1) {
			iRet = -1;
			goto EXIT_TCP_ACCEPT;
		} else if (iRetS == 0) {
			iRet = 0;
			goto EXIT_TCP_ACCEPT;
		}
	}

	accpetSocket = accept(m_Socket, (struct sockaddr *)&remoteAddr, &iRemoteAddrLen);

	if(accpetSocket != -1) {
		DLog("common", "KTcpSocket::Listen( accept socket:(%d) ok ) \n", accpetSocket);

	    /*deal with the tcp keepalive
	      iKeepAlive = 1 (check keepalive)
	      iKeepIdle = 600 (active keepalive after socket has idled for 10 minutes)
	      KeepInt = 60 (send keepalive every 1 minute after keepalive was actived)
	      iKeepCount = 3 (send keepalive 3 times before disconnect from peer)
	     */
	    int iKeepAlive = 1, iKeepIdle = 15, KeepInt = 15, iKeepCount = 2;
	    if (setsockopt(accpetSocket, SOL_SOCKET, SO_KEEPALIVE, (void*)&iKeepAlive, sizeof(iKeepAlive)) < 0) {
	    	iRet = -1;
	    	ELog("common", "KTcpSocket::Listen( setsockopt SO_KEEPALIVE fail ) \n");
	    	goto EXIT_TCP_ACCEPT;
	    }
	    if (setsockopt(accpetSocket, IPPROTO_TCP, TCP_KEEPIDLE, (void*)&iKeepIdle, sizeof(iKeepIdle)) < 0) {
	    	iRet = -1;
	    	ELog("common", "KTcpSocket::Listen( setsockopt TCP_KEEPIDLE fail ) \n");
	    	goto EXIT_TCP_ACCEPT;
	    }
	    if (setsockopt(accpetSocket, IPPROTO_TCP, TCP_KEEPINTVL, (void *)&KeepInt, sizeof(KeepInt)) < 0) {
	    	iRet = -1;
	    	ELog("common", "KTcpSocket::Listen( setsockopt TCP_KEEPINTVL fail ) \n");
	    	goto EXIT_TCP_ACCEPT;
	    }
	    if (setsockopt(accpetSocket, IPPROTO_TCP, TCP_KEEPCNT, (void *)&iKeepCount, sizeof(iKeepCount)) < 0) {
	    	iRet = -1;
	    	ELog("common", "KTcpSocket::Listen( setsockopt TCP_KEEPCNT fail ) \n");
	    	goto EXIT_TCP_ACCEPT;
	    }
	    DLog("common", "KTcpSocket::Listen( setsockopt ok KeepInt : %d, iKeepCount : %d, iKeepIdle : %d ) \n", \
	    		KeepInt, iKeepCount, iKeepIdle);

		clientSocket.setScoket(accpetSocket);
		clientSocket.SetAddress(remoteAddr);
		clientSocket.SetConnnected();
		clientSocket.setBlocking(bBlocking);

		iRet = 1;
	}

EXIT_TCP_ACCEPT:
	if(iRet == -1) {
		Close();
	}
	return clientSocket;
}

void KTcpSocket::Close() {
	KSocket::Close();
	m_bConnected = false;
}
