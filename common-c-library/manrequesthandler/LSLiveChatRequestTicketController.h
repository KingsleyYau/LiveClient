/*
 * LSLiveChatRequestTicketController.h
 *
 *  Created on: 2015-07-13
 *      Author: Samson.Fan
 */

#ifndef LSLIVECHATREQUESTTICKETCONTROLLER_H_
#define LSLIVECHATREQUESTTICKETCONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"
#include "item/LSLCTicket.h"

typedef void (*OnRequestTicketList)(long requestId, bool success, const string& errnum, const string& errmsg, int pageIndex, int pageSize, int dataCount, const TicketList& ticketList);
typedef void (*OnRequestTicketDetail)(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCTicketDetailItem& item);
typedef void (*OnRequestReplyTicket)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef void (*OnRequestResolvedTicket)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef void (*OnRequestAddTicket)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef struct _tagLSLiveChatRequestTicketControllerCallback {
	OnRequestTicketList onRequestTicketList;
	OnRequestTicketDetail onRequestTicketDetail;
	OnRequestReplyTicket onRequestReplyTicket;
	OnRequestResolvedTicket onRequestResolvedTicket;
	OnRequestAddTicket onRequestAddTicket;
} LSLiveChatRequestTicketControllerCallback;

class LSLiveChatRequestTicketController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestTicketController(LSLiveChatHttpRequestManager* pHttpRequestManager, const LSLiveChatRequestTicketControllerCallback& callback);
	virtual ~LSLiveChatRequestTicketController();

public:
	long QueryTicketList(int pageIndex, int pageSize);
	long TicketDetail(const string& ticketId);
	long ReplyTicket(const string& ticketId, const string& message, const string& filePath);
	long ResolvedTicket(const string& ticketId);
	long AddTicket(int typeId, const string& title, const string& message, const string& filePath);

private:
	void QueryTicketListCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void TicketDetailCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void ReplyTicketCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void ResolvedTicketCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void AddTicketCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);

protected:
	void onSuccess(long requestId, string path, const char* buf, int size);
	void onFail(long requestId, string path);

private:
	LSLiveChatRequestTicketControllerCallback m_Callback;
};

#endif /*LSLIVECHATREQUESTTICKETCONTROLLER_H_ */
