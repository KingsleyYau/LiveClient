/*
 * HttpAnchorCheckIsPlayProgramTask.h
 *
 *  Created on: 2018-4-24
 *      Author: Alex
 *        desc: 7.4.检测是否开播节目直播
 */

#ifndef HttpAnchorCheckIsPlayProgramTask_H_
#define HttpAnchorCheckIsPlayProgramTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"


class HttpAnchorCheckIsPlayProgramTask;

class IRequestAnchorCheckIsPlayProgramCallback {
public:
	virtual ~IRequestAnchorCheckIsPlayProgramCallback(){};
	virtual void OnAnchorCheckPublicRoomType(HttpAnchorCheckIsPlayProgramTask* task, bool success, int errnum, const string& errmsg, AnchorPublicRoomType liveShowType, const string& liveShowId) = 0;
};
      
class HttpAnchorCheckIsPlayProgramTask : public ZBHttpRequestTask {
public:
	HttpAnchorCheckIsPlayProgramTask();
	virtual ~HttpAnchorCheckIsPlayProgramTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorCheckIsPlayProgramCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAnchorCheckIsPlayProgramCallback* mpCallback;

};

#endif /* HttpAnchorCheckIsPlayProgramTask_H */
