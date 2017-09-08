/*
 * HttpGetTalentListTask.h
 *
 *  Created on: 2017-8-28
 *      Author: Alex
 *        desc: 3.10.获取才艺点播列表
 */

#ifndef HttpGetTalentListTask_H_
#define HttpGetTalentListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpGetTalentItem.h"

class HttpGetTalentListTask;

class IRequestGetTalentListCallback {
public:
	virtual ~IRequestGetTalentListCallback(){};
	virtual void OnGetTalentList(HttpGetTalentListTask* task, bool success, int errnum, const string& errmsg, const TalentItemList& list) = 0;
};
      
class HttpGetTalentListTask : public HttpRequestTask {
public:
	HttpGetTalentListTask();
	virtual ~HttpGetTalentListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetTalentListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string roomId
                  );
    
    /**
     *  直播间ID
     */
    const string& GetRoomId();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetTalentListCallback* mpCallback;
    
    // 直播间ID
    string mRoomId;
    
    //TalentItemList mItemList;

};

#endif /* HttpGetTalentListTask_H_ */
