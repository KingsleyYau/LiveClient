/*
 *HttpAnchorGetShowRoomInfoTask.h
 *
 *  Created on: 2018-4-24
 *      Author: Alex
 *        desc: 7.3.获取可进入的节目信息
 */

#ifndef HttpAnchorGetShowRoomInfoTask_H_
#define HttpAnchorGetShowRoomInfoTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBitem/HttpAnchorProgramInfoItem.h"


class HttpAnchorGetShowRoomInfoTask;

class IRequestAnchorGetShowRoomInfoCallback {
public:
	virtual ~IRequestAnchorGetShowRoomInfoCallback(){};
	virtual void OnAnchorGetShowRoomInfo(HttpAnchorGetShowRoomInfoTask* task, bool success, int errnum, const string& errmsg, HttpAnchorProgramInfoItem showInfo, const string& roomId) = 0;
};
      
class HttpAnchorGetShowRoomInfoTask : public ZBHttpRequestTask {
public:
	HttpAnchorGetShowRoomInfoTask();
	virtual ~HttpAnchorGetShowRoomInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorGetShowRoomInfoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& liveShowId
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAnchorGetShowRoomInfoCallback* mpCallback;
    // 节目ID
    string mLiveShowId;
};

#endif /* HttpAnchorCheckIsPlayProgramTask_H */
