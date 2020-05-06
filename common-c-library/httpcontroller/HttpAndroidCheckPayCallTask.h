/*
 * HttpAndroidCheckPayCallTask.h
 *
 *  Created on: 2019-12-10
 *      Author: Alex
 *        desc: 16.3.购买成功上传校验送点（仅Android）
 */

#ifndef HttpAndroidCheckPayCallTask_H_
#define HttpAndroidCheckPayCallTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpAndroidCheckPayCallTask;

class IRequestAndroidCheckPayCallCallback {
public:
	virtual ~IRequestAndroidCheckPayCallCallback(){};
	virtual void OnAndroidCheckPayCall(HttpAndroidCheckPayCallTask* task, bool success, const string& code, const string& errmsg) = 0;
};
      
class HttpAndroidCheckPayCallTask : public HttpRequestTask {
public:
	HttpAndroidCheckPayCallTask();
	virtual ~HttpAndroidCheckPayCallTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAndroidCheckPayCallCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  LSPaidCallType callType,
                  string manid,
                  string orderNo,
                  string number,
                  string token,
                  string data
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAndroidCheckPayCallCallback* mpCallback;

};

#endif /* HttpAndroidCheckPayCallTask_H_ */
