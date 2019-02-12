/*
 * HttpDetailLoiItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPDETAILLOIITEM_H_
#define HTTPDETAILLOIITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "HttpLetterDetailAnchorItem.h"
#include "HttpLetterImgItem.h"
#include "HttpLetterVideoItem.h"

class HttpDetailLoiItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* oppAnchor */
            if (root[LETTER_OPP_ANCHOR].isObject()) {
                oppAnchor.Parse(root[LETTER_OPP_ANCHOR]);
            }
            /* loiId */
            if (root[LETTER_LOI_ID].isString()) {
                loiId = root[LETTER_LOI_ID].asString();
            }
            /* loiSendTime */
            if (root[LETTER_LOI_SEND_TIME].isNumeric()) {
                loiSendTime = root[LETTER_LOI_SEND_TIME].asInt();
            }
            /* loiContent */
            if (root[LETTER_LOI_CONTENT].isString()) {
                loiContent = root[LETTER_LOI_CONTENT].asString();
            }
            /* loiImgList */
            if (root[LETTER_LOI_IMG_LIST].isArray()) {
                for (int i = 0; i < root[LETTER_LOI_IMG_LIST].size(); i++) {
                    HttpLetterImgItem imgItem;
                    imgItem.Parse(root[LETTER_LOI_IMG_LIST].get(i, Json::Value::null));
                    loiImgList.push_back(imgItem);
                }
            }
            /* loiVideoList */
            if (root[LETTER_LOI_VIDEO_LIST].isArray()) {
                for (int i = 0; i < root[LETTER_LOI_VIDEO_LIST].size(); i++) {
                    HttpLetterVideoItem videoItem;
                    videoItem.Parse(root[LETTER_LOI_VIDEO_LIST].get(i, Json::Value::null));
                    loiVideoList.push_back(videoItem);
                }
            }
            
            /* hasRead */
            if (root[LETTER_HAS_READ].isNumeric()) {
                hasRead = root[LETTER_HAS_READ].asInt() == 0 ? false : true;
            }
            /* hasReplied */
            if (root[LETTER_HAS_REPLIED].isNumeric()) {
                hasReplied = root[LETTER_HAS_REPLIED].asInt() == 0 ? false : true;
            }

        }
        result = true;
        return result;
    }

    HttpDetailLoiItem() {
        loiId = "";
        loiSendTime = 0;
        loiContent = "";
        hasRead = false;
        hasReplied = false;
    }
    
    virtual ~HttpDetailLoiItem() {
        
    }
    
    /**
     * 意向信详情
     * oppAnchor        主播详细信息
     * loiId            信件ID
     * loiSendTime      信件发送时间
     * loiContent       意向信内容
     * loiImgList       图片附件列表
     * loiVideoList     视频列表
     * hasRead          是否已读
     * hasReplied       是否已回复
     */
    HttpLetterDetailAnchorItem oppAnchor;
    string      loiId;
    long        loiSendTime;
    string      loiContent;
    HttpLetterImgList  loiImgList;
    HttpLetterVideoList loiVideoList;
    bool hasRead;
    bool hasReplied;
};


#endif /* HTTPDETAILLOIITEM_H_*/
