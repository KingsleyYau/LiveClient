/*
 * IMLoveLevelItem.h
 *
 *  Created on: 2018-06-11
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMLOVELEVELITEM_H_
#define IMLOVELEVELITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMLOVELEVELITEM_LOVELEVEL_PARAM             "love_level"
#define IMLOVELEVELITEM_ANCHORID_PARAM              "anchor_id"
#define IMLOVELEVELITEM_ANCHORNAME_PARAM            "anchor_name"


class IMLoveLevelItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {

            /* loveLevel */
            if (root[IMLOVELEVELITEM_LOVELEVEL_PARAM].isNumeric()) {
                loveLevel = root[IMLOVELEVELITEM_LOVELEVEL_PARAM].asInt();
            }
            
            /* anchorId */
            if (root[IMLOVELEVELITEM_ANCHORID_PARAM].isString()) {
                anchorId = root[IMLOVELEVELITEM_ANCHORID_PARAM].asString();
            }
            
            /* anchorName */
            if (root[IMLOVELEVELITEM_ANCHORNAME_PARAM].isString()) {
                anchorName = root[IMLOVELEVELITEM_ANCHORNAME_PARAM].asString();
            }
            
        }
        return result;
    }
    
    IMLoveLevelItem() {
        loveLevel = 0;
        anchorId = "";
        anchorName = "";
    }
    
    virtual ~IMLoveLevelItem() {
        
    }
    /**
     * 观众亲密度升级
     * @loveLevel           亲密度等级
     * @anchorId            主播ID
     * @anchorName          主播昵称
     */

    int      loveLevel;
    string   anchorId;
    string   anchorName;
    
};



#endif /* IMLOVELEVELITEM_H_*/
