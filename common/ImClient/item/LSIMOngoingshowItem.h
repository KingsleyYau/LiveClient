/*
 * LSIMOngoingshowItem.h
 *
 *  Created on: 2018-05-07
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSIMONGOINGSHOWITEM_H_
#define LSIMONGOINGSHOWITEM_H_

#include <string>
#include "IMProgramItem.h"
using namespace std;

#include <json/json/json.h>


#define ONGOINGSHOWLIST_SHOWINFO_PARAM                  "show_info"
#define ONGOINGSHOWLIST_TYPE_PARAM                      "type"
#define ONGOINGSHOWLIST_MSG_PARAM                       "msg"

class LSIMOngoingshowItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* showInfo */
            if (root[ONGOINGSHOWLIST_SHOWINFO_PARAM].isObject()) {
                showInfo.Parse(root[ONGOINGSHOWLIST_SHOWINFO_PARAM]);
            }
            
            /* type */
            if (root[ONGOINGSHOWLIST_TYPE_PARAM].isNumeric()) {
                type = GetIMProgramNoticeType(root[ONGOINGSHOWLIST_TYPE_PARAM].asInt());
            }
            
            /* msg */
            if (root[ONGOINGSHOWLIST_MSG_PARAM].isString()) {
                msg = root[ONGOINGSHOWLIST_MSG_PARAM].asString();
            }
        }
        result = true;
        return result;
    }
    
    LSIMOngoingshowItem() {
        type = IMPROGRAMNOTICETYPE_UNKNOW;
        msg = "";
    }
    
    virtual ~LSIMOngoingshowItem() {
        
    }
    /**
     * 将要开播的节目
     * showInfo             节目
     * type                 通知类型（IMPROGRAMNOTICETYPE_BUYTICKET：已购票的通知，IMPROGRAMNOTICETYPE_FOLLOW：仅关注通知）
     * msg		            消息提示文字
     */
    IMProgramItem           showInfo;
    IMProgramNoticeType     type;
    string                  msg;
    
};

#endif /* LSIMONGOINGSHOWITEM_H_*/
