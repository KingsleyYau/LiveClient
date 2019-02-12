/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCContactManager.h
 *   desc: LiveChat联系人管理器
 */

#pragma once

#include <livechat/ILSLiveChatClientDef.h>
#include <common/IAutoLock.h>
#include <string>
#include <map>


using namespace std;

class LSLCContactManager
{
private:
	typedef map<string, bool> ContactUserMap;		// key: userId, value: unused

public:
	LSLCContactManager();
	virtual ~LSLCContactManager();

public:
	// 更新联系人列表
	void UpdateWithContactList(const TalkUserList& userList);
	// 用户是否存在于联系人列表
	bool IsExist(const string& userId);

private:
	ContactUserMap	m_contactListMap;		// 联系人列表
	IAutoLock*		m_contactListMapLock;	// 联系人列表锁
};
