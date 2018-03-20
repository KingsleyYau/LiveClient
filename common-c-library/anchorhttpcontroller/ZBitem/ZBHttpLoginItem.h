/*
 * ZBHttpLoginItem.h
 *
 *  Created on: 2018-2-279
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBLOGINITEM_H_
#define ZBLOGINITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"
#include "../ZBHttpRequestEnum.h"

class ZBHttpLoginItem {
public:
    void Parse(const Json::Value& root) {
        if( root.isObject() ) {
            /* userId */
            if( root[LADYLOGIN_USERID].isString() ) {
                userId = root[LADYLOGIN_USERID].asString();
            }
            
            /* token */
            if( root[LADYLOGIN_TOKEN].isString() ) {
                token = root[LADYLOGIN_TOKEN].asString();
            }
            
            /* nickName */
            if( root[LADYLOGIN_NICKNAME].isString() ) {
                nickName = root[LADYLOGIN_NICKNAME].asString();
            }
            
            /* photourl */
            if( root[LADYLOGIN_PHOTOURL].isString() ) {
                photoUrl = root[LADYLOGIN_PHOTOURL].asString();
            }
            
        }
        
    }
    
    ZBHttpLoginItem() {
        userId = "";
        token = "";
        nickName = "";
        photoUrl = "";
    }
    
    virtual ~ZBHttpLoginItem() {
        
    }
    /**
     * 登录成功结构体
     * userId			用户ID
     * token            直播系统不同服务器的统一验证身份标识
     * nickName         昵称
     * photoUrl		    头像url
     */
    string userId;
    string token;
    string nickName;
    string photoUrl;
};

#endif /* ZBLOGINITEM_H_ */
