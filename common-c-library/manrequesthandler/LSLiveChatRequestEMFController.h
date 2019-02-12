/*
 * LSLiveChatRequestEMFController.h
 *
 *  Created on: 2015-3-6
 *      Author: Samson.Fan
 */

#ifndef LSLIVECHATREQUESTEMFCONTROLLER_H_
#define LSLIVECHATREQUESTEMFCONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"
#include "item/LSLCEMF.h"
#include "item/LSLCEMFError.h"

typedef void (*OnRequestEMFInboxList)(long requestId, bool success, const string& errnum, const string& errmsg, int pageIndex, int pageSize, int dataCount, const EMFInboxList& inboxList);
typedef void (*OnRequestEMFInboxMsg)(long requestId, bool success, const string& errnum, const string& errmsg, int memberType, const LSLCEMFInboxMsgItem& item);
typedef void (*OnRequestEMFOutboxList)(long requestId, bool success, const string& errnum, const string& errmsg, int pageIndex, int pageSize, int dataCount, const EMFOutboxList& outboxList);
typedef void (*OnRequestEMFOutboxMsg)(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCEMFOutboxMsgItem& item);
typedef void (*OnRequestEMFMsgTotal)(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCEMFMsgTotalItem& item);
typedef void (*OnRequestEMFSendMsg)(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCEMFSendMsgItem& item, const LSLCEMFSendMsgErrorItem& errItem);
typedef void (*OnRequestEMFUploadImage)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef void (*OnRequestEMFUploadAttach)(long requestId, bool success, const string& errnum, const string& errmsg, const string& attachId);
typedef void (*OnRequestEMFDeleteMsg)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef void (*OnRequestEMFAdmirerList)(long requestId, bool success, const string& errnum, const string& errmsg, int pageIndex, int pageSize, int dataCount, const EMFAdmirerList& admirerList);
typedef void (*OnRequestEMFAdmirerViewer)(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCEMFAdmirerViewerItem& item);
typedef void (*OnRequestEMFBlockList)(long requestId, bool success, const string& errnum, const string& errmsg, int pageIndex, int pageSize, int dataCount, const EMFBlockList& blockList);
typedef void (*OnRequestEMFBlock)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef void (*OnRequestEMFUnblock)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef void (*OnRequestEMFInboxPhotoFee)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef void (*OnRequestEMFPrivatePhotoView)(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath);
typedef void (*OnRequestGetVideoThumbPhoto)(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath);
typedef void (*OnRequestGetVideoUrl)(long requestId, bool success, const string& errnum, const string& errmsg, const string& url);
typedef struct _tagLSLiveChatRequestEMFControllerCallback {
	OnRequestEMFInboxList onRequestEMFInboxList;
	OnRequestEMFInboxMsg onRequestEMFInboxMsg;
	OnRequestEMFOutboxList onRequestEMFOutboxList;
	OnRequestEMFOutboxMsg onRequestEMFOutboxMsg;
	OnRequestEMFMsgTotal onRequestEMFMsgTotal;
	OnRequestEMFSendMsg onRequestEMFSendMsg;
	OnRequestEMFUploadImage onRequestEMFUploadImage;
	OnRequestEMFUploadAttach onRequestEMFUploadAttach;
	OnRequestEMFDeleteMsg onRequestEMFDeleteMsg;
	OnRequestEMFAdmirerList onRequestEMFAdmirerList;
	OnRequestEMFAdmirerViewer onRequestEMFAdmirerViewer;
	OnRequestEMFBlockList onRequestEMFBlockList;
	OnRequestEMFBlock onRequestEMFBlock;
	OnRequestEMFUnblock onRequestEMFUnblock;
	OnRequestEMFInboxPhotoFee onRequestEMFInboxPhotoFee;
	OnRequestEMFPrivatePhotoView onRequestEMFPrivatePhotoView;
	OnRequestGetVideoThumbPhoto onRequestGetVideoThumbPhoto;
	OnRequestGetVideoUrl onRequestOnGetVideoUrl;
} LSLiveChatRequestEMFControllerCallback;


class LSLiveChatRequestEMFController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestEMFController(LSLiveChatHttpRequestManager* pHttpRequestManager, const LSLiveChatRequestEMFControllerCallback& callback);
	virtual ~LSLiveChatRequestEMFController();

public:
	long InboxList(int pageIndex, int pageSize, int sortType, const string& womanid);
	long InboxMsg(const string& messageid);
	long OutboxList(int pageIndex, int pageSize, int progressType, const string& womanid);
	long OutboxMsg(const string& messageid);
	long MsgTotal(int sortType);
	long SendMsg(const string& womanid, const string& body, bool useIntegral, int replyType, string mtab, const SendMsgGifts& gifts, const SendMsgAttachs& attachs, bool isLovecall, const string& messageId);
	long UploadImage(const string& messageid, const EMFFileNameList& fileList);
	long UploadAttach(const string& filePath, int attachType);
	long DeleteMsg(const string& messageid, int mailType);
	long AdmirerList(int pageIndex, int pageSize, int sortType, const string& womanid);
	long AdmirerViewer(const string& messageid);
	long BlockList(int pageIndex, int pageSize, const string& womanid);
	long Block(const string& womanid, int blockreason);
	long Unblock(const EMFWomanidList& womanidList);
	long InboxPhotoFee(const string& womanid, const string& photoId, const string& sendid, const string& messageid);
	long PrivatePhotoView(const string& womanid, const string& photoid, const string& sendid, const string& messageid, const string& filePath, int type, int mode);
	/**
	 * 7.17.获取微视频thumb图片（http post）（New）
	 * @param womanid		女士ID
	 * @param send_id		发送Id
	 * @param videoid		视频ID
	 * @param messageid		所属邮件Id
	 * @param type			图片尺寸
	 * @return				请求唯一Id
	 */
	long GetVideoThumbPhoto(
			string womanid,
			string send_id,
			string video_id,
			string messageid,
			int type,
			const string& filePath
			);

	/**
	 * 7.18.获取微视频文件URL（http post）（New）
	 * @param womanId		女士ID
	 * @param send_id		发送Id
	 * @param videoid		视频ID
	 * @param messageid		所属邮件Id
	 * @return				请求唯一Id
	 */
	long GetVideoUrl(
			string womanId,
			string send_id,
			string video_id,
			string messageid
			);
private:
	void InboxListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void InboxMsgCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void OutboxListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void OutboxMsgCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void MsgTotalCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void SendMsgCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void UploadImageCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void UploadAttachCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void DeleteMsgCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void AdmirerListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void AdmirerViewerCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void BlockListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void BlockCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void UnblockCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void InboxPhotoFeeCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void PrivatePhotoViewCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void PrivatePhotoViewRecvCallbackHandle(long requestId, const string& url, const char* buf, int size);
	void GetVideoThumbPhotoCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void GetVideoThumbPhotoRecvCallbackHandle(long requestId, const string& url, const char* buf, int size);
	void GetVideoUrlCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);

protected:
	virtual void onSuccess(long requestId, string path, const char* buf, int size);
	virtual void onFail(long requestId, string path);
	virtual void onReceiveBody(long requestId, string url, const char* buf, int size);

private:
	string GetTempFilePath(const string& filePath);

private:
	LSLiveChatRequestEMFControllerCallback m_Callback;
};

#endif /* LSLIVECHATREQUESTEMFCONTROLLER_H_ */
