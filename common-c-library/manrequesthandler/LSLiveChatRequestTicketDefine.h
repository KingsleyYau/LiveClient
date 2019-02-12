/*
 * LSLiveChatRequestTicketDefine.h
 *
 *  Created on: 2015-07-13
 *      Author: Samson.Fan
 * Description: Ticket 协议接口定义
 */

#ifndef LSLIVECHATREQUESTTICKETDEFINE_H_
#define LSLIVECHATREQUESTTICKETDEFINE_H_

/* ########################	Ticket相关接口  ######################## */
/// ------------------- 请求参数定义 -------------------
#define TICKET_REQUEST_TICKETID		"ticketid"
#define TICKET_REQUEST_MESSAGE		"message"
#define TICKET_REQUEST_FILE			"file1"
#define TICKET_REQUEST_TITLE		"title"
#define TICKET_REQUEST_TYPEID		"typeid"

/// ------------------- 返回参数定义 -------------------
// 查询ticket列表
#define TICKET_TICKETLIST_PATH		"/member/ticket_list"
// item
#define TICKET_TICKETLIST_ID			"ticketid"
#define TICKET_TICKETLIST_TITLE			"title"
#define TICKET_TICKETLIST_UNREADNUM		"unreadnum"
#define TICKET_TICKETLIST_STATUS		"status"
#define TICKET_TICKETLIST_ADDDATE		"adddate"
// 处理状态定义
typedef enum {
	TICKET_STATUS_OPEN = 0,			// 打开状态
	TICKET_STATUS_SYSTEMCLOSE = 1,	// 系统关闭
	TICKET_STATUS_USERCLOSE = 2,	// 用户关闭
	TICKET_STATUS_BEGIN = TICKET_STATUS_OPEN,		// 有效范围起始值
	TICKET_STATUS_END = TICKET_STATUS_USERCLOSE,	// 有效范围结束值
	TICKET_STATUS_DEFAULT = TICKET_STATUS_OPEN,		// 默认值
} TicketStatus;
#define GetTicketStatusValue(param) (TICKET_STATUS_BEGIN <= param && param <= TICKET_STATUS_END ? (TicketStatus)param : TICKET_STATUS_DEFAULT)

// 查询ticket详情
#define TICKET_TICKETDETAIL_PATH	"/member/ticket_detail"
//item
#define TICKET_TICKETDETAIL_TITLE		"title"
#define TICKET_TICKETDETAIL_STATUS		"status"
#define TICKET_TICKETDETAIL_METHOD		"method"
#define TICKET_TICKETDETAIL_FROMNAME	"fromname"
#define TICKET_TICKETDETAIL_TONAME		"toname"
#define TICKET_TICKETDETAIL_SENDDATE	"senddate"
#define TICKET_TICKETDETAIL_MESSAGE		"message"
#define TICKET_TICKETDETAIL_FILELIST	"filelist"
// 回复类型定义
typedef enum {
	TICKET_METHOD_SEND = 0,		// 男士发送
	TICKET_METHOD_RECEIVE = 1,	// 系统回复
	TICKET_METHOD_BEGIN = TICKET_METHOD_SEND,	// 有效范围起始值
	TICKET_METHOD_END = TICKET_METHOD_RECEIVE,	// 有效范围结束值
	TICKET_METHOD_DEFAULT = TICKET_METHOD_SEND,	// 默认值
} TicketMethod;
#define GetTicketMethodValue(param) (TICKET_METHOD_BEGIN <= param && param <= TICKET_METHOD_END ? (TicketMethod)param : TICKET_METHOD_DEFAULT)

// 回复ticket
#define TICKET_REPLYTICKET_PATH		"/member/ticket_reply"

// 设置ticket为resolved
#define TICKET_RESOLVEDTICKET_PATH	"/member/ticket_resolved"

// 创建ticket
#define TICKET_ADDTICKET_PATH		"/member/ticket_add"

#endif /* LSLIVECHATREQUESTVIDEOSHOWDEFINE_H_ */
