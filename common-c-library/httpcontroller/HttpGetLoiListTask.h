/*
 * HttpGetLoiListTask.h
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.1.获取意向信列表
 */

#ifndef HttpGetLoiListTask_H_
#define HttpGetLoiListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpLetterListItem.h"

class HttpGetLoiListTask;

class IRequestGetLoiListCallback {
public:
	virtual ~IRequestGetLoiListCallback(){};
	virtual void OnGetLoiList(HttpGetLoiListTask* task, bool success, int errnum, const string& errmsg, const HttpLetterItemList& letterList) = 0;
};
      
class HttpGetLoiListTask : public HttpRequestTask {
public:
	HttpGetLoiListTask();
	virtual ~HttpGetLoiListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLoiListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    LSLetterTag tag,
                    int start,
                    int step
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetLoiListCallback* mpCallback;

};

#endif /* HttpGetLoiListTask_H_ */
