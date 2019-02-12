/*
 * LSLiveChatRequestEMFController.cpp
 *
 *  Created on: 2015-3-6
 *      Author: Samson.Fan
 */

#include "LSLiveChatRequestEMFController.h"
#include "LSLiveChatRequestDefine.h"
#include "LSLiveChatRequestEMFDefine.h"
#include "../common/CommonFunc.h"

LSLiveChatRequestEMFController::LSLiveChatRequestEMFController(LSLiveChatHttpRequestManager *pHttpRequestManager, const LSLiveChatRequestEMFControllerCallback& callback)
{
	// TODO Auto-generated constructor stub
	SetHttpRequestManager(pHttpRequestManager);
	m_Callback = callback;
}

LSLiveChatRequestEMFController::~LSLiveChatRequestEMFController()
{
	// TODO Auto-generated destructor stub
}

/* ILSLiveChatHttpRequestManagerCallback */
void LSLiveChatRequestEMFController::onSuccess(long requestId, string url, const char* buf, int size)
{
	FileLog("httprequest", "LSLiveChatRequestEMFController::onSuccess( url : %s, buf( size : %d ))", url.c_str(), size);
	if (size < MAX_LOG_BUFFER) {
		FileLog("httprequest", "LSLiveChatRequestEMFController::onSuccess(), buf: %s", buf);
	}

	if( url.compare(EMF_INBOXLIST_PATH) == 0 ) {
		InboxListCallbackHandle(requestId, url, true, buf, size);
	}
	else if( url.compare(EMF_INBOXMSG_PATH) == 0 ) {
		InboxMsgCallbackHandle(requestId, url, true, buf, size);
	}
	else if( url.compare(EMF_OUTBOXLIST_PATH) == 0 ) {
		OutboxListCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_OUTBOXMSG_PATH) == 0 ) {
		OutboxMsgCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_MSGTOTAL_PATH) == 0 ) {
		MsgTotalCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_SENDMSG_PATH) == 0 ) {
		SendMsgCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_UPLOADIMAGE_PATH) == 0 ) {
		UploadImageCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_UPLOADATTACH_PATH) == 0 ) {
		UploadAttachCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_DELETEMSG_PATH) == 0 ) {
		DeleteMsgCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_ADMIRERLIST_PATH) == 0 ) {
		AdmirerListCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_ADMIRERVIEWER_PATH) == 0 ) {
		AdmirerViewerCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_BLOCKLIST_PATH) == 0 ) {
		BlockListCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_BLOCK_PATH) == 0 ) {
		BlockCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_UNBLOCK_PATH) == 0 ) {
		UnblockCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_INBOXPHOTOFEE_PATH) == 0 ) {
		InboxPhotoFeeCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_PRIVATEPHOTOVIEW_PATH) == 0 ) {
		PrivatePhotoViewCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_SHORTVIDEOTHUMBPHOTO_PATH) == 0 ) {
		GetVideoThumbPhotoCallbackHandle(requestId, url, true, buf, size);
	}
	else if ( url.compare(EMF_SHORTVIDEOURL_PATH) == 0 ) {
		GetVideoUrlCallbackHandle(requestId, url, true, buf, size);
	}

	FileLog("httprequest", "LSLiveChatRequestEMFController::onSuccess() url: %s, end", url.c_str());
}

