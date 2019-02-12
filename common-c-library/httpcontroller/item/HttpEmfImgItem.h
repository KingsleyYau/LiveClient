/*
 * HttpEmfImgItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPEMFIMGITEM_H_
#define HTTPEMFIMGITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "HttpLetterPayItem.h"
#include "HttpLetterImgItem.h"


class HttpEmfImgItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            payItem.Parse(root);
            letterImgItem.Parse(root);
        }
        result = true;
        return result;
    }

    HttpEmfImgItem() {
    }
    
    virtual ~HttpEmfImgItem() {
        
    }
    
    /**
     * 图片附件列表
     * payItem         支付item
     * letterImgItem   图片item
     */
    HttpLetterPayItem  payItem;
    HttpLetterImgItem  letterImgItem;
};
typedef list<HttpEmfImgItem> HttpEmfImgList;

#endif /* HTTPEMFIMGITEM_H_*/
