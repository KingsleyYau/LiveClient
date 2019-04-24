/*
 * LSLCLCSendPhotoItem.h
 *
 *  Created on: 2015-04-23
 *      Author: Samson.Fan
 */

#ifndef LSLCLCSENDPHOTOITEM_H_
#define LSLCLCSENDPHOTOITEM_H_

#include <string>
#include <list>
using namespace std;

#include <manrequesthandler/LSLiveChatRequestLiveChatDefine.h>
#include <json/json/json.h>
#include <common/CommonFunc.h>

// 发送私密照片LC_SENDPHOTO_PATH(/livechat/setstatus.php?action=man_send_photo)
class LSLCLCSendPhotoItem
{
public:
	LSLCLCSendPhotoItem() {}
	virtual ~LSLCLCSendPhotoItem() {}

public:
	bool Parsing(Json::Value root)
	{
		bool result = false;
		if (root.isObject()) {
            if (root[LIVECHAT_PHOTOID].isString()) {
                photoId = root[LIVECHAT_PHOTOID].asString();
            }
			
            if (root[LIVECHAT_SENDID].isString()) {
                sendId = root[LIVECHAT_SENDID].asString();
            }

			if (!photoId.empty() && !sendId.empty()) {
				result = true;
			}
		}
		return result;
	}

public:
	string	photoId;
	string	sendId;
};

#endif /* LCSENDPHOTOITEM_H_ */
