/*
 * HttpGetShareLinkTask.h
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 6.11.获取分享链接
 */

#ifndef HttpGetShareLinkTask_H_
#define HttpGetShareLinkTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpGetShareLinkTask;

class IRequestGetShareLinkCallback {
public:
    virtual ~IRequestGetShareLinkCallback(){};
    virtual void OnGetShareLink(HttpGetShareLinkTask* task, bool success, int errnum, const string& errmsg, const string& shareId, const string& shareLink) = 0;
};

class HttpGetShareLinkTask : public HttpRequestTask {
public:
    HttpGetShareLinkTask();
    virtual ~HttpGetShareLinkTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestGetShareLinkCallback* pCallback);
    
    /**
     * 获取分享链接
     * shareuserId          发起分享的主播/观众ID
     * anchorId             被分享的主播ID
     * shareType            分享渠道（0：其它，1：Facebook，2：Twitter）
     * sharePageType        分享类型（1：主播资料页，2：免费公开直播间）
     */
    void SetParam(
                  string shareuserId,
                  string anchorId,
                  ShareType shareType,
                  SharePageType sharePageType
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestGetShareLinkCallback* mpCallback;
    
    string mShareuserId;              // 发起分享的主播/观众ID
    string mAnchorId;                 // 被分享的主播ID
    ShareType mShareType;             // 分享渠道（0：其它，1：Facebook，2：Twitter）
    SharePageType mSharePageType;     // 分享类型（1：主播资料页，2：免费公开直播间）
};

#endif /* HttpGetShareLinkTask_H_ */
