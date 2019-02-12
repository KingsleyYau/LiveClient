/*
 * HttpBuyPrivatePhotoVideoTask.h
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.7.购买信件附件
 */

#ifndef HttpBuyPrivatePhotoVideoTask_H_
#define HttpBuyPrivatePhotoVideoTask_H_

#include "HttpRequestTask.h"
#include "item/HttpBuyAttachItem.h"

class HttpBuyPrivatePhotoVideoTask;

class IRequestBuyPrivatePhotoVideoCallback {
public:
	virtual ~IRequestBuyPrivatePhotoVideoCallback(){};
	virtual void OnBuyPrivatePhotoVideo(HttpBuyPrivatePhotoVideoTask* task, bool success, int errnum, const string& errmsg, const HttpBuyAttachItem& buyAttachItem) = 0;
};
      
class HttpBuyPrivatePhotoVideoTask : public HttpRequestTask {
public:
	HttpBuyPrivatePhotoVideoTask();
	virtual ~HttpBuyPrivatePhotoVideoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestBuyPrivatePhotoVideoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  string emfId,
                  string resourceId,
                  LSLetterComsumeType comsumeType
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestBuyPrivatePhotoVideoCallback* mpCallback;

};

#endif /* HttpBuyPrivatePhotoVideoTask_H_ */
