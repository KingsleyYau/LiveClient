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
            
            /* country */
            if( root[LOGIN_COUNTRY].isString() ) {
                country = root[LOGIN_COUNTRY].asString();
            }
            
            /* photourl */
            if( root[LOGIN_PHOTOURL].isString() ) {
                photoUrl = root[LOGIN_PHOTOURL].asString();
            }
            
            /* sign */
            if( root[LOGIN_SIGN].isString() ) {
                sign = root[LOGIN_SIGN].asString();
            }
            
            /* anchor */
            if( root[LOGIN_ANCHOR].isInt() ) {
                anchor = root[LOGIN_ANCHOR].asInt();
            }
            
            /* modifyinfo */
            if( root[LOGIN_MODIFYINFO].isInt() ) {
                modifyinfo = root[LOGIN_MODIFYINFO].asInt();
            }
        }
    }
    
    /**
     * 登录成功结构体
     * @param userId			用户ID
     * @param token				直播系统不同服务器的统一验证身份标识
     * @param nickName          昵称
     * @param levenl			级别
     * @param country			国家／地区
     * @param photoUrl		    头像url
     * @param sign				个人签名
     * @param anchor			是否主播（0:不是 1:是）
     * @param modifyinfo		是否需要修改个人资料（0:不是 1:是）
     */
    HttpLoginItem() {
        userId = "";
        token = "";
        nickName = "";
        level = 0;
        country = "";
        photoUrl = "";
        sign = "";
        anchor = false;
        modifyinfo = false;
    }
    
    virtual ~HttpLoginItem() {
        
    }
    
    string userId;
    string token;
    string nickName;
    int level;
    string country;
    string photoUrl;
    string sign;
    bool anchor;
    bool modifyinfo;
};

#endif /* LOGINITEM_H_ */
