/*
 * HttpSetFavoriteTask.h
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 6.3.添加／取消收藏
 */

#ifndef HttpSetFavoriteTask_H_
#define HttpSetFavoriteTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpSetFavoriteTask;

class IRequestSetFavoriteCallback {
public:
	virtual ~IRequestSetFavoriteCallback(){};
	virtual void OnSetFavorite(HttpSetFavoriteTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpSetFavoriteTask : public HttpRequestTask {
public:
	HttpSetFavoriteTask();
	virtual ~HttpSetFavoriteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSetFavoriteCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& userId,
                    const string& roomId,
                    bool isFav
                  );
    
    const string& GetUserId();
    const string& GetRoomId();
    bool GetIsFav();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSetFavoriteCallback* mpCallback;
    // 主播ID
    string mUserId;
    // 直播间ID（可无，无则表示不在直播间操作）
    string mRoomId;
    // 是否收藏（0:否 1:是）
    bool mIsFav;

};

#endif /* HttpSetFavoriteTask_H_ */
