/*
 * HttpLoginItem.h
 *
 *  Created on: 2017-5-19
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LOGINITEM_H_
#define LOGINITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpLoginItem {
public:
    void Parse(const Json::Value& root) {
        if( root.isObject() ) {
            /* userId */
            if( root[LOGIN_USERID].isString() ) {
                userId = root[LOGIN_USERID].asString();
            }
            
            /* token */
            if( root[LOGIN_TOKEN].isString() ) {
                token = root[LOGIN_TOKEN].asString();
            }
            
            /* nickName */
            if( root[LOGIN_NICKNAME].isString() ) {
                nickName = root[LOGIN_NICKNAME].asString();
            }
            
            /* level */
            if( root[LOGIN_LEVEL].isInt() ) {
                level = root[LOGIN_LEVEL].asInt();
            }
            
            /* experience */
            if( root[LOGIN_EXPERIENCE].isInt() ) {
                experience = root[LOGIN_EXPERIENCE].asInt();
            }
            
            /* photourl */
            if( root[LOGIN_PHOTOURL].isString() ) {
                photoUrl = root[LOGIN_PHOTOURL].asString();
            }
        }
        
    }
    
    HttpLoginItem() {
        userId = "";
        token = "";
        nickName = "";
        level = 0;
        experience = 0;
        photoUrl = "";
    }
    
    virtual ~HttpLoginItem() {
        
    }
    /**
     * 登录成功结构体
     * userId			用户ID
     * token				直播系统不同服务器的统一验证身份标识
     * nickName          昵称
     * levenl			级别
     * experience		经验值
     * photoUrl		    头像url
     */
    string userId;
    string token;
    string nickName;
    int level;
    int experience;
    string photoUrl;
};

#endif /* LOGINITEM_H_ */
