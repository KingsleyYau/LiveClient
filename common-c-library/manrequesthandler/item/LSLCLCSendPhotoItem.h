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
#include <xml/tinyxml.h>
#include <common/CommonFunc.h>

// 发送私密照片LC_SENDPHOTO_PATH(/livechat/setstatus.php?action=man_send_photo)
class LSLCLCSendPhotoItem
{
public:
	LSLCLCSendPhotoItem() {}
	virtual ~LSLCLCSendPhotoItem() {}

public:
	bool Parsing(const TiXmlNode* info)
	{
		bool result = false;
		if (NULL != info) {
			const TiXmlNode* photoIdNode = info->FirstChild(LIVECHAT_PHOTOID);
			if (NULL != photoIdNode) {
				const TiXmlElement* itemElement = photoIdNode->ToElement();
				if (NULL != itemElement) {
					photoId = itemElement->GetText();
				}
			}

			const TiXmlNode* sendIdNode = info->FirstChild(LIVECHAT_SENDID);
			if (NULL != sendIdNode) {
				const TiXmlElement* itemElement = sendIdNode->ToElement();
				if (NULL != itemElement) {
					sendId = itemElement->GetText();
				}
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