void LSLiveChatRequestEMFController::onFail(long requestId, string url)
{
	FileLog("httprequest", "LSLiveChatRequestEMFController::onFail( url : %s )", url.c_str());
	/* request fail, callback fail */
	if( url.compare(EMF_INBOXLIST_PATH) == 0 ) {
		InboxListCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if( url.compare(EMF_INBOXMSG_PATH) == 0 ) {
		InboxMsgCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if( url.compare(EMF_OUTBOXLIST_PATH) == 0 ) {
		OutboxListCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if( url.compare(EMF_OUTBOXMSG_PATH) == 0 ) {
		OutboxMsgCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if( url.compare(EMF_MSGTOTAL_PATH) == 0 ) {
		MsgTotalCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if ( url.compare(EMF_SENDMSG_PATH) == 0 ) {
		SendMsgCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if ( url.compare(EMF_UPLOADIMAGE_PATH) == 0 ) {
		UploadImageCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if ( url.compare(EMF_UPLOADATTACH_PATH) == 0 ) {
		UploadAttachCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if ( url.compare(EMF_DELETEMSG_PATH) == 0 ) {
		DeleteMsgCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if ( url.compare(EMF_ADMIRERLIST_PATH) == 0 ) {
		AdmirerListCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if ( url.compare(EMF_ADMIRERVIEWER_PATH) == 0 ) {
		AdmirerViewerCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if ( url.compare(EMF_BLOCKLIST_PATH) == 0 ) {
		BlockListCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if ( url.compare(EMF_BLOCK_PATH) == 0 ) {
		BlockCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if ( url.compare(EMF_UNBLOCK_PATH) == 0 ) {
		UnblockCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if ( url.compare(EMF_INBOXPHOTOFEE_PATH) == 0 ) {
		InboxPhotoFeeCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if ( url.compare(EMF_PRIVATEPHOTOVIEW_PATH) == 0 ) {
		PrivatePhotoViewCallbackHandle(requestId, url, false, NULL, 0);
	}
    else if ( url.compare(EMF_SHORTVIDEOTHUMBPHOTO_PATH) == 0 ) {
        GetVideoThumbPhotoCallbackHandle(requestId, url, false, NULL, 0);
    }
    else if ( url.compare(EMF_SHORTVIDEOURL_PATH) == 0 ) {
        GetVideoUrlCallbackHandle(requestId, url, false, NULL, 0);
    }

	FileLog("httprequest", "LSLiveChatRequestEMFController::onFail() url: %s, end", url.c_str());
}

void LSLiveChatRequestEMFController::onReceiveBody(long requestId, string url, const char* buf, int size)
{
	if ( url.compare(EMF_PRIVATEPHOTOVIEW_PATH) == 0 ) {
		PrivatePhotoViewRecvCallbackHandle(requestId, url, buf, size);
	}
	else if(  url.compare(EMF_SHORTVIDEOTHUMBPHOTO_PATH) == 0  ){
		GetVideoThumbPhotoRecvCallbackHandle(requestId, url, buf, size);
	}
}

// ----------------------- InboxList -----------------------
long LSLiveChatRequestEMFController::InboxList(int pageIndex, int pageSize, int sortType, const string& womanid)
{
	char temp[16];
	HttpEntiy entiy;

	// pageIndex
	sprintf(temp, "%d", pageIndex);
	entiy.AddContent(COMMON_PAGE_INDEX, temp);
	// pageSize
	sprintf(temp, "%d", pageSize);
	entiy.AddContent(COMMON_PAGE_SIZE, temp);
	// sortType
	string strSortType("");
	if (sortType < _countof(EMF_SORTBY_TYPE)) {
		strSortType = EMF_SORTBY_TYPE[sortType];
		entiy.AddContent(EMF_REQUEST_SORTBY, strSortType.c_str());
	}
	// womanid
	if(!womanid.empty()) {
		entiy.AddContent(EMF_REQUEST_WOMANID, womanid.c_str());
	}


	string url = EMF_INBOXLIST_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::InboxLIst"
			"( url:%s, pageIndex:%d, pageSize:%d, sortType:%s, womanid:%s)",
			url.c_str(), pageIndex, pageSize, strSortType.c_str(), womanid.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::InboxListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	EMFInboxList list;
	int pageIndex = 0, pageSize = 0, dataCount = 0;
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			if (dataJson.isObject()) {
				// 解析pageIndex、pageCount、dataCount
				Json::Value pageIndexJson = dataJson[COMMON_PAGE_INDEX];
				if (pageIndexJson.isIntegral()) {
					pageIndex = pageIndexJson.asInt();
				}

				Json::Value pageSizeJson = dataJson[COMMON_PAGE_SIZE];
				if (pageSizeJson.isIntegral()) {
					pageSize = pageSizeJson.asInt();
				}

				Json::Value dataCountJson = dataJson[COMMON_DATA_COUNT];
				if (dataCountJson.isIntegral()) {
					dataCount = dataCountJson.asInt();
				}

				// 解析列表
				Json::Value dataListJson = dataJson[COMMON_DATA_LIST];
				bFlag = dataListJson.isArray();
				if(bFlag) {
					for(int i = 0; i < dataListJson.size(); i++) {
						LSLCEMFInboxListItem item;
						if (item.Parsing(dataListJson.get(i, Json::Value::null))) {
							list.push_back(item);
						}
					}
				}
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestEMFController::InboxListCallbackHandle() parsing fail:"
						"(url:%s, size:%d, buf:%s)",
						url.c_str(), size, buf);
			}
		}

	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFInboxList != NULL ) {
		m_Callback.onRequestEMFInboxList(requestId, bFlag, errnum, errmsg, pageIndex, pageSize, dataCount, list);
	}
}

// ----------------------- InboxMsg -----------------------
long LSLiveChatRequestEMFController::InboxMsg(const string& messageid)
{
	HttpEntiy entiy;
	entiy.AddContent(EMF_REQUEST_MESSAGEID, messageid.c_str());

	string url = EMF_INBOXMSG_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::InboxMsg"
			"( url:%s, messageid:%s)",
			url.c_str(), messageid.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::InboxMsgCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	LSLCEMFInboxMsgItem item;
	string errnum = "";
	string errmsg = "";
	int memberType = 0;
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		Json::Value errDataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
			// success
			if(dataJson.isObject()) {
				bFlag = item.Parsing(dataJson);
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestEMFController::InboxMsgCallbackHandle() parsing fail:"
							"(url:%s, size:%d, buf:%s)",
							url.c_str(), size, buf);
			}
		}else{
			if (errDataJson.isObject()) {
				if(errDataJson[COMMON_ERRDATA_TYPE].isInt()){
					memberType = errDataJson[COMMON_ERRDATA_TYPE].asInt();
				}
			}
		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFInboxMsg != NULL ) {
		m_Callback.onRequestEMFInboxMsg(requestId, bFlag, errnum, errmsg, memberType, item);
	}
}

// ----------------------- OutboxList -----------------------
long LSLiveChatRequestEMFController::OutboxList(int pageIndex, int pageSize, int progressType, const string& womanid)
{
	char temp[16];
	HttpEntiy entiy;

	// pageIndex
	sprintf(temp, "%d", pageIndex);
	entiy.AddContent(COMMON_PAGE_INDEX, temp);
	// pageSize
	sprintf(temp, "%d", pageSize);
	entiy.AddContent(COMMON_PAGE_SIZE, temp);
	// progressType
	string strProgressType("");
	if (progressType < _countof(EMF_PROGRESS_TYPE)) {
		strProgressType = EMF_PROGRESS_TYPE[progressType];
		entiy.AddContent(EMF_REQUEST_PROGRESS, strProgressType.c_str());
	}
	// womanid
	if(!womanid.empty()) {
		entiy.AddContent(EMF_REQUEST_WOMANID, womanid.c_str());
	}


	string url = EMF_OUTBOXLIST_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::OutboxList"
			"( url:%s, pageIndex:%d, pageSize:%d, progressType:%s, womanid:%s)",
			url.c_str(), pageIndex, pageSize, strProgressType.c_str(), womanid.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::OutboxListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	EMFOutboxList list;
	int pageIndex = 0, pageSize = 0, dataCount = 0;
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			if (dataJson.isObject()) {
				// success
				// 解析pageIndex、pageCount、dataCount
				Json::Value pageIndexJson = dataJson[COMMON_PAGE_INDEX];
				if (pageIndexJson.isIntegral()) {
					pageIndex = pageIndexJson.asInt();
				}

				Json::Value pageSizeJson = dataJson[COMMON_PAGE_SIZE];
				if (pageSizeJson.isIntegral()) {
					pageSize = pageSizeJson.asInt();
				}

				Json::Value dataCountJson = dataJson[COMMON_DATA_COUNT];
				if (dataCountJson.isIntegral()) {
					dataCount = dataCountJson.asInt();
				}

				// 解析列表
				Json::Value dataListJson = dataJson[COMMON_DATA_LIST];
				bFlag = dataListJson.isArray();
				if(bFlag) {
					for(int i = 0; i < dataListJson.size(); i++) {
						LSLCEMFOutboxListItem item;
						if (item.Parsing(dataListJson.get(i, Json::Value::null))) {
							list.push_back(item);
						}
					}
				}
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestEMFController::OutboxListCallbackHandle() parsing fail:"
						"(url:%s, size:%d, buf:%s)",
						url.c_str(), size, buf);
			}
		}

	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFOutboxList != NULL ) {
		m_Callback.onRequestEMFOutboxList(requestId, bFlag, errnum, errmsg, pageIndex, pageSize, dataCount, list);
	}
}

// ----------------------- OubboxMsg -----------------------
long LSLiveChatRequestEMFController::OutboxMsg(const string& messageid)
{
	HttpEntiy entiy;
	entiy.AddContent(EMF_REQUEST_MESSAGEID, messageid.c_str());

	string url = EMF_OUTBOXMSG_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::OutboxMsg"
			"( url:%s, messageid:%s)",
			url.c_str(), messageid.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::OutboxMsgCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	LSLCEMFOutboxMsgItem item;
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			// success
			if(dataJson.isObject()) {
				bFlag = item.Parsing(dataJson);
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestEMFController::OutboxMsgCallbackHandle() parsing fail:"
											"(url:%s, size:%d, buf:%s)",
											url.c_str(), size, buf);
			}
		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFOutboxMsg != NULL ) {
		m_Callback.onRequestEMFOutboxMsg(requestId, bFlag, errnum, errmsg, item);
	}
}

// ----------------------- MsgTotal -----------------------
long LSLiveChatRequestEMFController::MsgTotal(int sortType)
{
//	char temp[16];
	HttpEntiy entiy;
	string strSortType("");
	if (sortType < _countof(EMF_SORTBY_TYPE)) {
		strSortType = EMF_SORTBY_TYPE[sortType];
		entiy.AddContent(EMF_REQUEST_SORTBY, strSortType.c_str());
	}

	string url = EMF_MSGTOTAL_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::MsgTotal"
			"( url:%s, sortType:%s)",
			url.c_str(), strSortType.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::MsgTotalCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	LSLCEMFMsgTotalItem item;
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			// success
			bFlag = item.Parsing(dataJson);

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestEMFController::MsgTotalCallbackHandle() parsing fail:"
						"(url:%s, size:%d, buf:%s)",
						url.c_str(), size, buf);
			}
		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFMsgTotal != NULL ) {
		m_Callback.onRequestEMFMsgTotal(requestId, bFlag, errnum, errmsg, item);
	}
}

// ----------------------- SendMsg -----------------------
long LSLiveChatRequestEMFController::SendMsg(const string& womanid, const string& body, bool useIntegral, int replyType, string mtab, const SendMsgGifts& gifts, const SendMsgAttachs& attachs, bool isLovecall, const string& messageId)
{
	char temp[16];
	HttpEntiy entiy;
	// womanid
	entiy.AddContent(EMF_REQUEST_WOMANID, womanid.c_str());
	// body
	entiy.AddContent(EMF_REQUEST_BODY, body.c_str());
	// useIntegral
	snprintf(temp, sizeof(temp), "%d", useIntegral ? 1 : 0);
	entiy.AddContent(EMF_REQUEST_USEINTEGRAL, temp);
    
    entiy.AddContent(EMF_REQUEST_MESSAGEID, messageId.c_str());

	// 回复类型
	if( replyType > -1 && replyType < _countof(REPLY_TYPE_ARRAY) ) {
		entiy.AddContent(EMF_REQUEST_REPLYTYPE, REPLY_TYPE_ARRAY[replyType]);
	}

	// 意向信表后缀
	if( mtab.length() > 0 ) {
		entiy.AddContent(EMF_REQUEST_MTA, mtab);
	}

	// attachinfo
	string attachInfo("");
	Json::Value giftsJson;
	SendMsgGifts::const_iterator giftIter;
	for (giftIter = gifts.begin(); giftIter != gifts.end(); giftIter++) {
		Json::Value gift;
		gift[EMF_REQUEST_ATTACH_ID] = *giftIter;
		giftsJson.append(Json::Value(gift));
	}
	Json::Value attachsJson;
	SendMsgAttachs::const_iterator attachIter;
	for (attachIter = attachs.begin(); attachIter != attachs.end(); attachIter++) {
		Json::Value attach;
		attach[EMF_REQUEST_ATTACH_ID] = *attachIter;
		attachsJson.append(Json::Value(attach));
	}
	Json::Value attachInfoJson;
	attachInfoJson[EMF_REQUEST_GIFTS] = giftsJson;
	attachInfoJson[EMF_REQUEST_ATTACHS] = attachsJson;
	Json::FastWriter jsonWriter;
	attachInfo = jsonWriter.write(attachInfoJson);
	entiy.AddContent(EMF_REQUEST_ATTACHINFO, attachInfo.c_str());

	//Lovecall
	if(isLovecall){
		string lovecallStr = "invite";
		entiy.AddContent(EMF_REQUEST_LOVECALL_FLAG, lovecallStr.c_str());
	}

	string url = EMF_SENDMSG_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::SendMsg"
			"( url:%s, womanid:%s, useIntegral:%d, attachInfo:%s, body:%s, isLovecall:%d,)",
			url.c_str(), womanid.c_str(), useIntegral, attachInfo.c_str(), body.c_str(), isLovecall);

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::SendMsgCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	LSLCEMFSendMsgItem item;
	LSLCEMFSendMsgErrorItem errItem;
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		Json::Value errDataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
			// success
			if(dataJson.isObject()) {
				bFlag = item.Parsing(dataJson);
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestEMFController::SendMsgCallbackHandle() parsing fail:"
						"(url:%s, size:%d, buf:%s)",
						url.c_str(), size, buf);
			}
		}
		else {
			// fail
			if (errDataJson.isObject()) {
				errItem.Parsing(errDataJson);
			}
		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFSendMsg != NULL ) {
		m_Callback.onRequestEMFSendMsg(requestId, bFlag, errnum, errmsg, item, errItem);
	}
}

