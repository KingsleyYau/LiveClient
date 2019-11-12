/*
 * HttpChangeCartGiftNumberTask.h
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.9.修改购物车商品数量
 */

#ifndef HttpChangeCartGiftNumberTask_H_
#define HttpChangeCartGiftNumberTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpChangeCartGiftNumberTask;

class IRequestChangeCartGiftNumberCallback {
public:
	virtual ~IRequestChangeCartGiftNumberCallback(){};
	virtual void OnChangeCartGiftNumber(HttpChangeCartGiftNumberTask* task, bool success, int errnum, const string& errmsg, int status) = 0;
};
      
class HttpChangeCartGiftNumberTask : public HttpRequestTask {
public:
	HttpChangeCartGiftNumberTask();
	virtual ~HttpChangeCartGiftNumberTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestChangeCartGiftNumberCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& anchorId,
                    const string& giftId,
                    int giftNumber
                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestChangeCartGiftNumberCallback* mpCallback;

};

#endif /* HttpChangeCartGiftNumberTask_H_ */
