/*
 * ZBHttpLiveFansItem.h
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPLIVEFANSITEM_H_
#define ZBHTTPLIVEFANSITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"

class ZBHttpLiveFansItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* userId */
			if( root[LIVEFANSLIST_USERID].isString() ) {
				userId = root[LIVEFANSLIST_USERID].asString();
			}
            
			/* nickName */
			if( root[LIVEFANSLIST_NICKNAME].isString() ) {
				nickName = root[LIVEFANSLIST_NICKNAME].asString();
			}

			/* photourl */
			if( root[LIVEFANSLIST_PHOTOURL].isString() ) {
				photoUrl = root[LIVEFANSLIST_PHOTOURL].asString();
			}
            
            /* mountId */
            if( root[LIVEFANSLIST_MOUNTID].isString() ) {
                mountId = root[LIVEFANSLIST_MOUNTID].asString();
            }
            
            /* mountName */
            if( root[LIVEFANSLIST_MOUNTNAME].isString() ) {
                mountId = root[LIVEFANSLIST_MOUNTNAME].asString();
            }
            
            /* mountUrl */
            if( root[LIVEFANSLIST_MOUNTURL].isString() ) {
                mountUrl = root[LIVEFANSLIST_MOUNTURL].asString();
            }
            
            /* level */
            if( root[LIVEFANSLIST_LEVEL].isIntegral() ) {
                level = root[LIVEFANSLIST_LEVEL].asInt();
            }
            
            /* isHasTicket */
            if( root[LIVEFANSLIST_HASTICKET].isIntegral() ) {
                isHasTicket = root[LIVEFANSLIST_HASTICKET].asInt() == 0 ? false : true;
            }
            
        }
	}

	ZBHttpLiveFansItem() {
		userId = "";
		nickName = "";
		photoUrl = "";
        mountId = "";
        mountName = "";
        mountUrl = "";
        level = 0;
        isHasTicket = false;
	}

	virtual ~ZBHttpLiveFansItem() {

	}
    /**
     * 指定观众信息结构体
     * userId			观众ID
     * nickName         观众昵称
     * photoUrl		    观众头像url
     * mountId          坐驾ID
     * mountName        座驾名称
     * mountUrl         坐驾图片url
     * level            用户等级
     * isHasTicket      是否已购票（0：否，1：是）
     */
    string userId;
	string nickName;
	string photoUrl;
    string mountId;
    string mountName;
    string mountUrl;
    int    level;
    bool   isHasTicket;
};

typedef list<ZBHttpLiveFansItem> ZBHttpLiveFansList;

#endif /* ZBHTTPLIVEFANSITEM_H_ */
