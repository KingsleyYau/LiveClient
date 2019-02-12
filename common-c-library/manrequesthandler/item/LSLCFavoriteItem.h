/*
 * LSLCFavoriteItem.h
 *
 *  Created on: 2018-10-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCFAVORITEITEM_H_
#define LSLCFAVORITEITEM_H_

#include <string>
using namespace std;


#include <json/json/json.h>

#include "../LSLiveChatRequestLadyDefine.h"
#include "../LSLiveChatRequestEnumDefine.h"

class LSLCFavoriteItem {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {

			if( root[FAVORITE_WOMANID].isString() ) {
				womanId = root[FAVORITE_WOMANID].asString();
			}

			if( root[FAVORITE_FIRSTNAME].isString() ) {
				firstName = root[FAVORITE_FIRSTNAME].asString();
			}
            
            if( root[FAVORITE_AGE].isNumeric() ) {
                age = root[FAVORITE_AGE].asInt();
            }

			if( root[FAVORITE_PHOTOURL].isString() ) {
				photoUrl = root[FAVORITE_PHOTOURL].asString();
			}
            
            if( root[FAVORITE_PHOTOBIGURL].isString() ) {
                photoBigUrl = root[FAVORITE_PHOTOBIGURL].asString();
            }
            
            if( root[FAVORITE_LASTTIME].isNumeric() ) {
                lastTime = root[FAVORITE_LASTTIME].asInt();
                
            }
            
            if( root[FAVORITE_CAMSTATUS].isNumeric() ) {
                camStatus = root[FAVORITE_CAMSTATUS].asInt() == 0 ? false : true;
                
            }
            
            if ( root[FAVORITE_ONLINE].isNumeric() ) {
                isOnline = root[FAVORITE_ONLINE].asInt() == 1 ? true : false;
            }
		}
	}

	LSLCFavoriteItem() {
		womanId = "";
		firstName = "";
        age = 0;
		photoUrl = "";
		photoBigUrl = "";
		lastTime = 0;
		camStatus = false;
        isOnline = false;
	}
	virtual ~LSLCFavoriteItem() {

	}

	/**
	 * 收藏女士列表成功回调
	 * @param womanId		女士ID
	 * @param firstName		女士first name
	 * @param age		    年龄
	 * @param photoURL		头像URL
	 * @param photoBigUrl   大头像URL
	 * @param lastTime		加收藏时间
     * @param camStatus		Cam是否可以（0: 为打开 1:已打开）
     * @param isOnline  在线状态（1:在线  0:不在线）
	 */
	string womanId;
	string firstName;
	int age;
	string photoUrl;
    string photoBigUrl;
	long lastTime;
	bool camStatus;
    bool isOnline;
};

#endif /* LSLCFAVORITEITEM_H_ */
