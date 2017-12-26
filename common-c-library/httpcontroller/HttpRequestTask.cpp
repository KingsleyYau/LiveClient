/*
 * HttpRequestTask.cpp
 *
 *  Created on: 2015-9-10
 *      Author: Max
 */

#include "HttpRequestTask.h"

HttpRequestTask::HttpRequestTask() {
	// TODO Auto-generated constructor stub
	mpRequest = NULL;
	mPath = "";
	mNoCache = false;
	mbFinishOK = false;
	mErrCode = "";
	mpErrcodeHandler = NULL;
    mpHttpRequestManager = NULL;
}

HttpRequestTask::~HttpRequestTask() {
	// TODO Auto-generated destructor stub
}

void HttpRequestTask::Init(HttpRequestManager *pHttpRequestManager) {
	mpHttpRequestManager = pHttpRequestManager;
}

void HttpRequestTask::SetErrcodeHandler(ErrcodeHandler* pErrcodeHandler) {
	mpErrcodeHandler = pErrcodeHandler;
}

bool HttpRequestTask::Start() {
    bool bFlag = false;
    
    // 启动父类业务
	if( HttpBaseTask::Start() ) {
        // 启动子类业务
		if( NULL != StartRequest() ) {
			bFlag = true;
            
		} else {
			OnTaskFinish();
		}
	}
    
	return bFlag;
}

void HttpRequestTask::Stop() {
    // 停止子类业务
	StopRequest();
    
    // 停止父类业务
	return HttpBaseTask::Stop();
}

bool HttpRequestTask::IsFinishOK() {
	return mbFinishOK;
}

const char* HttpRequestTask::GetErrCode() {
	return mErrCode.c_str();
}

const HttpRequest* HttpRequestTask::StartRequest() {
	if( mpHttpRequestManager != NULL && mPath.length() > 0 ) {
		mpRequest = mpHttpRequestManager->StartRequest(mPath, mHttpEntiy, this);
	}
	return mpRequest;
}

void HttpRequestTask::StopRequest() {
	if( mpHttpRequestManager != NULL && mpRequest != NULL ) {
		mpHttpRequestManager->StopRequest(mpRequest);
		mpRequest = NULL;
	}
}

bool HttpRequestTask::ParseCommon(const char* buf, int size, string &errnum, string &errmsg, Json::Value *data, Json::Value *errdata) {
	bool bFlag = false;

    // 默认错误码是解析错误
    errnum = LOCAL_ERROR_CODE_PARSEFAIL;
    errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
    
	// Try Parse JSON
	Json::Value root;
	Json::Reader reader;

	if( reader.parse(buf, root, false) ) {
		FileLog(LIVESHOW_HTTP_LOG, "HttpRequestTask::ParseCommon( [Parse Json Finish], task : %p )", this);
		if( root.isObject() ) {
			if( root[COMMON_RESULT].isInt() && root[COMMON_RESULT].asInt() == 1 ) {
                // 解析公共结果, 返回成功
				errnum = "";
				errmsg = "";
                
				if( data != NULL ) {
					*data = root[COMMON_DATA];
				}

				bFlag = true;
                
			} else {
                // 解析公共结果, 返回错误
				if( root[COMMON_ERRNO].isString() ) {
					errnum = root[COMMON_ERRNO].asString();

                    // 自定义错误码处理
					if( mpErrcodeHandler != NULL ) {
						mpErrcodeHandler->ErrcodeHandle(this, errnum);
					}
				}

                // 错误消息
				if( root[COMMON_ERRMSG].isString() ) {
					errmsg = root[COMMON_ERRMSG].asString();
				}

				if( errdata != NULL ) {
					*errdata = root[COMMON_ERRDATA];
				}

				bFlag = false;
			}
		}
	}

    mErrCode = errnum;
    
	FileLog(LIVESHOW_HTTP_LOG, "HttpRequestTask::ParseCommon( [Handle Json %s], task : %p, errnum : %s )", bFlag?"Success":"Fail", this, errnum.c_str());
    
	return bFlag;
}

bool HttpRequestTask::ParseLiveCommon(const char* buf, int size, int &errnum, string &errmsg, Json::Value *data, Json::Value *errdata) {
    bool bFlag = false;
    
    // 默认错误码是解析错误
    errnum = LOCAL_LIVE_ERROR_CODE_PARSEFAIL;
    errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
    
    // Try Parse JSON
    Json::Value root;
    Json::Reader reader;
    
    if( reader.parse(buf, root, false) ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpRequestTask::ParseLiveCommon( [Parse Json Finish], task : %p )", this);
        if( root.isObject() ) {
            if( root[COMMON_ERRNO].isInt()) {
                 // 解析公共结果, 返回成功
                errnum = root[COMMON_ERRNO].asInt();
                errmsg = "";
                if (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS) {
                    
                    if( data != NULL ) {
                        *data = root[COMMON_DATA];
                    }
                    
                    bFlag = true;
                }
                else
                {
                    // 解析公共结果, 返回错误
                    // 错误消息
                    if( root[COMMON_ERRMSG].isString() ) {
                        errmsg = root[COMMON_ERRMSG].asString();
                    }
                    bFlag = false;
                }
                
            }
        }
    }
    
    
    FileLog(LIVESHOW_HTTP_LOG, "HttpRequestTask::ParseLiveCommon( [Handle Json %s], task : %p, errnum : %d )", bFlag?"Success":"Fail", this, errnum);
    
    return bFlag;
}

// ios 支付的头部
bool HttpRequestTask::ParseIOSPaid(const char* buf, int size, string &code, Json::Value *data) {
    bool result = false;
    
    Json::Value root;
    Json::Reader reader;
    
    string strBuf("");
    strBuf.assign(buf, size);
    if( reader.parse(strBuf, root, false) ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpRequestTask::ParseIOSPaid( parse Json finish )");
        if( root.isObject() ) {
            if( root[COMMON_IOSPAY_RESULT].isInt() && root[COMMON_IOSPAY_RESULT].asInt() == 1 ) {
                code = "";
                *data = root;
                
                result = true;
            } else {
                if( root[COMMON_IIOSPAY_CODE].isString() ) {
                    code = root[COMMON_IIOSPAY_CODE].asString();
                }
                
                result = false;
            }
        }
    }
    
    return result;
}


void HttpRequestTask::OnFinish(HttpRequest* request, bool bFlag, const char* buf, int size) {
	// Handle in sub class
	mbFinishOK = ParseData(request->GetUrl(), bFlag, buf, size);

	// Send message to main thread
	OnTaskFinish();
}

