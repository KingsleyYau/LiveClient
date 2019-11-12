/*
 * HttpGetResentRecipientListTask.h
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.4.获取Resent Recipient主播列表
 */

#ifndef HttpGetResentRecipientListTask_H_
#define HttpGetResentRecipientListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpRecipientAnchorItem.h"

class HttpGetResentRecipientListTask;

class IRequestGetResentRecipientListCallback {
public:
	virtual ~IRequestGetResentRecipientListCallback(){};
	virtual void OnGetResentRecipientList(HttpGetResentRecipientListTask* task, bool success, int errnum, const string& errmsg, const RecipientAnchorList& list) = 0;
};
      
class HttpGetResentRecipientListTask : public HttpRequestTask {
public:
	HttpGetResentRecipientListTask();
	virtual ~HttpGetResentRecipientListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetResentRecipientListCallback* pCallback);

    /**
     *
     */
    void SetParam(

                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetResentRecipientListCallback* mpCallback;

};

#endif /* HttpGetResentRecipientListTask_H_ */
