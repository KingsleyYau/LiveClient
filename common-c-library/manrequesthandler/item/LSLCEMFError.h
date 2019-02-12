/*
 * LSLCEMFError.h
 *
 *  Created on: 2015-04-20
 *      Author: Samson.Fan
 */

#ifndef EMFERROR_H_
#define EMFERROR_H_

#include <string>
#include <list>
using namespace std;

#include "../LSLiveChatRequestEMFDefine.h"
#include <json/json/json.h>
#include <common/CommonFunc.h>

// 发送邮件 EMF_SENDMSG_PATH(/emf/sendmsg)
class LSLCEMFSendMsgErrorItem
{
public:
	LSLCEMFSendMsgErrorItem()
	{
		money = "";
		memberType = 0;
	}
	virtual ~LSLCEMFSendMsgErrorItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data[EMF_SENDMSG_MONEY].isString()) {
			money = data[EMF_SENDMSG_MONEY].asString();
		}

		if (data[EMF_MEMBER_TYPE].isInt()) {
			memberType = data[EMF_MEMBER_TYPE].asInt();
		}

		if (!money.empty()) {
			result = true;
		}
		return result;
	}

public:
	string	money;	// 余额
	int memberType; //会员月费类型
};


#endif /* LSLCEMFERROR_H_ */
