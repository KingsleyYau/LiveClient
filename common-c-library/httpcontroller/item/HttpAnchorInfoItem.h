/*
 * HttpAnchorInfoItem.h
 *
 *  Created on: 2017-11-01
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPANCHORINFOITEM_H_
#define HTTPANCHORINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpAnchorInfoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
			/* address */
			if( root[LIVEROOM_GETUSERINFO_ANCHORINFO_ADDRESS].isString() ) {
				address = root[LIVEROOM_GETUSERINFO_ANCHORINFO_ADDRESS].asString();
			}

			/* anchorType */
			if( root[LIVEROOM_GETUSERINFO_ANCHORINFO_ANCHORTYPE].isNumeric() ) {
				anchorType = (AnchorLevelType)root[LIVEROOM_GETUSERINFO_ANCHORINFO_ANCHORTYPE].asInt();
			}
            
            /* isLive */
            if( root[LIVEROOM_GETUSERINFO_ANCHORINFO_ISLIVE].isNumeric() ) {
                isLive = root[LIVEROOM_GETUSERINFO_ANCHORINFO_ISLIVE].asInt() == 1 ? true : false;
            }
            
            /* introduction */
            if( root[LIVEROOM_GETUSRRINFO_ANCHORINFO_INTRODUCTION].isString() ) {
                introduction = root[LIVEROOM_GETUSRRINFO_ANCHORINFO_INTRODUCTION].asString();
            }
            
        }
	}

	HttpAnchorInfoItem() {
		address = "";
		anchorType = ANCHORLEVELTYPE_UNKNOW;
		isLive = false;
        introduction = "";
	}

	virtual ~HttpAnchorInfoItem() {

	}
    /**
     * 主播信息结构体
     * address              联系地址
     * anchorType           主播类型
     * isLive               是否正在公开直播（0：否，1：是）
     * introduction         主播个人介绍
     */
	string address;
	AnchorLevelType anchorType;
    bool isLive;
    string introduction;
};

#endif /* HTTPANCHORINFOITEM_H_ */
