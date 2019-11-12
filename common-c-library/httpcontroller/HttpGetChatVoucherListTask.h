/*
 * HttpGetChatVoucherListTask.h
 *
 *  Created on: 2019-9-11
 *      Author: Alex
 *        desc: 5.7.获取LiveChat聊天试用券列表
 */

#ifndef HttpGetChatVoucherListTask_H_
#define HttpGetChatVoucherListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpVoucherItem.h"

class HttpGetChatVoucherListTask;

class IRequestGetChatVoucherListCallback {
public:
	virtual ~IRequestGetChatVoucherListCallback(){};
	virtual void OnGetChatVoucherList(HttpGetChatVoucherListTask* task, bool success, const string& errnum, const string& errmsg, const VoucherList& list, int totalCount) = 0;
};
      
class HttpGetChatVoucherListTask : public HttpRequestTask {
public:
	HttpGetChatVoucherListTask();
	virtual ~HttpGetChatVoucherListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetChatVoucherListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  int start,
                  int step
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetChatVoucherListCallback* mpCallback;
    

};

#endif /* HttpGetChatVoucherListTask_H_ */
