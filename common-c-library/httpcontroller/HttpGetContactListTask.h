/*
 * HttpGetContactListTask.h
 *
 *  Created on: 2019-6-17
 *      Author: Alex
 *        desc: 3.16.获取我的联系人列表
 */

#ifndef HttpGetContactListTask_H_
#define HttpGetContactListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpRecommendAnchorItem.h"

class HttpGetContactListTask;

class IRequestGetContactListCallback {
public:
	virtual ~IRequestGetContactListCallback(){};
	virtual void OnGetContactList(HttpGetContactListTask* task, bool success, int errnum, const string& errmsg, const RecommendAnchorList& listItem, int totalCount) = 0;
};
      
class HttpGetContactListTask : public HttpRequestTask {
public:
	HttpGetContactListTask();
	virtual ~HttpGetContactListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetContactListCallback* pCallback);

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
	IRequestGetContactListCallback* mpCallback;

};

#endif /* HttpGetContactListTask_H_ */
