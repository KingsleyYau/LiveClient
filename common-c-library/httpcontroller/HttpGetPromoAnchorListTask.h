/*
 * HttpGetPromoAnchorListTask.h
 *
 *  Created on: 2017-9-05
 *      Author: Alex
 *        desc: 3.14.获取推荐主播列表
 */

#ifndef HttpGetPromoAnchorListTask_H_
#define HttpGetPromoAnchorListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpLiveRoomInfoItem.h"

class HttpGetPromoAnchorListTask;

class IRequestGetPromoAnchorListCallback {
public:
	virtual ~IRequestGetPromoAnchorListCallback(){};
	virtual void OnGetPromoAnchorList(HttpGetPromoAnchorListTask* task, bool success, int errnum, const string& errmsg, const AdItemList& listItem) = 0;
};
      
class HttpGetPromoAnchorListTask : public HttpRequestTask {
public:
	HttpGetPromoAnchorListTask();
	virtual ~HttpGetPromoAnchorListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetPromoAnchorListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    int number,
                    PromoAnchorType type,
                    const string& userId
                  );
    
    int GetNumber();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetPromoAnchorListCallback* mpCallback;
    // 获取推荐个数
    int mNumber;
    // 获取界面的类型（1:直播间 2:主播个人页）
    PromoAnchorType mType;
    // 当前界面的主播ID，返回结果将不包含当前主播（可无， 无则表示不过滤结果）
    string mUserId;
};

#endif /* HttpGetPromoAnchorListTask_H_ */
