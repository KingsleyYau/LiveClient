/*
 * HttpAddCartGiftTask.h
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.8.添加购物车商品
 */

#ifndef HttpAddCartGiftTask_H_
#define HttpAddCartGiftTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpAddCartGiftTask;

class IRequestAddCartGiftCallback {
public:
	virtual ~IRequestAddCartGiftCallback(){};
	virtual void OnAddCartGift(HttpAddCartGiftTask* task, bool success, int errnum, const string& errmsg, int status) = 0;
};
      
class HttpAddCartGiftTask : public HttpRequestTask {
public:
	HttpAddCartGiftTask();
	virtual ~HttpAddCartGiftTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAddCartGiftCallback* pCallback);

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
	IRequestAddCartGiftCallback* mpCallback;

};

#endif /* HttpAddCartGiftTask_H_ */
