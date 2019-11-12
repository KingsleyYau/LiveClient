/*
 * HttpGetCartGiftTypeNumTask.h
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.6.获取购物车礼品种类数
 */

#ifndef HttpGetCartGiftTypeNumTask_H_
#define HttpGetCartGiftTypeNumTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpGetCartGiftTypeNumTask;

class IRequestGetCartGiftTypeNumCallback {
public:
	virtual ~IRequestGetCartGiftTypeNumCallback(){};
	virtual void OnGetCartGiftTypeNum(HttpGetCartGiftTypeNumTask* task, bool success, int errnum, const string& errmsg, int num) = 0;
};
      
class HttpGetCartGiftTypeNumTask : public HttpRequestTask {
public:
	HttpGetCartGiftTypeNumTask();
	virtual ~HttpGetCartGiftTypeNumTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetCartGiftTypeNumCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& anchorId
                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetCartGiftTypeNumCallback* mpCallback;

};

#endif /* HttpGetCartGiftTypeNumTask_H_ */
