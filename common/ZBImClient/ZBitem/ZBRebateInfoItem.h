/*
 * ZBRebateInfoItem.h
 *
 *  Created on: 2018-3-05
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBREBATEINFOITEM_H_
#define ZBREBATEINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

// 返回参数定义
#define REBATEINFO_CURCREDIT_PARAM  "cur_credit"
#define REBATEINFO_CURTIME_PARAM    "cur_time"
#define REBATEINFO_PRECREDIT_PARAM  "pre_credit"
#define REBATEINFO_PRETIME_PARAM    "pre_time"


class ZBRebateInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* curCredit */
            if (root[REBATEINFO_CURCREDIT_PARAM].isNumeric()) {
                curCredit = root[REBATEINFO_CURCREDIT_PARAM].asDouble();
            }
            /* curTime */
            if (root[REBATEINFO_CURTIME_PARAM].isInt()) {
                curTime = root[REBATEINFO_CURTIME_PARAM].asInt();
            }
            /* preCredit */
            if (root[REBATEINFO_PRECREDIT_PARAM].isNumeric()) {
                preCredit = root[REBATEINFO_PRECREDIT_PARAM].asDouble();
            }
            /* preTime */
            if (root[REBATEINFO_PRETIME_PARAM].isInt()) {
                preTime = root[REBATEINFO_PRETIME_PARAM].asInt();
            }
            
        }

        result = true;

        return result;
    }

    ZBRebateInfoItem() {
        curCredit = 0.0;
        curTime = 0;
        preCredit = 0.0;
        preTime = 0;
    }
    
    virtual ~ZBRebateInfoItem() {
        
    }
    
    /**
     * 返点信息结构体
     * curCredit                已返点数余额
     * curTime                  剩余发电倒数时间（秒）
     * preCredit                每期返点数
     * preTime                  返点周期时间 (秒)
     */
    double curCredit;;
    int    curTime;
    double preCredit;
    int   preTime;
};

#endif /* ZBREBATEINFOITEM_H_*/
