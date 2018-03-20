/*
 * ZBHttpTodayCreditItem.h
 *
 *  Created on: 2018-3-1
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPTODAYCREDITITEM_H_
#define ZBHTTPTODAYCREDITITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"
#include "../ZBHttpRequestEnum.h"

class ZBHttpTodayCreditItem {
public:
    void Parse(const Json::Value& root) {
        if( root.isObject() ) {
            /* monthCredit */
            if( root[GETTODAYCREDIT_MONTHCREDIT].isNumeric() ) {
                monthCredit = root[GETTODAYCREDIT_MONTHCREDIT].asInt();
            }
            
            /* monthCompleted */
            if( root[GETTODAYCREDIT_MONTHBCCOMPLETED].isNumeric() ) {
                monthCompleted = root[GETTODAYCREDIT_MONTHBCCOMPLETED].asInt();
            }
            
            /* monthTarget */
            if( root[GETTODAYCREDIT_MONTHBCTARGET].isNumeric() ) {
                monthTarget = root[GETTODAYCREDIT_MONTHBCTARGET].asInt();
            }
            
            /* monthProgress */
            if( root[GETTODAYCREDIT_MONTHBCPROGRESS].isNumeric() ) {
                monthProgress = root[GETTODAYCREDIT_MONTHBCPROGRESS].asInt();
            }
            
        }
        
    }
    
    ZBHttpTodayCreditItem() {
        monthCredit = 0;
        monthCompleted = 0;
        monthTarget = 0;
        monthProgress = 0;
    }
    
    virtual ~ZBHttpTodayCreditItem() {
        
    }
    /**
     * 获取收入信息结构体
     * monthCredit			本月产出数
     * monthCompleted       本月开播已完成天数
     * monthTarget          本月开播计划天数
     * monthProgress        本月已开播进度（整型）（取值范围为0-100）
     */
    int monthCredit;
    int monthCompleted;
    int monthTarget;
    int monthProgress;
};

#endif /* ZBHTTPTODAYCREDITITEM_H_ */
