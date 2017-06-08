/*
 * IPAddress.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IPADDRESS_H_
#define IPADDRESS_H_
#include <string>

#include <list>
using namespace std;

typedef struct _ipAddressNetworkInfo {
	string name;
	string ip;
	string broad;
	string netmask;
	string dst;
	string mac;
	char macByte[8];
	bool bUp;
	bool bPPP;

	_ipAddressNetworkInfo() {
		bUp = false;
		bPPP = false;
		memset(macByte, 0, sizeof(macByte));
	}

}IpAddressNetworkInfo;

class IPAddress {
public:
	IPAddress();
	virtual ~IPAddress();

	static list<IpAddressNetworkInfo> GetNetworkInfoList();

	static list<string> GetDeviceList();
	static list<string> GetMacAddressList();
	static list<string> GetIPAddress();
	static list<string> GetBroadAddress();
    
    static string Ipv42Ipv6(string ipv4);
};

#endif /* IPADDRESS_H_ */
