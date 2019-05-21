/*
 * HttpGetSayHiAnchorListTask.h
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.2.获取可发Say Hi的主播列表
 */

#ifndef HttpGetSayHiAnchorListTask_H_
#define HttpGetSayHiAnchorListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpSayHiAnchorItem.h"

class HttpGetSayHiAnchorListTask;

class IRequestGetSayHiAnchorListCallback {
public:
	virtual ~IRequestGetSayHiAnchorListCallback(){};
	virtual void OnGetSayHiAnchorList(HttpGetSayHiAnchorListTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiAnchorList& list) = 0;
};
      
class HttpGetSayHiAnchorListTask : public HttpRequestTask {
public:
	HttpGetSayHiAnchorListTask();
	virtual ~HttpGetSayHiAnchorListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetSayHiAnchorListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetSayHiAnchorListCallback* mpCallback;

};

#endif /* HttpGetSayHiAnchorListTask_H_ */
