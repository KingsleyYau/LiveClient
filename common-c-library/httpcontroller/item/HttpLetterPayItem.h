/*
 * HttpLetterPayItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLETTERPAYITEM_H_
#define HTTPLETTERPAYITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"


class HttpLetterPayItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* resourceId */
            if (root[LETTER_RESOURCE_ID].isString()) {
                resourceId = root[LETTER_RESOURCE_ID].asString();
            }
            /* describe */
            if (root[LETTER_DESCRIBE].isString()) {
                describe = root[LETTER_DESCRIBE].asString();
            }
            /* isFee */
            if (root[LETTER_IS_FREE].isNumeric()) {
                // LETTER_IS_FREE是免费的，所以  LETTER_IS_FREE == 0；代表时收费（isFee时收费）
                isFee = root[LETTER_IS_FREE].asInt() == 0 ? true : false;
            }
            /* status */
            if (root[LETTER_STATUS].isNumeric()) {
                status = GetLSPayFeeStatus(root[LETTER_STATUS].asInt());
            }
        }
        result = true;
        return result;
    }

    HttpLetterPayItem() {
        resourceId = "";
        isFee = true;
        status = LSPAYFEESTATUS_UNPAID;
        describe = "";
    }
    
    virtual ~HttpLetterPayItem() {
        
    }
    
    /**
     * emf图片信息
     * resourceId     图片/视频ID
     * isFee          是否收费附件
     * status         付费状态
     * describe       图片/视频描述
     */
    string    resourceId;
    bool      isFee;
    LSPayFeeStatus status;
    string    describe;
};

#endif /* HTTPLETTERPAYITEM_H_*/