// ----------------------- UploadImage -----------------------
long LSLiveChatRequestEMFController::UploadImage(const string& messageid, const EMFFileNameList& fileList)
{
	string filelog("");
	HttpEntiy entiy;

	// messageid
	entiy.AddContent(EMF_REQUEST_MESSAGEID, messageid.c_str());
	// filename
	entiy.AddContent(EMF_REQUEST_FILENAME, "img");
	// files
	for (EMFFileNameList::const_iterator iter = fileList.begin();
			iter != fileList.end();
			iter++)
	{
		entiy.AddFile("img[]", (*iter));

		// log
		if (!filelog.empty()) {
			filelog += "\n";
		}
		filelog += (*iter);
	}

	string url = EMF_UPLOADIMAGE_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::UploadImage"
			"( url:%s, messageid:%s, file:%s)",
			url.c_str(), messageid.c_str(), filelog.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::UploadImageCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		bFlag = HandleResult(buf, size, errnum, errmsg, &dataJson);
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFUploadImage != NULL ) {
		m_Callback.onRequestEMFUploadImage(requestId, bFlag, errnum, errmsg);
	}
}

// ----------------------- UploadAttach -----------------------
long LSLiveChatRequestEMFController::UploadAttach(const string& filePath, int attachType)
{
	if (filePath.empty()
			&& 0 <= attachType && attachType < _countof(EMF_UPLOADATTACH_TYPE))
	{
		return -1;
	}

	HttpEntiy entiy;

	// attachType
	entiy.AddContent(EMF_REQUEST_ATTACHTYPE, EMF_UPLOADATTACH_TYPE[attachType]);
	// files
	entiy.AddFile("private_photo_file", filePath.c_str());

	string url = EMF_UPLOADATTACH_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::UploadAttach"
			"( url:%s, file:%s, type:%s)",
			url.c_str(), filePath.c_str(), EMF_UPLOADATTACH_TYPE[attachType]);

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::UploadAttachCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	string errnum = "";
	string errmsg = "";
	string attachId = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if ( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			if( dataJson.isObject() && dataJson[EMF_UPLOADATTACH_ID].isString() ) {
				attachId = dataJson[EMF_UPLOADATTACH_ID].asString();
			}

			if (attachId.empty()) {
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
				bFlag = false;
			} else {
				bFlag = true;
			}
		}

	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFUploadAttach != NULL ) {
		m_Callback.onRequestEMFUploadAttach(requestId, bFlag, errnum, errmsg, attachId);
	}
}

