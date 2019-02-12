/*
 * HttpLetterListItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLETTERLISTITEM_H_
#define HTTPLETTERLISTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "HttpLetterHasItem.h"
#include "HttpLetterOppAnchorItem.h"


class HttpLetterListItem {
public:
    bool Parse(const Json::Value& root, bool isLoi) {
        bool result = false;
        if (root.isObject()) {
            if (isLoi) {
                /* letterId */
                if (root[LETTER_LOI_ID].isString()) {
                    letterId = root[LETTER_LOI_ID].asString();
                }
                /* letterSendTime */
                if (root[LETTER_LOI_SEND_TIME].isNumeric()) {
                    letterSendTime = root[LETTER_LOI_SEND_TIME].asInt();
                }
                /* letterBrief */
                if (root[LETTER_LOI_BRIEF].isString()) {
                    letterBrief = root[LETTER_LOI_BRIEF].asString();
                }
                if (root[LETTER_OPP_ANCHOR].isObject()) {
                    oppAnchor.Parse(root[LETTER_OPP_ANCHOR]);
                }
            } else {
                /* letterId */
                if (root[LETTER_EMF_ID].isString()) {
                    letterId = root[LETTER_EMF_ID].asString();
                }
                /* letterSendTime */
                if (root[LETTER_EMF_SEND_TIME].isNumeric()) {
                    letterSendTime = root[LETTER_EMF_SEND_TIME].asInt();
                }
                /* letterBrief */
                if (root[LETTER_EMF_BRIEF].isString()) {
                    letterBrief = root[LETTER_EMF_BRIEF].asString();
                }
                if (root[LETTER_OPP_USER].isObject()) {
                    oppAnchor.Parse(root[LETTER_OPP_USER]);
                }
            }

            
            /* hasItem */
            hasItem.Parse(root);

        }
        result = true;
        return result;
    }

    HttpLetterListItem() {
        letterId = "";
        letterSendTime = 0;
        letterBrief = "";
    }
    
    virtual ~HttpLetterListItem() {
        
    }
    
    /**
     * 信件列表的信息item(EMF和意向信)
     * oppAnchor        主播信息
     * letterId         信件ID
     * letterSendTime   信件发送时间
     * letterBrief      信件内容摘要
     * hasItem          是否item
     */
    HttpLetterOppAnchorItem oppAnchor;
    string      letterId;
    long        letterSendTime;
    string      letterBrief;
    HttpLetterHasItem hasItem;
};

typedef list<HttpLetterListItem> HttpLetterItemList;

#endif /* HTTPLETTERLISTITEM_H_*/
