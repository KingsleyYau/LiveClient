/*
 * HttpUpdateProfileTask.h
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 6.19.修改个人信息
 */

#ifndef HttpUpdateProfileTask_H_
#define HttpUpdateProfileTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"
#include "HttpRequestConvertEnum.h"

class HttpUpdateProfileTask;

class IRequestUpdateProfileCallback {
public:
	virtual ~IRequestUpdateProfileCallback(){};
	virtual void OnUpdateProfile(HttpUpdateProfileTask* task, bool success, const string& errnum, const string& errmsg, bool isModify) = 0;
};
      
class HttpUpdateProfileTask : public HttpRequestTask {
public:
	HttpUpdateProfileTask();
	virtual ~HttpUpdateProfileTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestUpdateProfileCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  int weight,
                  int height,
                  int language,
                  int ethnicity,
                  int religion,
                  int education,
                  int profession,
                  int income,
                  int children,
                  int smoke,
                  int drink,
                  const string resume,
                  list<string> interests,
                  int zodiac
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestUpdateProfileCallback* mpCallback;

};

#endif /* HttpUpdateProfileTask_H_ */
