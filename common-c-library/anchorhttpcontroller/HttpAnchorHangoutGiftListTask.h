/*
 * HttpAnchorHangoutGiftListTask.h
 *
 *  Created on: 2018-4-4
 *      Author: Alex
 *        desc: 6.8.获取多人互动直播间礼物列表
 */

#ifndef HttpAnchorHangoutGiftListTask_H_
#define HttpAnchorHangoutGiftListTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBitem/HttpAnchorHangoutGiftListItem.h"


class HttpAnchorHangoutGiftListTask;

class IRequestAnchorHangoutGiftListCallback {
public:
	virtual ~IRequestAnchorHangoutGiftListCallback(){};
	virtual void OnAnchorHangoutGiftList(HttpAnchorHangoutGiftListTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorHangoutGiftListItem& hangoutGiftItem) = 0;
};
      
class HttpAnchorHangoutGiftListTask : public ZBHttpRequestTask {
public:
	HttpAnchorHangoutGiftListTask();
	virtual ~HttpAnchorHangoutGiftListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorHangoutGiftListCallback* pCallback);

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
	IRequestAnchorHangoutGiftListCallback* mpCallback;
    // 多人互动直播间ID
    string mRoomId;


};

#endif /* HttpAnchorHangoutGiftListTask_H */
