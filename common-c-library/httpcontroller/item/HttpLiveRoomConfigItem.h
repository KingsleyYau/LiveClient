/*
 * HttpLiveRoomConfigItem.h
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLIVEROOMCONFIGITEM_H_
#define HTTPLIVEROOMCONFIGITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"


class HttpLiveRoomConfigItem {
public:
    void Parse(const Json::Value& root) {
        if( root.isObject() ) {
            /* imSvr_ip */
            if( root[LIVEROOM_IMSVR_IP].isString() ) {
                imSvr_ip = root[LIVEROOM_IMSVR_IP].asString();
            }
            
            /* imSvr_port */
            if( root[LIVEROOM_IMSVR_PORT].isInt() ) {
                imSvr_port = root[LIVEROOM_IMSVR_PORT].asInt();
            }
            
            /* httpSvr_ip */
            if( root[LIVEROOM_HTTPSVR_IP].isString() ) {
                httpSvr_ip = root[LIVEROOM_HTTPSVR_IP].asString();
            }
            
            /* httpSvr_port */
            if( root[LIVEROOM_HTTPSVR_PORT].isInt() ) {
                httpSvr_port = root[LIVEROOM_HTTPSVR_PORT].asInt();
            }
            
            /* uploadSvr_ip */
            if( root[LIVEROOM_UPLOADSVR_IP].isString() ) {
                uploadSvr_ip = root[LIVEROOM_UPLOADSVR_IP].asString();
            }
            
            /* uploadSvr_port */
            if( root[LIVEROOM_UPLOADSVR_PORT].isInt() ) {
                uploadSvr_port = root[LIVEROOM_UPLOADSVR_PORT].asInt();
            }

        }
    }
    
    /**
     * 获取礼物列表成功结构体
     * @param imSvr_ip			IM服务器ip或域名
     * @param imSvr_port		IM服务器端口
     * @param httpSvr_ip        http服务器ip或域名
     * @param httpSvr_port		http服务器端口
     * @param uploadSvr_ip		上传图片服务器ip或域名
     * @param uploadSvr_port	上传图片服务器或端口
     */
    HttpLiveRoomConfigItem() {
        imSvr_ip = "";
        imSvr_port = 0;
        httpSvr_ip = "";
        httpSvr_port = 0;
        uploadSvr_ip = "";
        uploadSvr_port = 0;
    }
    
    virtual ~HttpLiveRoomConfigItem() {
        
    }
    
    string   imSvr_ip;
    int      imSvr_port;
    string   httpSvr_ip;
    int      httpSvr_port;
    string   uploadSvr_ip;
    int      uploadSvr_port;

};


#endif /* HTTPLIVEROOMCONFIGITEM_H_*/
