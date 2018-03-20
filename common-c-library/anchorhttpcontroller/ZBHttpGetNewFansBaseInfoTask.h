/*
 * ZBHttpGetNewFansBaseInfoTask.h
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *        desc: 3.2.获取指定观众信息
 */

#ifndef ZBHttpGetNewFansBaseInfoTask_H_
#define ZBHttpGetNewFansBaseInfoTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBitem/ZBHttpLiveFansInfoItem.h"

class ZBHttpGetNewFansBaseInfoTask;

class IRequestZBGetNewFansBaseInfoCallback {
public:
	virtual ~IRequestZBGetNewFansBaseInfoCallback(){};
	virtual void OnZBGetNewFansBaseInfo(ZBHttpGetNewFansBaseInfoTask* task, bool success, int errnum, const string& errmsg, const ZBHttpLiveFansInfoItem& item) = 0;
};
      
class ZBHttpGetNewFansBaseInfoTask : public ZBHttpRequestTask {
public:
	ZBHttpGetNewFansBaseInfoTask();
	virtual ~ZBHttpGetNewFansBaseInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBGetNewFansBaseInfoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& userId
                  );
    
    const string& GetUserId();
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBGetNewFansBaseInfoCallback* mpCallback;
    // 观众ID
    string mUserId;

};

#endif /* ZBHttpGetNewFansBaseInfoTask_H_ */
