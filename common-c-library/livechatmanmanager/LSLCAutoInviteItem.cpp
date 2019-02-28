/*
 * author: Alex
 *   date: 2019-01-23
 *   file: LSLCAutoInviteItem.cpp
 *   desc: 自动邀请item
 */

#include "LSLCAutoInviteItem.h"
#include <common/CheckMemoryLeak.h>

LSLCAutoInviteItem::LSLCAutoInviteItem()
{
	womanId = "";
    manId = "";
    identifyKey = "";
}

LSLCAutoInviteItem::LSLCAutoInviteItem(string womanId, string manId, string identifyKey)
{
    this->womanId = womanId;
    this->manId = manId;
    this->identifyKey = identifyKey;
}

LSLCAutoInviteItem::~LSLCAutoInviteItem()
{

}


