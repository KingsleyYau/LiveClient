/*
 * ZBHttpRequestTask.cpp
 *
 *  Created on: 2018-3-1
 *      Author: Max
 */

#include "ZBHttpRequestTask.h"

ZBHttpRequestTask::ZBHttpRequestTask() {
	// TODO Auto-generated constructor stub
	mpRequest = NULL;
	mPath = "";
	mNoCache = false;
	mbFinishOK = false;
	mErrCode = "";
	mpErrcodeHandler = NULL;
    mpHttpRequestManager = NULL;
    
    mHttpEntiy.AddHeader("zb", "1");
}

ZBHttpRequestTask::~ZBHttpRequestTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpRequestTask::Init(HttpRequestManager *pHttpRequestManager) {
	mpHttpRequestManager = pHttpRequestManager;
}

void ZBHttpRequestTask::SetErrcodeHandler(ZBErrcodeHandler* pErrcodeHandler) {
	mpErrcodeHandler = pErrcodeHandler;
}

bool ZBHttpRequestTask::Start() {
    bool bFlag = false;
    
    // 启动父类业务
	if( ZBHttpBaseTask::Start() ) {
        // 启动子类业务
		if( NULL != StartRequest() ) {
			bFlag = true;
            
		} else {
			OnTaskFinish();
		}
	}
    
	return bFlag;
}

void ZBHttpRequestTask::Stop() {
    // 停止子类业务
	StopRequest();
    
    // 停止父类业务
	return ZBHttpBaseTask::Stop();
}

bool ZBHttpRequestTask::IsFinishOK() {
	return mbFinishOK;
}

const char* ZBHttpRequestTask::GetErrCode() {
	return mErrCode.c_str();
}

const HttpRequest* ZBHttpRequestTask::StartRequest() {
	if( mpHttpRequestManager != NULL && mPath.length() > 0 ) {
		mpRequest = mpHttpRequestManager->StartRequest(mPath, mHttpEntiy, this);
	}
	return mpRequest;
}

void ZBHttpRequestTask::StopRequest() {
	if( mpHttpRequestManager != NULL && mpRequest != NULL ) {
		mpHttpRequestManager->StopRequest(mpRequest);
		mpRequest = NULL;
	}
}

bool ZBHttpRequestTask::ParseCommon(const char* buf, int size, string &errnum, string &errmsg, Json::Value *data, Json::Value *errdata) {
	bool bFlag = false;

    // 默认错误码是解析错误
    errnum = LOCAL_ERROR_CODE_PARSEFAIL;
    errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
    
	// Try Parse JSON
	Json::Value root;
	Json::Reader reader;

	if( reader.parse(buf, root, false) ) {
		FileLog(LIVESHOW_HTTP_LOG, "ZBHttpRequestTask::ParseCommon( [Parse Json Finish], task : %p )", this);
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
    
	FileLog(LIVESHOW_HTTP_LOG, "ZBHttpRequestTask::ParseCommon( [Handle Json %s], task : %p, errnum : %s )", bFlag?"Success":"Fail", this, errnum.c_str());
    
	return bFlag;
}

bool ZBHttpRequestTask::ParseLiveCommon(const char* buf, int size, int &errnum, string &errmsg, Json::Value *data, Json::Value *errdata) {
    bool bFlag = false;
    
    // 默认错误码是解析错误
    errnum = LOCAL_LIVE_ERROR_CODE_PARSEFAIL;
    errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
    
    // Try Parse JSON
    Json::Value root;
    Json::Reader reader;
    
    if( reader.parse(buf, root, false) ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpRequestTask::ParseLiveCommon( [Parse Json Finish], task : %p )", this);
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
    
    
    FileLog(LIVESHOW_HTTP_LOG, "ZBHttpRequestTask::ParseLiveCommon( [Handle Json %s], task : %p, errnum : %d )", bFlag?"Success":"Fail", this, errnum);
    
    return bFlag;
}

// ios 支付的头部
bool ZBHttpRequestTask::ParseIOSPaid(const char* buf, int size, string &code, Json::Value *data) {
    bool result = false;
    
    Json::Value root;
    Json::Reader reader;
    
    string strBuf("");
    strBuf.assign(buf, size);
    if( reader.parse(strBuf, root, false) ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpRequestTask::ParseIOSPaid( parse Json finish )");
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


void ZBHttpRequestTask::OnFinish(HttpRequest* request, bool bFlag, const char* buf, int size) {
	// Handle in sub class
	mbFinishOK = ParseData(request->GetUrl(), bFlag, buf, size);

	// Send message to main thread
	OnTaskFinish();
}

