/*
 * HttpUploadFailPayInfoTask.h
 *
 *  Created on: 2019-12-10
 *      Author: Alex
 *        desc: 16.4.Google购买失败信息上传（仅Android）
 */

#ifndef HttpUploadFailPayInfoTask_H_
#define HttpUploadFailPayInfoTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpUploadFailPayInfoTask;

class IRequestUploadFailPayInfoCallback {
public:
	virtual ~IRequestUploadFailPayInfoCallback(){};
	virtual void OnUploadFailPayInfo(HttpUploadFailPayInfoTask* task, bool success, const string& code, const string& errmsg) = 0;
};
      
class HttpUploadFailPayInfoTask : public HttpRequestTask {
public:
	HttpUploadFailPayInfoTask();
	virtual ~HttpUploadFailPayInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestUploadFailPayInfoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  string manid,
                  string orderNo,
                  string number,
                  string errNo,
                  string errMsg
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestUploadFailPayInfoCallback* mpCallback;

};

#endif /* HttpUploadFailPayInfoTask_H_ */
