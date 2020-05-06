/*
 * HttpGetCountryTimeZoneListTask.h
 *
 *  Created on: 2020-3-18
 *      Author: Alex
 *        desc: 17.2.获取国家时区列表
 */

#ifndef HttpGetCountryTimeZoneListTask_H_
#define HttpGetCountryTimeZoneListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpCountryTimeZoneItem.h"


class HttpGetCountryTimeZoneListTask;

class IRequestGetCountryTimeZoneListCallback {
public:
	virtual ~IRequestGetCountryTimeZoneListCallback(){};
	virtual void OnGetCountryTimeZoneList(HttpGetCountryTimeZoneListTask* task, bool success, int errnum, const string& errmsg, const CountryTimeZoneList& list) = 0;
};
      
class HttpGetCountryTimeZoneListTask : public HttpRequestTask {
public:
	HttpGetCountryTimeZoneListTask();
	virtual ~HttpGetCountryTimeZoneListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetCountryTimeZoneListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetCountryTimeZoneListCallback* mpCallback;

};

#endif /* HttpGetCountryTimeZoneListTask_H */
