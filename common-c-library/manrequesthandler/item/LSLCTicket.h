/*
 * LSLCTicket.h
 *
 *  Created on: 2015-07-13
 *      Author: Samson.Fan
 */

#ifndef LSLCTICKET_H_
#define LSLCTICKET_H_

#include <string>
#include <list>
using namespace std;

#include "../LSLiveChatRequestTicketDefine.h"
#include "../LSLiveChatRequestDefine.h"
#include <json/json/json.h>
#include <common/CommonFunc.h>

// 查询ticket列表 TICKET_LIST_PATH(/member/ticket_list) item
class LSLCTicketListItem {
public:
	LSLCTicketListItem()
	{
		ticketId = "";
		title = "";
		unreadNum = 0;
		status = TICKET_STATUS_DEFAULT;
		addDate = 0;
	}
	virtual ~LSLCTicketListItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[TICKET_TICKETLIST_ID].isString()) {
				ticketId = data[TICKET_TICKETLIST_ID].asString();
			}
			if (data[TICKET_TICKETLIST_TITLE].isString()) {
				title = data[TICKET_TICKETLIST_TITLE].asString();
			}
			if (data[TICKET_TICKETLIST_UNREADNUM].isIntegral()) {
				unreadNum = data[TICKET_TICKETLIST_UNREADNUM].asInt();
			}
			if (data[TICKET_TICKETLIST_STATUS].isIntegral()) {
				int statusValue = data[TICKET_TICKETLIST_STATUS].asInt();
				status = GetTicketStatusValue(statusValue);
			}
			if (data[TICKET_TICKETLIST_ADDDATE].isIntegral()) {
				addDate = data[TICKET_TICKETLIST_ADDDATE].asInt();
			}

			if (!ticketId.empty()) {
				result = true;
			}
		}
		return result;
	}
public:
	string			ticketId;	// ticketID
	string			title;		// 标题
	int				unreadNum;	// 未读数
	TicketStatus	status;		// 处理状态
	int				addDate;	// 创建时间（Unix Timestamp）
};
// ticket列表定义
typedef list<LSLCTicketListItem> TicketList;

// ticket附件URL列表
typedef list<string> TicketFileList;
// ticket详情内容item定义
class LSLCTicketContentItem
{
public:
	LSLCTicketContentItem()
	{
		method = TICKET_METHOD_DEFAULT;
		fromName = "";
		toName = "";
		sendDate = 0;
		message = "";
	}
	virtual ~LSLCTicketContentItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[TICKET_TICKETDETAIL_METHOD].isIntegral()) {
				int methodValue = data[TICKET_TICKETDETAIL_METHOD].asInt();
				method = GetTicketMethodValue(methodValue);
			}
			if (data[TICKET_TICKETDETAIL_FROMNAME].isString()) {
				fromName = data[TICKET_TICKETDETAIL_FROMNAME].asString();
			}
			if (data[TICKET_TICKETDETAIL_TONAME].isString()) {
				toName = data[TICKET_TICKETDETAIL_TONAME].asString();
			}
			if (data[TICKET_TICKETDETAIL_SENDDATE].isIntegral()) {
				sendDate = data[TICKET_TICKETDETAIL_SENDDATE].asInt();
			}
			if (data[TICKET_TICKETDETAIL_MESSAGE].isString()) {
				message = data[TICKET_TICKETDETAIL_MESSAGE].asString();
			}
			if (data[TICKET_TICKETDETAIL_FILELIST].isArray()) {
				Json::Value fileListJson = data[TICKET_TICKETDETAIL_FILELIST];
				for (int i = 0; i < fileListJson.size(); i++)
				{
					Json::Value jsonValue = fileListJson.get(i, Json::Value::null);
					if (jsonValue.isString()) {
						fileList.push_back(jsonValue.asString());
					}
				}
			}

			result = true;
		}
		return result;
	}

public:
	TicketMethod	method;		// 回复类型
	string			fromName;	// 发送人
	string			toName;		// 接收人
	int			 	sendDate;	// 发送时间
	string			message;	// 内容
	TicketFileList	fileList;	// 文件URL列表
};
typedef list<LSLCTicketContentItem> TicketContentList;

// 查询ticket详情接口 TICKET_DETAIL_PATH(/member/ticket_detail) item
class LSLCTicketDetailItem
{
public:
	LSLCTicketDetailItem()
	{
		title = "";
		status = TICKET_STATUS_DEFAULT;
	}
	virtual ~LSLCTicketDetailItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[TICKET_TICKETDETAIL_TITLE].isString()) {
				title = data[TICKET_TICKETDETAIL_TITLE].asString();
			}
			if (data[TICKET_TICKETDETAIL_STATUS].isIntegral()) {
				int statusValue = data[TICKET_TICKETDETAIL_STATUS].asInt();
				status = GetTicketStatusValue(statusValue);
			}
			if (data[COMMON_DATA_LIST].isArray()) {
				Json::Value listJson = data[COMMON_DATA_LIST];
				for (int i = 0; i < listJson.size(); i++)
				{
					Json::Value contentJson = listJson.get(i, Json::Value::null);
					LSLCTicketContentItem contentItem;
					if (contentItem.Parsing(contentJson)) {
						contentList.push_back(contentItem);
					}
				}
			}

			result = true;
		}
		return result;
	}

public:
	string				title;			// 标题
	TicketStatus		status;			// 处理状态
	TicketContentList	contentList;	// 内容列表
};


#endif /* LSLCTICKET_H_ */
