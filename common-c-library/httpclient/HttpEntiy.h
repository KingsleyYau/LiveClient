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
    void SetNoHeader();
    void SetIsDownLoadFile(bool isDownload);
    
    void SetRawData(string data);
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
    string mRawData;
	string mAuthorization;
	bool mIsGetMethod;
	bool mbSaveCookie;
    double mDownloadTimeout;
    unsigned int mConnectTimeout;
    bool mNoHeader;
    // 接口是否是下载文件（为了如果服务器返回的大小不知道，而curl会按照超时判断断http停止，如果是文件这个已经收到数据了，服务器已经记录完成了）alex,2019-09-21
    bool mIsDownloadFile;
};

#endif
