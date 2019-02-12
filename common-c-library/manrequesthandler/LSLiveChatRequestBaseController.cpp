/*
 * LSLiveChatRequestBaseController.cpp
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LSLiveChatRequestBaseController.h"
#include <common/CheckMemoryLeak.h>

LSLiveChatRequestBaseController::LSLiveChatRequestBaseController() {
	// TODO Auto-generated constructor stub

}

LSLiveChatRequestBaseController::~LSLiveChatRequestBaseController() {
	// TODO Auto-generated destructor stub
}

void LSLiveChatRequestBaseController::SetHttpRequestManager(LSLiveChatHttpRequestManager *pHttpRequestManager) {
	mpHttpRequestManager = pHttpRequestManager;
}
long LSLiveChatRequestBaseController::StartRequest(string url, HttpEntiy& entiy, ILSLiveChatHttpRequestManagerCallback* callback, SiteType type, bool bNoCache) {
	if( mpHttpRequestManager != NULL ) {
		return mpHttpRequestManager->StartRequest(url, entiy, callback, type, bNoCache);
	}
	return -1;
}

bool LSLiveChatRequestBaseController::StopRequest(long requestId, bool bWait) {
	bool bFlag = false;
	if( mpHttpRequestManager != NULL ) {
		bFlag =mpHttpRequestManager->StopRequest(requestId, bWait);
	}
	return bFlag;
}

string LSLiveChatRequestBaseController::GetContentTypeById(long requestId) {
	string contentType = "";
	if( mpHttpRequestManager != NULL ) {
		const HttpRequest* request = mpHttpRequestManager->GetRequestById(requestId);
		if ( NULL != request ) {
			contentType = request->GetContentType();
		}
	}
	return contentType;
}

// 获取body总数及已下载数
void LSLiveChatRequestBaseController::GetRecvLength(long requestId, int& total, int& recv)
{
	if (NULL != mpHttpRequestManager ) {
		const HttpRequest* request = mpHttpRequestManager->GetRequestById(requestId);
		if ( NULL != request ) {
			request->GetRecvDataCount(total, recv);
		}
	}
}

bool LSLiveChatRequestBaseController::HandleResult(const char* buf, int size, string &errnum, string &errmsg, Json::Value *data, Json::Value *errdata) {
	bool bFlag = false;

	/* try to parse json */
	Json::Value root;
	Json::Reader reader;

	string strBuf("");
	strBuf.assign(buf, size);
	if( reader.parse(strBuf, root, false) ) {
		FileLog("httprequest", "LSLiveChatRequestBaseController::HandleResult( parse Json finish )");
		if( root.isObject() ) {

            if( root[COMMON_RESULT].isInt() && root[COMMON_RESULT].asInt() == 1 ) {
                errnum = "";
                errmsg = "";
                if( data != NULL ) {
                    *data = root[COMMON_DATA];
                }

                bFlag = true;
            } else {
                if( root[COMMON_ERRNO].isString() ) {
                    errnum = root[COMMON_ERRNO].asString();
                }

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

	FileLog("httprequest", "LSLiveChatRequestBaseController::HandleResult( handle json result %s )", bFlag?"ok":"fail");

	return bFlag;
}

bool LSLiveChatRequestBaseController::HandleResult(const char* buf, int size, string &errnum, string &errmsg, TiXmlDocument &doc) {
	bool bFlag = false;

	/* try to parse xml */
	TiXmlElement* itemElement;
	doc.Parse(buf);
	const char *p = NULL;

	if ( !doc.Error() ) {
		TiXmlNode *rootNode = doc.FirstChild(COMMON_ROOT);
		if( rootNode != NULL ) {
			TiXmlNode *resultNode = rootNode->FirstChild(COMMON_RESULT);
			if( resultNode != NULL ) {
				TiXmlNode *statusNode = resultNode->FirstChild(COMMON_STATUS);
				if( statusNode != NULL ) {
					itemElement = statusNode->ToElement();
					if ( itemElement != NULL ) {
						p = itemElement->GetText();
						if( p != NULL && 1 == atoi(p) ) {
							bFlag = true;
						}
					}
				}

				TiXmlNode *errcodeNode = resultNode->FirstChild(COMMON_ERRCODE);
				if( errcodeNode != NULL ) {
					itemElement = errcodeNode->ToElement();
					if ( itemElement != NULL ) {
						p = itemElement->GetText();
						if( p != NULL ) {
							errnum = p;
						}
					}
				}

				TiXmlNode *errmsgNode = resultNode->FirstChild(COMMON_ERRMSG);
				if( errmsgNode != NULL ) {
					itemElement = errmsgNode->ToElement();
					if ( itemElement != NULL ) {
						p = itemElement->GetText();
						if( p != NULL ) {
							errmsg = p;
						}
					}
				}
			}
		}
	} else {
		FileLog("httprequest", "LSLiveChatRequestBaseController::HandleResult( Value() : %s, ErrorDesc() : %s, ErrorRow() : %d, ErrorCol() : %d )",
				doc.Value(), doc.ErrorDesc(), doc.ErrorRow(), doc.ErrorCol());
	}

	return bFlag;
}

bool LSLiveChatRequestBaseController::HandleLiveChatReqult(const char* buf, int size, string &errnum, string &errmsg, Json::Value *data, Json::Value *errdata) {
    bool bFlag = false;
    
    /* try to parse json */
    Json::Value root;
    Json::Reader reader;
    Json::Value resultRoot;
    
    string strBuf("");
    strBuf.assign(buf, size);
    int status = 0;
    if( reader.parse(strBuf, root, false) ) {
        FileLog("httprequest", "LSLiveChatRequestBaseController::HandleLiveChatReqult( parse Json finish )");
        if( root.isObject() ) {
            if( root[COMMON_RESULT].isObject() ) {
                resultRoot = root[COMMON_RESULT];
                if (resultRoot[COMMON_STATUS].isNumeric()) {
                    status = resultRoot[COMMON_STATUS].asInt();
                }
                if (resultRoot[COMMON_ERRCODE].isString()) {
                    errnum = resultRoot[COMMON_ERRCODE].asString();
                }
                if (resultRoot[COMMON_ERRMSG].isString()) {
                    errmsg = resultRoot[COMMON_ERRMSG].asString();
                }
                if( data != NULL ) {
                    *data = root;
                }
                
                bFlag = (status == 1) ? true : false;
            }
        }
    }
    
    FileLog("httprequest", "LSLiveChatRequestBaseController::HandleLiveChatReqult( handle json result %s )", bFlag?"ok":"fail");
    
    return bFlag;
}

// 将直播的http接口6.2.获取帐号余额
bool LSLiveChatRequestBaseController::HandleLSResult(const char* buf, int size, int &errnum, string &errmsg, Json::Value *data, Json::Value *errdata) {
    bool bFlag = false;
    
    /* try to parse json */
    Json::Value root;
    Json::Reader reader;
    
    string strBuf("");
    strBuf.assign(buf, size);
    if( reader.parse(strBuf, root, false) ) {
        FileLog("httprequest", "LSLiveChatRequestBaseController::HandleLSResult( parse Json finish )");
        if( root.isObject() ) {
            if (root[COMMON_ERRNO].isNumeric()) {
                errnum = root[COMMON_ERRNO].asInt();
            }
            errmsg = "";
            if (errnum == 0) {
                if (data != NULL) {
                    *data = root[COMMON_DATA];
                }
                bFlag = true;
            } else {
                if (root[COMMON_ERRMSG].isString()) {
                    errmsg = root[COMMON_ERRMSG].asString();
                }
                bFlag = false;
            }
        }
    }
    
    FileLog("httprequest", "LSLiveChatRequestBaseController::HandleLSResult( handle json result %s )", bFlag?"ok":"fail");
    
    return bFlag;
}
