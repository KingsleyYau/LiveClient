/*
 * LSLiveChatHttpRequestHostManager.cpp
 *
 *  Created on: 2015-3-12
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LSLiveChatHttpRequestHostManager.h"
#include <common/CheckMemoryLeak.h>

LSLiveChatHttpRequestHostManager::LSLiveChatHttpRequestHostManager() {
	// TODO Auto-generated constructor stub

}

LSLiveChatHttpRequestHostManager::~LSLiveChatHttpRequestHostManager() {
	// TODO Auto-generated destructor stub
}

string LSLiveChatHttpRequestHostManager::GetHostByType(SiteType type) {
	string host = "";

	switch( type ) {
	case AppSite:{
		host = GetAppSite();
	}break;
	case WebSite:{
		host = GetWebSite();
	}break;
	case ChatVoiceSite:{
		host = GetChatVoiceSite();
	}break;
    case FakeSite:{
        host = GetFakeSite();
    }break;
    case ChangeSite:{
        host = GetChangeSite();
    }break;
	default:break;
	}

	FileLog("httprequest", "LSLiveChatHttpRequestHostManager::GetHostByType( "
			"type : %d, "
			"host : %s "
			")",
			type,
			host.c_str()
			);

	return host;
}

void LSLiveChatHttpRequestHostManager::SetWebSite(string webSite) {
	mWebSite = webSite;
}

string LSLiveChatHttpRequestHostManager::GetWebSite() {
	return mWebSite;
}

void LSLiveChatHttpRequestHostManager::SetAppSite(string appSite) {
	mAppSite = appSite;
}

void LSLiveChatHttpRequestHostManager::SetChatVoiceSite(string chatVoiceSite) {
	mChatVoiceSite = chatVoiceSite;
}

string LSLiveChatHttpRequestHostManager::GetChatVoiceSite() {
	return mChatVoiceSite;
}

string LSLiveChatHttpRequestHostManager::GetAppSite() {
	return mAppSite;
}

void LSLiveChatHttpRequestHostManager::SetFakeSite(string fakeSite) {
    mFakeSite = fakeSite;
}

string LSLiveChatHttpRequestHostManager::GetFakeSite() {
    return mFakeSite;
}

void LSLiveChatHttpRequestHostManager::SetChangeSite(string changeSite) {
    mChangeSite = changeSite;
}
string LSLiveChatHttpRequestHostManager::GetChangeSite() {
    return mChangeSite;
}
