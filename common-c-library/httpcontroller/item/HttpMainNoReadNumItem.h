/*
 * HttpMainNoReadNumItem.h
 *
 *  Created on: 2018-6-22
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPMAINNOREADNUMITEM_H_
#define HTTPMAINNOREADNUMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"
#include "HttpLoginItem.h"

class HttpMainNoReadNumItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* showTicketUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_SHOWTICKETUNREADNUM].isNumeric()) {
                showTicketUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_SHOWTICKETUNREADNUM].asInt();
            }
            
            /* loiUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_LOIUNREADNUM].isNumeric()) {
                loiUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_LOIUNREADNUM].asInt();
            }
            
            /* emfUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_EMFUNREADNUM].isNumeric()) {
                emfUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_EMFUNREADNUM].asInt();
            }
            
            /* privateMessageUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_PRIVATEMESSAGEUNREADNUM].isNumeric()) {
                privateMessageUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_PRIVATEMESSAGEUNREADNUM].asInt();
            }
            /* bookingUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_BOOKINGUNREADNUM].isNumeric()) {
                bookingUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_BOOKINGUNREADNUM].asInt();
            }
            /* backpackUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_BACKPACKUNREADNUM].isNumeric()) {
                backpackUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_BACKPACKUNREADNUM].asInt();
            }
            
        }

        result = true;

        return result;
    }
    
    HttpMainNoReadNumItem() {
        showTicketUnreadNum = 0;
        loiUnreadNum = 0;
        emfUnreadNum = 0;
        privateMessageUnreadNum = 0;
        bookingUnreadNum = 0;
        backpackUnreadNum = 0;
        
    }
    
    virtual ~HttpMainNoReadNumItem() {
        
    }
    /**
     * 获取主界面未读数量
     * showTicketUnreadNum          节目未读数量
     * loiUnreadNum                 意向信未读数量
     * emfUnreadNum		            EMF未读数量
     * privateMessageUnreadNum      私信未读数量
     * bookingUnreadNum             预约未读数量
     * backpackUnreadNum            背包未读数量
     */
    int showTicketUnreadNum;
    int loiUnreadNum;
    int emfUnreadNum;
    int privateMessageUnreadNum;
    int bookingUnreadNum;
    int backpackUnreadNum;
};

#endif /* HTTPMAINNOREADNUMITEM_H_*/
