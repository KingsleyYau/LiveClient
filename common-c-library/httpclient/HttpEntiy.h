/*
 * HttpEntiy.h
 *
 *  Created on: 2014-12-24
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef _INC_HttpEntiy_
#define _INC_HttpEntiy_

#include <string>
#include <map>
#include "HttpLiveShowLog.h"
using namespace std;

typedef map<string, string> HttpMap;

typedef struct _tagFileMapItem
{
	string	fileName;
	string	mimeType;
} FileMapItem;
typedef map<string, FileMapItem> FileMap;

class HttpEntiy {
	friend class HttpClient;

public:
	HttpEntiy();
	virtual ~HttpEntiy();

	void AddHeader(string key, string value);
	void SetKeepAlive(bool isKeepAlive);
	void SetAuthorization(string user, string password);
	void SetGetMethod(bool isGetMethod);
	void SetSaveCookie(bool isSaveCookie);
    void SetConnectTimeout(unsigned int connectTimeout); 
    void SetDownloadTimeout(double downloadTimeout); // downloadTimeout=1.0 is 1 second.

	void AddContent(string key, string value);
	void AddFile(string key, string fileName, string mimeType = "image/jpeg");

	void Reset();
    
    /**
     获取请求参数(调试输出)

     @return 参数文本输出
     */
    string GetContentDesc();
    
private:
	HttpMap mHeaderMap;
	HttpMap mContentMap;
	FileMap mFileMap;
	string mAuthorization;
	bool mIsGetMethod;
	bool mbSaveCookie;
    double mDownloadTimeout;
    unsigned int mConnectTimeout;
};

#endif
