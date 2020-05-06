/*
 * HttpDetailEmfItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPDETAILEMFITEM_H_
#define HTTPDETAILEMFITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "HttpLetterDetailAnchorItem.h"
#include "HttpEmfImgItem.h"
#include "HttpEmfVideoItem.h"
#include "HttpScheduleInviteDetailItem.h"

class HttpDetailEmfItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* oppAnchor */
            if (root[LETTER_OPP_ANCHOR].isObject()) {
                oppAnchor.Parse(root[LETTER_OPP_ANCHOR]);
            }
            /* emfId */
            if (root[LETTER_EMF_ID].isString()) {
                emfId = root[LETTER_EMF_ID].asString();
            }
            /* emfSendTime */
            if (root[LETTER_EMF_SEND_TIME].isNumeric()) {
                emfSendTime = root[LETTER_EMF_SEND_TIME].asInt();
            }
            /* emfContent */
            if (root[LETTER_EMF_CONTENT].isString()) {
                emfContent = root[LETTER_EMF_CONTENT].asString();
            }
            /* emfImgList */
            if (root[LETTER_EMF_IMG_LIST].isArray()) {
                for (int i = 0; i < root[LETTER_EMF_IMG_LIST].size(); i++) {
                    HttpEmfImgItem imgItem;
                    imgItem.Parse(root[LETTER_EMF_IMG_LIST].get(i, Json::Value::null));
                    emfImgList.push_back(imgItem);
                }
            }
            /* emfVideoList */
            if (root[LETTER_EMF_VIDEO_LIST].isArray()) {
                for (int i = 0; i < root[LETTER_EMF_VIDEO_LIST].size(); i++) {
                    HttpEmfVideoItem videoItem;
                    videoItem.Parse(root[LETTER_EMF_VIDEO_LIST].get(i, Json::Value::null));
                    emfVideoList.push_back(videoItem);
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
            
            /* scheduleInfo */
            if (root[LETTER_SCHEDULE_INFO].isObject()) {
                scheduleInfo.Parse(root[LETTER_SCHEDULE_INFO]);
            }

        }
        result = true;
        return result;
    }

    HttpDetailEmfItem() {
        emfId = "";
        emfSendTime = 0;
        emfContent = "";
        hasRead = false;
        hasReplied = false;
    }
    
    virtual ~HttpDetailEmfItem() {
        
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
     * scheduleInfo    预约信息
     */
    HttpLetterDetailAnchorItem oppAnchor;
    string      emfId;
    long        emfSendTime;
    string      emfContent;
    HttpEmfImgList  emfImgList;
    HttpEmfVideoList emfVideoList;
    bool hasRead;
    bool hasReplied;
    HttpScheduleInviteDetailItem scheduleInfo;
};


#endif /* HTTPDETAILEMFITEM_H_*/
