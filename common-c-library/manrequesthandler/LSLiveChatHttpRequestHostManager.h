/*
 * LSLiveChatHttpRequestHostManager.h
 *
 *  Created on: 2015-3-12
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATHTTPREQUESTHOSTMANAGER_H_
#define LSLIVECHATHTTPREQUESTHOSTMANAGER_H_

#include <string>
using namespace std;

#include <common/KLog.h>

typedef enum SiteType {
	AppSite,
	WebSite,
	ChatVoiceSite,
    FakeSite,
    ChangeSite,
} SiteType;

class LSLiveChatHttpRequestHostManager {
public:
	LSLiveChatHttpRequestHostManager();
	virtual ~LSLiveChatHttpRequestHostManager();

	string GetHostByType(SiteType type);
	void SetWebSite(string webSite);
	string GetWebSite();
	void SetAppSite(string appSite);
	string GetAppSite();
	void SetChatVoiceSite(string chatVoiceSite);
	string GetChatVoiceSite();
    void SetFakeSite(string fakeSite);
    string GetFakeSite();
    void SetChangeSite(string changeSite);
    string GetChangeSite();
    
private:
	string mWebSite;
	string mAppSite;
	string mChatVoiceSite;
    string mFakeSite;
    string mChangeSite;
};

#endif /* LSLIVECHATHTTPREQUESTHOSTMANAGER_H_ */
