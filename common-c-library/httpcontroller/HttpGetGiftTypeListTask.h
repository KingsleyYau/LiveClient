/*
 * HttpGetGiftTypeListTask.h
 *
 *  Created on: 2019-08-27
 *      Author: Alex
 *        desc: 3.17.获取虚拟礼物分类列表
 */

#ifndef HttpGetGiftTypeListTask_H_
#define HttpGetGiftTypeListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpGiftTypeItem.h"
#include "HttpRequestEnum.h"

class HttpGetGiftTypeListTask;

class IRequestGetGiftTypeListtCallback {
public:
	virtual ~IRequestGetGiftTypeListtCallback(){};
	virtual void OnGetGiftTypeList(HttpGetGiftTypeListTask* task, bool success, int errnum, const string& errmsg, const GiftTypeList typeList) = 0;
};
      
class HttpGetGiftTypeListTask : public HttpRequestTask {
public:
	HttpGetGiftTypeListTask();
	virtual ~HttpGetGiftTypeListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetGiftTypeListtCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    LSGiftRoomType roomType
                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetGiftTypeListtCallback* mpCallback;

};

#endif /* HttpGetGiftTypeListTask_H_ */
