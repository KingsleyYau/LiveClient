/*
 * LSLiveChatRequestFakeDefine.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTFAKEDEFINE_H_
#define LSLIVECHATREQUESTFAKEDEFINE_H_

#include "LSLiveChatRequestDefine.h"

/* ########################	检查真假服务器模块  ######################## */

/* 2.1.检查真假服务器 */
/* 接口路径定义 */
#define FAKE_CHECK_SERVER_PATH "/member/check_server"

/* 提交参数 */
#define FAKE_EMAIL          "email"

/* 返回字段 */
#define FAKE_WEBHOST        "webhost"
#define FAKE_APPHOST		"apphost"
#define FAKE_WAPHOST		"waphost"
#define FAKE_PAY_API        "pay_api"
#define FAKE_FAKE           "fake"

/* 2.1.检查真假服务器 END */

#endif /* LSLIVECHATREQUESTFAKEDEFINE_H_ */
