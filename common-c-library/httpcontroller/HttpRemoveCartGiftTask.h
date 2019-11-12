/*
 * HttpRemoveCartGiftTask.h
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.10.删除购物车商品
 */

#ifndef HttpRemoveCartGiftTask_H_
#define HttpRemoveCartGiftTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpRemoveCartGiftTask;

class IRequestRemoveCartGiftCallback {
public:
	virtual ~IRequestRemoveCartGiftCallback(){};
	virtual void OnRemoveCartGift(HttpRemoveCartGiftTask* task, bool success, int errnum, const string& errmsg, int status) = 0;
};
      
class HttpRemoveCartGiftTask : public HttpRequestTask {
public:
	HttpRemoveCartGiftTask();
	virtual ~HttpRemoveCartGiftTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestRemoveCartGiftCallback* pCallback);

    /**
     *
     */
    void SetParam(
                   const string& anchorId,
                    const string& giftId
                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestRemoveCartGiftCallback* mpCallback;

};

#endif /* HttpRemoveCartGiftTask_H_ */
