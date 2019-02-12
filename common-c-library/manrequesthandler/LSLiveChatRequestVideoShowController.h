/*
 * LSLiveChatRequestVideoShowController.h
 *
 *  Created on: 2015-3-6
 *      Author: Samson.Fan
 */

#ifndef LSLIVECHATREQUESTVIDEOSHOWCONTROLLER_H_
#define LSLIVECHATREQUESTVIDEOSHOWCONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"
#include "item/LSLCVideoShow.h"

typedef void (*OnRequestVSVideoList)(long requestId, bool success, const string& errnum, const string& errmsg, int pageIndex, int pageSize, int dataCount, const VSVideoList& vsList);
typedef void (*OnRequestVSVideoDetail)(long requestId, bool success, const string& errnum, const string& errmsg, const VSVideoDetailList& list);
typedef void (*OnRequestVSPlayVideo)(long requestId, bool success, const string& errnum, const string& errmsg, int memberType, const LSLCVSPlayVideoItem& item);
typedef void (*OnRequestVSWatchedVideoList)(long requestId, bool success, const string& errnum, const string& errmsg, int pageIndex, int pageSize, int dataCount, const VSWatchedVideoList& vsList);
typedef void (*OnRequestVSSaveVideo)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef void (*OnRequestVSRemoveVideo)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef void (*OnRequestVSSavedVideoList)(long requestId, bool success, const string& errnum, const string& errmsg, int pageIndex, int pageSize, int dataCount, const VSSavedVideoList& vsList);
typedef struct _tagLSLiveChatRequestVideoShowControllerCallback {
	OnRequestVSVideoList onRequestVSVideoList;
	OnRequestVSVideoDetail onRequestVSVideoDetail;
	OnRequestVSPlayVideo onRequestVSPlayVideo;
	OnRequestVSWatchedVideoList onRequestVSWatchedVideoList;
	OnRequestVSSaveVideo onRequestVSSaveVideo;
	OnRequestVSRemoveVideo onRequestVSRemoveVideo;
	OnRequestVSSavedVideoList onRequestVSSavedVideoList;
} LSLiveChatRequestVideoShowControllerCallback;


class LSLiveChatRequestVideoShowController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestVideoShowController(LSLiveChatHttpRequestManager* pHttpRequestManager, const LSLiveChatRequestVideoShowControllerCallback& callback);
	virtual ~LSLiveChatRequestVideoShowController();

public:
	long VideoList(int pageIndex, int pageSize, int age1, int age2, int orderBy);
	long VideoDetail(const string& womanid);
	long PlayVideo(const string& womanid, const string& videoid);
	long WatchedVideoList(int pageIndex, int pageSize);
	long SaveVideo(const string& videoid);
	long RemoveVideo(const string& videoid);
	long SavedVideoList(int pageIndex, int pageSize);

private:
	void VideoListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void VideoDetailCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void PlayVideoCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void WatchedVideoListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void SaveVideoCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void RemoveVideoCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void SavedVideoListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);

protected:
	void onSuccess(long requestId, string path, const char* buf, int size);
	void onFail(long requestId, string path);

private:
	LSLiveChatRequestVideoShowControllerCallback m_Callback;
};

#endif /* LSLIVECHATREQUESTVIDEOSHOWCONTROLLER_H_ */
