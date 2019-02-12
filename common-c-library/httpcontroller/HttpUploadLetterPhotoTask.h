/*
 * HttpUploadLetterPhotoTask.h
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.6.上传附件
 */

#ifndef HttpUploadLetterPhotoTask_H_
#define HttpUploadLetterPhotoTask_H_

#include "HttpRequestTask.h"
#include "item/HttpLetterListItem.h"

class HttpUploadLetterPhotoTask;

class IRequestUploadLetterPhotoCallback {
public:
	virtual ~IRequestUploadLetterPhotoCallback(){};
	virtual void OnUploadLetterPhoto(HttpUploadLetterPhotoTask* task, bool success, int errnum, const string& errmsg, const string& url, const string& md5, const string& fileName) = 0;
};
      
class HttpUploadLetterPhotoTask : public HttpRequestTask {
public:
	HttpUploadLetterPhotoTask();
	virtual ~HttpUploadLetterPhotoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestUploadLetterPhotoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  string file,
                  string fileName
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestUploadLetterPhotoCallback* mpCallback;
    string mFileName;

};

#endif /* HttpUploadLetterPhotoTask_H_ */
