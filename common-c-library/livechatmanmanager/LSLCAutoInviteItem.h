/*
 * author: Alex
 *   date: 2019-01-23
 *   file: LSLCAutoInviteItem.h
 *   desc: 自动邀请item
 */

#pragma once

#include <string>
#include <map>
using namespace std;

class LSLCAutoInviteItem
{
public:
	LSLCAutoInviteItem();
    LSLCAutoInviteItem(string womanId, string manId, string identifyKey);
	virtual ~LSLCAutoInviteItem();

public:
    /**
     * 女士Id
     */
   string womanId;
    /**
     * 男士Id
     */
    string manId;
    /**
     * 验证码
     */
    string identifyKey;
};

typedef map<string, LSLCAutoInviteItem*>  AutoInviteMap;
