/*
 * HttpGetHangoutGiftListTask.h
 *
 *  Created on: 2018-5-8
 *      Author: Alex
 *        desc: 8.6.获取多人互动直播间可发送的礼物列表
 */

#ifndef HttpGetHangoutGiftListTask_H_
#define HttpGetHangoutGiftListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpHangoutGiftListItem.h"

class HttpGetHangoutGiftListTask;

class IRequestGetHangoutGiftListCallback {
public:
	virtual ~IRequestGetHangoutGiftListCallback(){};
	virtual void OnGetHangoutGiftList(HttpGetHangoutGiftListTask* task, bool success, int errnum, const string& errmsg, const HttpHangoutGiftListItem& item) = 0;
};
      
class HttpGetHangoutGiftListTask : public HttpRequestTask {
public:
	HttpGetHangoutGiftListTask();
	virtual ~HttpGetHangoutGiftListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetHangoutGiftListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& roomId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetHangoutGiftListCallback* mpCallback;
   
    string mRoomId;         // 直播间ID

};

#endif /* HttpGetHangoutGiftListTask_H_ */
