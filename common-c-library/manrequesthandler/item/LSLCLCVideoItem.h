/*
 * LSLCVideoItem.h
 *
 *  Created on: 2015-3-6
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCVideoItem_H_
#define LSLCVideoItem_H_

#include <string>
using namespace std;

#include <xml/tinyxml.h>

#include "../LSLiveChatRequestLiveChatDefine.h"

class LSLCVideoItem {
public:
	void Parse(TiXmlNode* node) {
		const char *p = NULL;
		TiXmlElement* itemElement;

		// 视频ID
		TiXmlNode* videoidNode = node->FirstChild(LC_RECENT_VIDEO_VIDEOID);
		if( videoidNode != NULL ) {
			itemElement = videoidNode->ToElement();
			if ( itemElement != NULL ) {
				p = itemElement->GetText();
				if( p != NULL ) {
					videoid = p;
				}
			}
		}

		// 视频标题
		TiXmlNode* titleNode = node->FirstChild(LC_RECENT_VIDEO_TITLE);
		if( titleNode != NULL ) {
			itemElement = titleNode->ToElement();
			if ( itemElement != NULL ) {
				p = itemElement->GetText();
				if( p != NULL ) {
					title = p;
				}
			}
		}

		// 邀请ID
		TiXmlNode* inviteidNode = node->FirstChild(LC_RECENT_VIDEO_INVITEID);
		if( inviteidNode != NULL ) {
			itemElement = inviteidNode->ToElement();
			if ( itemElement != NULL ) {
				p = itemElement->GetText();
				if( p != NULL ) {
					inviteid = p;
				}
			}
		}

		// 视频url
		TiXmlNode* video_urlNode = node->FirstChild(LC_RECENT_VIDEO_VIDEO_URL);
		if( video_urlNode != NULL ) {
			itemElement = video_urlNode->ToElement();
			if ( itemElement != NULL ) {
				p = itemElement->GetText();
				if( p != NULL ) {
					video_url = p;
				}
			}
		}
	}

	/**
	 * 微视频列表结构体
	 * @param videoid			视频ID
	 * @param title				视频标题
	 * @param inviteid			邀请ID
	 * @param video_url			视频url
	 */
	LSLCVideoItem() {
		videoid = "";
		title = "";
		inviteid = "";
		video_url = "";
	}

	virtual ~LSLCVideoItem() {

	}

	string videoid;
	string title;
	string inviteid;
	string video_url;
};

#endif /* LCVIDEOITEM_H_ */
