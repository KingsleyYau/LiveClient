/*
 * HttpPhoneInfoTask.h
 *
 *  Created on: 2018-11-23
 *      Author: Alex
 *        desc: 6.22.收集手机硬件信息
 */

#ifndef HttpPhoneInfoTask_H_
#define HttpPhoneInfoTask_H_

#include "HttpRequestTask.h"
#include "item/HttpVersionCheckItem.h"

class HttpPhoneInfoTask;

class IRequestPhoneInfoCallback {
public:
	virtual ~IRequestPhoneInfoCallback(){};
	virtual void OnPhoneInfo(HttpPhoneInfoTask* task, bool success, const string& errnum, const string& errmsg) = 0;
};
      
class HttpPhoneInfoTask : public HttpRequestTask {
public:
	HttpPhoneInfoTask();
	virtual ~HttpPhoneInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestPhoneInfoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& manId, int verCode, const string& verName,
                  int action, HTTP_OTHER_SITE_TYPE siteId, double density,
                  int width, int height, const string& densityDpi,
                  const string& model, const string& manufacturer, const string& os,
                  const string& release, const string& sdk, const string& language,
                  const string& region, const string& lineNumber, const string& simOptName,
                  const string& simOpt, const string& simCountryIso, const string& simState,
                  int phoneType, int networkType, const string& deviceId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestPhoneInfoCallback* mpCallback;

};

#endif /* HttpPhoneInfoTask_H_ */