// ----------------------- DeleteMsg -----------------------
long LSLiveChatRequestEMFController::DeleteMsg(const string& messageid, int mailType)
{
	HttpEntiy entiy;
	// messageid
	entiy.AddContent(EMF_REQUEST_EMAILID, messageid.c_str());
	// mailType
	string strMailType("");
	if (mailType < _countof(EMF_MAILTYPE_TYPE)) {
		strMailType = EMF_MAILTYPE_TYPE[mailType];
		entiy.AddContent(EMF_REQUEST_MAILTYPE, strMailType.c_str());
	}

	string url = EMF_DELETEMSG_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::DeleteMsg"
			"( url:%s, messageid:%s, mailType:%s)",
			url.c_str(), messageid.c_str(), strMailType.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::DeleteMsgCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		bFlag = HandleResult(buf, size, errnum, errmsg, &dataJson);
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFDeleteMsg != NULL ) {
		m_Callback.onRequestEMFDeleteMsg(requestId, bFlag, errnum, errmsg);
	}
}

// ----------------------- AdmirerList -----------------------
long LSLiveChatRequestEMFController::AdmirerList(int pageIndex, int pageSize, int sortType, const string& womanid)
{
	char temp[16] = {0};
	HttpEntiy entiy;
	// pageIndex
	snprintf(temp, sizeof(temp), "%d", pageIndex);
	entiy.AddContent(COMMON_PAGE_INDEX, temp);
	// pageSize
	snprintf(temp, sizeof(temp), "%d", pageSize);
	entiy.AddContent(COMMON_PAGE_SIZE, temp);
	// sortType
	string strSortType("");
	if (sortType < _countof(EMF_MAILTYPE_TYPE)) {
		strSortType = EMF_MAILTYPE_TYPE[sortType];
		entiy.AddContent(EMF_REQUEST_SORTBY, strSortType.c_str());
	}
	// womanid
	if (!womanid.empty()) {
		entiy.AddContent(EMF_REQUEST_WOMANID, womanid.c_str());
	}

	string url = EMF_ADMIRERLIST_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::AdmirerList"
			"( url:%s, pageIndex:%d, pageSize:%d, sortType:%s, womanid:%s)",
			url.c_str(), pageIndex, pageSize, strSortType.c_str(), womanid.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::AdmirerListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	EMFAdmirerList list;
	int pageIndex = 0, pageSize = 0, dataCount = 0;
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			if (dataJson.isObject()) {
				// 解析pageIndex、pageCount、dataCount
				Json::Value pageIndexJson = dataJson[COMMON_PAGE_INDEX];
				if (pageIndexJson.isIntegral()) {
					pageIndex = pageIndexJson.asInt();
				}

				Json::Value pageSizeJson = dataJson[COMMON_PAGE_SIZE];
				if (pageSizeJson.isIntegral()) {
					pageSize = pageSizeJson.asInt();
				}

				Json::Value dataCountJson = dataJson[COMMON_DATA_COUNT];
				if (dataCountJson.isIntegral()) {
					dataCount = dataCountJson.asInt();
				}

				// 解析列表
				Json::Value dataListJson = dataJson[COMMON_DATA_LIST];
				bFlag = dataListJson.isArray();
				if(bFlag) {
					for(int i = 0; i < dataListJson.size(); i++) {
						LSLCEMFAdmirerListItem item;
						if (item.Parsing(dataListJson.get(i, Json::Value::null))) {
							list.push_back(item);
						}
					}
				}
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestEMFController::AdmirerListCallbackHandle() parsing fail:"
						"(url:%s, size:%d, buf:%s)",
						url.c_str(), size, buf);
			}
		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFAdmirerList != NULL ) {
		m_Callback.onRequestEMFAdmirerList(requestId, bFlag, errnum, errmsg, pageIndex, pageSize, dataCount, list);
	}
}

