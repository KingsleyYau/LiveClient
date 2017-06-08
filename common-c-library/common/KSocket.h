/*
 * KSocket.h
 *
 * Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 *  Description: Thread safe socket class
 */

#ifndef KSocket_H_
#define KSocket_H_

#include <string>
using namespace std;

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#ifndef IOS
#include <net/if_arp.h>
#endif
#include <resolv.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <time.h>

#include "KLog.h"

typedef int socket_type;

class KSocket {
public:
	KSocket();
	virtual ~KSocket();

	virtual void Close();

	socket_type getSocket();
	void setScoket(socket_type socket);

	bool setBlocking(bool bBlocking);
	bool IsBlocking();

	static unsigned int StringToIp(const char* string_ip);
	static string IpToString(unsigned int ip_addr);

protected:
	unsigned int GetTick();
	bool IsTimeout(unsigned int uiStart, unsigned int uiTimeout);

	socket_type m_Socket;

	// 鏄惁闃诲
	bool m_bBlocking;
};

#endif /* KSocket_H_ */
