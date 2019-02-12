/*
 * HttpGetProductListTask.h
 *
 *  Created on: 2018-9-18
 *      Author: Alex
 *        desc: 10.4.标记私信已读
 */

#ifndef HttpGetProductListTask_H_
#define HttpGetProductListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPrivateMsgItem.h"

class HttpGetProductListTask;

class IRequestGetProductListCallback {
public:
	virtual ~IRequestGetProductListCallback(){};
	virtual void OnGetProductList(HttpGetProductListTask* task, bool success, int errnum, const string& errmsg, bool isModify, const string& toId) = 0;
};
      
class HttpGetProductListTask : public HttpRequestTask {
public:
	HttpGetProductListTask();
	virtual ~HttpGetProductListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetProductListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& toId,
                  const string& lastMsgId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetProductListCallback* mpCallback;
    
    string mToId;
    string mMsgId;

};

#endif /* HttpGetProductListTask_H_ */