// ----------------------- AdmirerViewer -----------------------
long LSLiveChatRequestEMFController::AdmirerViewer(const string& messageid)
{
//	char temp[16] = {0};
	HttpEntiy entiy;
	// messageid
	entiy.AddContent(EMF_REQUEST_MESSAGEID, messageid.c_str());

	string url = EMF_ADMIRERVIEWER_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::AdmirerViewer"
			"( url:%s, messageid:%s )",
			url.c_str(), messageid.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::AdmirerViewerCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	LSLCEMFAdmirerViewerItem item;
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			// success
			if(dataJson.isObject()) {
				bFlag = item.Parsing(dataJson);
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestEMFController::AdmirerViewerCallbackHandle() parsing fail:"
						"(url:%s, size:%d, buf:%s)",
						url.c_str(), size, buf);
			}
		}

	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFAdmirerViewer != NULL ) {
		m_Callback.onRequestEMFAdmirerViewer(requestId, bFlag, errnum, errmsg, item);
	}
}

// ----------------------- BlockList -----------------------
long LSLiveChatRequestEMFController::BlockList(int pageIndex, int pageSize, const string& womanid)
{
	char temp[16] = {0};
	HttpEntiy entiy;
	// pageIndex
	snprintf(temp, sizeof(temp), "%d", pageIndex);
	entiy.AddContent(COMMON_PAGE_INDEX, temp);
	// pageSize
	snprintf(temp, sizeof(temp), "%d", pageSize);
	entiy.AddContent(COMMON_PAGE_SIZE, temp);
	// womanid
	if (!womanid.empty()) {
		entiy.AddContent(EMF_REQUEST_WOMANID, womanid.c_str());
	}

	string url = EMF_BLOCKLIST_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::BlockList"
			"( url:%s, pageIndex:%d, pageSize:%d, womanid:%s)",
			url.c_str(), pageIndex, pageSize, womanid.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::BlockListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	EMFBlockList list;
	int pageIndex = 0, pageSize = 0, dataCount = 0;
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			if (dataJson.isObject()) {
				// 解析pageIndex、pageCount、dataCount
				Json::Value pageIndexJson = dataJson[COMMON_PAGE_INDEX];
				if (pageIndexJson.isIntegral()) {
					pageIndex = pageIndexJson.asInt();
				}

				Json::Value pageSizeJson = dataJson[COMMON_PAGE_SIZE];
				if (pageSizeJson.isIntegral()) {
					pageSize = pageSizeJson.asInt();
				}

				Json::Value dataCountJson = dataJson[COMMON_DATA_COUNT];
				if (dataCountJson.isIntegral()) {
					dataCount = dataCountJson.asInt();
				}

				// 解析列表
				Json::Value dataListJson = dataJson[COMMON_DATA_LIST];
				bFlag = dataListJson.isArray();
				if(bFlag) {
					for(int i = 0; i < dataListJson.size(); i++) {
						LSLCEMFBlockListItem item;
						if (item.Parsing(dataListJson.get(i, Json::Value::null))) {
							list.push_back(item);
						}
					}
				}
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestEMFController::BlockListCallbackHandle() parsing fail:"
						"(url:%s, size:%d, buf:%s)",
						url.c_str(), size, buf);
			}
		}

	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFBlockList != NULL ) {
		m_Callback.onRequestEMFBlockList(requestId, bFlag, errnum, errmsg, pageIndex, pageSize, dataCount, list);
	}
}

// ----------------------- Block -----------------------
long LSLiveChatRequestEMFController::Block(const string& womanid, int blockreason)
{
	HttpEntiy entiy;
	// womanid
	entiy.AddContent(EMF_REQUEST_WOMANID, womanid.c_str());
	// blockreason
	string strBlockReason("");
	if (blockreason < _countof(EMF_BLOCKREASON_TYPE)) {
		strBlockReason = EMF_BLOCKREASON_TYPE[blockreason];
		entiy.AddContent(EMF_REQUEST_BLOCKREASON, strBlockReason.c_str());
	}

	string url = EMF_BLOCK_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::Block"
			"( url:%s, womanid:%s, blockreason:%s )",
			url.c_str(), womanid.c_str(), strBlockReason.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::BlockCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		bFlag = HandleResult(buf, size, errnum, errmsg, &dataJson);

//		if (!bFlag) {
//			// parsing fail
//			errnum = LOCAL_ERROR_CODE_PARSEFAIL;
//			errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
//
//			FileLog("httprequest", "LSLiveChatRequestEMFController::BlockCallbackHandle() parsing fail:"
//					"(url:%s, size:%d, buf:%s)",
//					url.c_str(), size, buf);
//		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFBlock != NULL ) {
		m_Callback.onRequestEMFBlock(requestId, bFlag, errnum, errmsg);
	}
}

// ----------------------- Unblock -----------------------
long LSLiveChatRequestEMFController::Unblock(const EMFWomanidList& womanidList)
{
	HttpEntiy entiy;
	// womanid
	string strWomanId("");
	for (EMFWomanidList::const_iterator iter = womanidList.begin();
		iter != womanidList.end();
		iter++)
	{
		if (!strWomanId.empty()) {
			strWomanId += EMF_WOMANID_DELIMITER;
		}
		strWomanId += (*iter);
	}
	entiy.AddContent(EMF_REQUEST_WOMANID, strWomanId.c_str());

	string url = EMF_UNBLOCK_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::Unblock"
			"( url:%s, womanid:%s )",
			url.c_str(), strWomanId.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::UnblockCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		bFlag = HandleResult(buf, size, errnum, errmsg, &dataJson);

//		if (!bFlag) {
//			// parsing fail
//			errnum = LOCAL_ERROR_CODE_PARSEFAIL;
//			errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
//
//			FileLog("httprequest", "LSLiveChatRequestEMFController::UnblockCallbackHandle() parsing fail:"
//					"(url:%s, size:%d, buf:%s)",
//					url.c_str(), size, buf);
//		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFUnblock != NULL ) {
		m_Callback.onRequestEMFUnblock(requestId, bFlag, errnum, errmsg);
	}
}

