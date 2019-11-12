/*
 * HttpGetRecommendGiftListTask.h
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.3.获取推荐鲜花礼品列表
 */

#ifndef HttpGetRecommendGiftListTask_H_
#define HttpGetRecommendGiftListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpStoreFlowerGiftItem.h"

class HttpGetRecommendGiftListTask;

class IRequestGetRecommendGiftListCallback {
public:
	virtual ~IRequestGetRecommendGiftListCallback(){};
	virtual void OnGetRecommendGiftList(HttpGetRecommendGiftListTask* task, bool success, int errnum, const string& errmsg, const FlowerGiftList& list) = 0;
};
      
class HttpGetRecommendGiftListTask : public HttpRequestTask {
public:
	HttpGetRecommendGiftListTask();
	virtual ~HttpGetRecommendGiftListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetRecommendGiftListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& giftId,
                    const string& anchorId,
                    int number
                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetRecommendGiftListCallback* mpCallback;

};

#endif /* HttpGetRecommendGiftListTask_H_ */
