/*
 * HttpChangeFavouriteTask.h
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *        desc: 9.4.关注/取消关注节目
 */

#ifndef HttpChangeFavouriteTask_H_
#define HttpChangeFavouriteTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"


class HttpChangeFavouriteTask;

class IRequestChangeFavouriteCallback {
public:
	virtual ~IRequestChangeFavouriteCallback(){};
	virtual void OnFollowShow(HttpChangeFavouriteTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpChangeFavouriteTask : public HttpRequestTask {
public:
	HttpChangeFavouriteTask();
	virtual ~HttpChangeFavouriteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestChangeFavouriteCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& liveShowId,
                    bool isCancel
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestChangeFavouriteCallback* mpCallback;
    // 节目ID
    string mLiveShowId;
    bool   mIsCancel;
};

#endif /* HttpChangeFavouriteTask_H */