//----------------------- InboxPhotoFee -----------------------
long LSLiveChatRequestEMFController::InboxPhotoFee(const string& womanid, const string& photoid, const string& sendid, const string& messageid)
{
	HttpEntiy entiy;
	// womanid
	entiy.AddContent(EMF_REQUEST_WOMANID, womanid.c_str());
	// photoid
	entiy.AddContent(EMF_REQUEST_PHOTOID, photoid.c_str());
	// sendid
	entiy.AddContent(EMF_INBOXPHOTOFEE_SENDID, sendid.c_str());
	// messageid
	entiy.AddContent(EMF_REQUEST_MESSAGEID, messageid.c_str());

	string url = EMF_INBOXPHOTOFEE_PATH;
	FileLog("httprequest", "LSLiveChatRequestEMFController::InboxPhotoFee"
			"( url:%s, womanid:%s, photoid:%s, sendid:%s, messageid:%s )",
			url.c_str(), womanid.c_str(), photoid.c_str(), sendid.c_str(), messageid.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::InboxPhotoFeeCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		bFlag = HandleResult(buf, size, errnum, errmsg, &dataJson);
//
//		if (!bFlag) {
//			// parsing fail
//			errnum = LOCAL_ERROR_CODE_PARSEFAIL;
//			errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
//
//			FileLog("httprequest", "LSLiveChatRequestEMFController::InboxPhotoFeeCallbackHandle() parsing fail:"
//					"(url:%s, size:%d, buf:%s)",
//					url.c_str(), size, buf);
//		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestEMFInboxPhotoFee != NULL ) {
		m_Callback.onRequestEMFInboxPhotoFee(requestId, bFlag, errnum, errmsg);
	}
}
// ----------------------- PrivatePhotoView -----------------------
long LSLiveChatRequestEMFController::PrivatePhotoView(const string& womanid, const string& photoid, const string& sendid, const string& messageid, const string& filePath, int type, int mode)
{
	HttpEntiy entiy;

	// delete file
	string tempPath = GetTempFilePath(filePath);
	remove(tempPath.c_str());

	// womanid
	entiy.AddContent(EMF_REQUEST_WOMANID, womanid.c_str());
	// photoid
	entiy.AddContent(EMF_REQUEST_PHOTOID, photoid.c_str());
	// sendid
	entiy.AddContent(EMF_PRIVATEPHOTOVIEW_SENDID, sendid.c_str());
	// messageid
	entiy.AddContent(EMF_REQUEST_MESSAGEID, messageid.c_str());

	// size
	string size;
	if( type > -1 && type < _countof(PRIVITE_PHOTO_SIZE_ARRAY) ) {
		size = PRIVITE_PHOTO_SIZE_ARRAY[type];
		entiy.AddContent(EMF_INBOXPHOTOFEE_SIZE, size.c_str());
	}

	// model
	if(mode >=0 && mode<=1){
        char temp[4];
        sprintf(temp, "%d", mode);
		entiy.AddContent(EMF_INBOXPHOTOFEE_MODE, temp);
	}else{
		entiy.AddContent(EMF_INBOXPHOTOFEE_MODE, "1");
	}

	string url = EMF_PRIVATEPHOTOVIEW_PATH;

	// only one file can be download, waiting until the last request is stopped
    mRequestFileDownloadMap.Lock();
    long oldRequestId = 0;
    RequestFileDownloadMap::iterator itr = mRequestFileDownloadMap.Find(filePath);
    if (itr != mRequestFileDownloadMap.End()) {
        oldRequestId = itr->second;
    }
    mRequestFileDownloadMap.Erase(filePath);
    mRequestFileDownloadMap.Unlock();
	if( oldRequestId != 0 ) {
		StopRequest(oldRequestId, true);
	}

	long requestId = StartRequest(url, entiy, this, AppSite, false);
	if (requestId != -1) {
		string* param = new string(filePath);
		mCustomParamMap.insert(RequestCustomParamMap::value_type(requestId, (void*)param));
        mRequestFileDownloadMap.Lock();
		mRequestFileDownloadMap.Insert(filePath, requestId);
        mRequestFileDownloadMap.Unlock();
	}

	FileLog("httprequest", "LSLiveChatRequestEMFController::PrivatePhotoView"
				"( requestId:%ld, url:%s, womanid:%s, photoid:%s, sendid:%s, messageid:%s, size : %s, model : 1 )",
				requestId, url.c_str(), womanid.c_str(), photoid.c_str(), sendid.c_str(), messageid.c_str(), size.c_str());

	return requestId;
}

