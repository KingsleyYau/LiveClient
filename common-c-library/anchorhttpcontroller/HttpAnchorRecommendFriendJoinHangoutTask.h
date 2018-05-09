/*
 * HttpAnchorRecommendFriendJoinHangoutTask.h
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *        desc: 6.2.主播推荐好友给观众
 */

#ifndef HttpAnchorRecommendFriendJoinHangoutTask_H_
#define HttpAnchorRecommendFriendJoinHangoutTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class HttpAnchorRecommendFriendJoinHangoutTask;

class IRequestAnchorRecommendFriendJoinHangoutCallback {
public:
	virtual ~IRequestAnchorRecommendFriendJoinHangoutCallback(){};
	virtual void OnAnchorRecommendFriend(HttpAnchorRecommendFriendJoinHangoutTask* task, bool success, int errnum, const string& errmsg, const string& anchorId) = 0;
};
      
class HttpAnchorRecommendFriendJoinHangoutTask : public ZBHttpRequestTask {
public:
	HttpAnchorRecommendFriendJoinHangoutTask();
	virtual ~HttpAnchorRecommendFriendJoinHangoutTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorRecommendFriendJoinHangoutCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& friendId,
                    const string& roomId
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAnchorRecommendFriendJoinHangoutCallback* mpCallback;
    // 主播好友ID
    string mFriendId;
    // 直播间ID
    string mRoomId;

};

#endif /* HttpAnchorRecommendFriendJoinHangoutTask */