void LSLiveChatRequestEMFController::PrivatePhotoViewCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	FileLog("httprequest", "LSLiveChatRequestEMFController::PrivatePhotoViewCallbackHandle"
				"( requestId:%ld, url:%s, requestRet:%d ) begin",
				requestId, url.c_str(), requestRet);

	// 找回文件路径
	string filePath("");
	RequestCustomParamMap::iterator iter = mCustomParamMap.find(requestId);
	if (mCustomParamMap.end() != iter) {
		string* param = (string*)((*iter).second);
		if (NULL != param) {
			filePath = *param;
			delete param;
		}
		mCustomParamMap.erase(iter);
	}
	string tempPath = GetTempFilePath(filePath);
	// download finish
    mRequestFileDownloadMap.Lock();
	mRequestFileDownloadMap.Erase(filePath);
    mRequestFileDownloadMap.Unlock();

	string errnum = "";
	string errmsg = "";
	bool bFlag = false;
	if (requestRet) {
		// request success
		string contentType = GetContentTypeById(requestId);
		if (string::npos != contentType.find("image")) {
			FILE* file = fopen(tempPath.c_str(), "rb");
			if (NULL != file) {
				fseek(file, 0, SEEK_END);
				size_t fileSize = ftell(file);
				fclose(file);
				file = NULL;

				int recv = 0;
				int total = 0;
				GetRecvLength(requestId, total, recv);
				if (total <= 0
					|| fileSize == (size_t)total)
				{
					bFlag = true;
					rename(tempPath.c_str(), filePath.c_str());

					FileLog("httprequest", "LSLiveChatRequestEMFController::PrivatePhotoViewCallbackHandle"
								"( requestId:%ld, url:%s, filePath:%s, tempPath:%s, totalSize:%d, fileSize:%d, contentType:%s ) rename ok",
								requestId, url.c_str(), filePath.c_str(), tempPath.c_str(), total, fileSize, contentType.c_str());
				}
				else {
					FileLog("httprequest", "LSLiveChatRequestEMFController::PrivatePhotoViewCallbackHandle"
								"( requestId:%ld, url:%s, filePath:%s, tempPath:%s, totalSize:%d, fileSize:%d ) file size error",
								requestId, url.c_str(), filePath.c_str(), tempPath.c_str(), total, fileSize);
				}
			}
			else {
				FileLog("httprequest", "LSLiveChatRequestEMFController::PrivatePhotoViewCallbackHandle"
							"( requestId:%ld, url:%s, filePath:%s, tempPath:%s ) open file fail",
							requestId, url.c_str(), filePath.c_str(), tempPath.c_str());
			}
		}
		else {
			FileLog("httprequest", "LSLiveChatRequestEMFController::PrivatePhotoViewCallbackHandle"
						"( requestId:%ld, url:%s, filePath:%s, tempPath:%s, contentType:%s ) content type fail",
						requestId, url.c_str(), filePath.c_str(), tempPath.c_str(), contentType.c_str());
		}

		if (!bFlag) {
			errnum = LOCAL_ERROR_CODE_FILEOPTFAIL;
			errmsg = LOCAL_ERROR_CODE_FILEOPTFAIL_DESC;
			// 删除文件
			remove(tempPath.c_str());
		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
		// 删除文件
		remove(tempPath.c_str());
	}


	if( m_Callback.onRequestEMFPrivatePhotoView != NULL ) {
		m_Callback.onRequestEMFPrivatePhotoView(requestId, bFlag, errnum, errmsg, filePath);
	}
}

void LSLiveChatRequestEMFController::PrivatePhotoViewRecvCallbackHandle(long requestId, const string& url, const char* buf, int size)
{
	// 找回文件路径
	string filePath("");
	RequestCustomParamMap::iterator iter = mCustomParamMap.find(requestId);
	if (mCustomParamMap.end() != iter) {
		string* param = (string*)((*iter).second);
		if (NULL != param) {
			filePath = *param;
		}
	}

	if (!filePath.empty()) {
		string tempPath = GetTempFilePath(filePath);
		FILE* pFile = fopen(tempPath.c_str(), "a+b");
		if (NULL != pFile) {
			fwrite(buf, 1, size, pFile);
			fclose(pFile);

			FileLog("httprequest", "LSLiveChatRequestEMFController::PrivatePhotoViewRecvCallbackHandle"
						"( write file requestId:%ld, url:%s, filePath:%s, tempPath:%s, size:%d )",
						requestId, url.c_str(), filePath.c_str(), tempPath.c_str(), size);
		}
		else {
			FileLog("httprequest", "LSLiveChatRequestEMFController::PrivatePhotoViewRecvCallbackHandle"
						"( open file fail, requestId:%ld, url:%s, filePath:%s, tempPath:%s )",
						requestId, url.c_str(), filePath.c_str(), tempPath.c_str());
		}
	}
	else {
		FileLog("httprequest", "LSLiveChatRequestEMFController::PrivatePhotoViewRecvCallbackHandle"
					"( param error, requestId:%ld, url:%s, filePath is empty)",
					requestId, url.c_str() );
	}
}

// ----------------------- short video -----------------------
long LSLiveChatRequestEMFController::GetVideoThumbPhoto(
	string womanid,
	string send_id,
	string video_id,
	string messageid,
	int type,
	const string& filePath
	) {
	HttpEntiy entiy;
	char temp[32] = {0};

	// delete file
	string tempPath = GetTempFilePath(filePath);
	remove(tempPath.c_str());

	string url = EMF_SHORTVIDEOTHUMBPHOTO_PATH;

	// womanid
	if( womanid.length() > 0 ) {
		entiy.AddContent(EMF_SHORTVIDEOTHUMBPHOTO_WOMANID, womanid.c_str());
	}

	// send_id
	if( send_id.length() > 0 ) {
		entiy.AddContent(EMF_SHORTVIDEOTHUMBPHOTO_SENDID, send_id.c_str());
	}

	// video_id
	if( video_id.length() > 0 ) {
		entiy.AddContent(EMF_SHORTVIDEOTHUMBPHOTO_VIDEOID, video_id.c_str());
	}

	// messageid
	if( messageid.length() > 0 ) {
		entiy.AddContent(EMF_SHORTVIDEOTHUMBPHOTO_MESSAGEID, messageid.c_str());
	}

	// type
	if( type > -1 && type < 2 ) {
		snprintf(temp, sizeof(temp), "%d", type);
		entiy.AddContent(EMF_SHORTVIDEOTHUMBPHOTO_PHOTOSIZE, temp);
	}

	FileLog("httprequest", "LSLiveChatRequestEMFController::GetVideoThumbPhoto( "
			"url : %s, "
			"womanid: %s, "
			"send_id : %s, "
			"video_id : %s, "
			"messageid : %s, "
			"type : %d, "
			"filePath : %s "
			")",
			url.c_str(),
			womanid.c_str(),
			send_id.c_str(),
			video_id.c_str(),
			messageid.c_str(),
			type,
			filePath.c_str()
			);

	// 删除文件
	remove(filePath.c_str());

	long requestId = -1;
	requestId = StartRequest(url, entiy, this, AppSite, true);
	if (requestId != -1) {
		string* param = new string(filePath);
		if (NULL != param) {
			mCustomParamMap.insert(RequestCustomParamMap::value_type(requestId, (void*)param));
		}
	}
	return requestId;
}

void LSLiveChatRequestEMFController::GetVideoThumbPhotoCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size) {
	// 找回文件路径
	string filePath("");
	RequestCustomParamMap::iterator iter = mCustomParamMap.find(requestId);
	if (mCustomParamMap.end() != iter) {
		string* param = (string*)((*iter).second);
		if (NULL != param) {
			filePath = *param;
			delete param;
		}
		mCustomParamMap.erase(iter);
	}
	string tempPath = GetTempFilePath(filePath);

	string errnum = "";
	string errmsg = "";
	bool bFlag = false;
	string contentType = GetContentTypeById(requestId);
	if (string::npos != contentType.find("image")) {
		FILE* file = fopen(tempPath.c_str(), "rb");
		if (NULL != file) {
			fseek(file, 0, SEEK_END);
			size_t fileSize = ftell(file);
			fclose(file);
			file = NULL;

			int recv = 0;
			int total = 0;
			GetRecvLength(requestId, total, recv);
			if (total <= 0
				|| fileSize == (size_t)total)
			{
				bFlag = true;
				rename(tempPath.c_str(), filePath.c_str());
			}
			else {
				FileLog("httprequest", "LSLiveChatRequestEMFController::onSuccess"
							"( requestId:%ld, url:%s, tempPath:%s, totalSize:%d, fileSize:%d ) file size error",
							requestId, url.c_str(), tempPath.c_str(), total, fileSize);
			}
		}
		else {
			FileLog("httprequest", "LSLiveChatRequestEMFController::onSuccess"
						"( requestId:%ld, url:%s, tempPath:%s ) open file fail",
						requestId, url.c_str(), tempPath.c_str());
		}
	}
	else {
		FileLog("httprequest", "LSLiveChatRequestEMFController::onSuccess"
					"( requestId:%ld, url:%s, tempPath:%s ) file size error",
					requestId, url.c_str(), tempPath.c_str());
	}

	if (!bFlag) {
		errnum = LOCAL_ERROR_CODE_FILEOPTFAIL;
		errmsg = LOCAL_ERROR_CODE_FILEOPTFAIL_DESC;
		remove(filePath.c_str());
	}

	if( m_Callback.onRequestGetVideoThumbPhoto!= NULL ) {
		m_Callback.onRequestGetVideoThumbPhoto(requestId, bFlag, errnum, errmsg, filePath);
	}
}

void LSLiveChatRequestEMFController::GetVideoThumbPhotoRecvCallbackHandle(long requestId, const string& url, const char* buf, int size)
{
	string filePath("");
	RequestCustomParamMap::iterator iter = mCustomParamMap.find(requestId);
	if (mCustomParamMap.end() != iter) {
		string* param = (string*)((*iter).second);
		if (NULL != param) {
			filePath = *param;
		}
	}

	string errnum = "";
	string errmsg = "";
	bool bFlag = false;
	if (!filePath.empty()) {
		string tempPath = GetTempFilePath(filePath);
		FILE* pFile = fopen(tempPath.c_str(), "a+b");
		if (NULL != pFile) {
			fwrite(buf, 1, size, pFile);
			fclose(pFile);

			FileLog("httprequest", "LSLiveChatRequestEMFController::onReceiveBody"
						"( write file success:%d, requestId:%ld, url:%s, filePath:%s, tempPath:%s )",
						bFlag, requestId, url.c_str(), filePath.c_str(), tempPath.c_str());
		}
		else {
			FileLog("httprequest", "LSLiveChatRequestEMFController::onReceiveBody"
						"( open file fail, requestId:%ld, url:%s, filePath:%s, tempPath:%s )",
						requestId, url.c_str(), filePath.c_str(), tempPath.c_str());
		}
	}
	else {
		FileLog("httprequest", "LSLiveChatRequestEMFController::onReceiveBody"
					"( param error, requestId:%ld, url:%s, filePath is empty)",
					requestId, url.c_str() );
	}
}

long LSLiveChatRequestEMFController::GetVideoUrl(
		string womanId,
		string send_id,
		string video_id,
		string messageid
		) {
	HttpEntiy entiy;
//	char temp[32] = {0};

	string url = EMF_SHORTVIDEOURL_PATH;

	if( womanId.length() > 0 ) {
		// womanId
		entiy.AddContent(EMF_SHORTVIDEOTHUMBPHOTO_WOMANID, womanId.c_str());
	}

	if( send_id.length() > 0 ) {
		// send_id
		entiy.AddContent(EMF_SHORTVIDEOTHUMBPHOTO_SENDID, send_id.c_str());
	}

	// video_id
	if( video_id.length() > 0 ) {
		entiy.AddContent(EMF_SHORTVIDEOTHUMBPHOTO_VIDEOID, video_id.c_str());
	}

	// messageid
	if( messageid.length() > 0 ) {
		entiy.AddContent(EMF_SHORTVIDEOTHUMBPHOTO_MESSAGEID, messageid.c_str());
	}

	FileLog("httprequest", "LSLiveChatRequestEMFController::GetVideoUrl( "
			"url : %s, "
			"womanId : %s, "
			"send_id : %s, "
			"video_id : %s, "
			"messageid : %s, "
			")",
			url.c_str(),
			womanId.c_str(),
			send_id.c_str(),
			video_id.c_str(),
			messageid.c_str()
			);

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestEMFController::GetVideoUrlCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size) {

	string errnum = "";
	string errmsg = "";
	string videoUrl = "";
	bool bFlag = false;
	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			// success
			if(dataJson.isObject()) {
				if (dataJson["url"].isString()) {
					videoUrl = dataJson["url"].asString();
				}
				if(!videoUrl.empty()){
					bFlag = true;
				}
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
				FileLog("httprequest", "LSLiveChatRequestEMFController::GetVideoUrlCallbackHandle() parsing fail:"
							"(url:%s, size:%d, buf:%s)",
							url.c_str(), size, buf);
			}
		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestOnGetVideoUrl != NULL ) {
		m_Callback.onRequestOnGetVideoUrl(requestId, bFlag, errnum, errmsg, videoUrl);
	}
}



string LSLiveChatRequestEMFController::GetTempFilePath(const string& filePath)
{
	static const char* tempFileName = ".tmp";
	return filePath + tempFileName;
}
