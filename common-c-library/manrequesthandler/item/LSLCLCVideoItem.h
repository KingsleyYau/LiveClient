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
	void Parse(Json::Value root) {

        if (root.isObject()) {
            
            // 视频ID
            if (root[LC_RECENT_VIDEO_VIDEOID].isString()) {
                videoid = root[LC_RECENT_VIDEO_VIDEOID].asString();
            }
            
            // 视频标题
            if (root[LC_RECENT_VIDEO_TITLE].isString()) {
                title = root[LC_RECENT_VIDEO_TITLE].asString();
            }
            
            // 邀请ID
            if (root[LC_RECENT_VIDEO_INVITEID].isString()) {
                inviteid = root[LC_RECENT_VIDEO_INVITEID].asString();
            }
            // 视频url
            if (root[LC_RECENT_VIDEO_VIDEO_URL].isString()) {
                video_url = root[LC_RECENT_VIDEO_VIDEO_URL].asString();
            }
            // 视频url
            if (root[LC_RECENT_VIDEO_VIDEO_COVER].isString()) {
                videoCover = root[LC_RECENT_VIDEO_VIDEO_COVER].asString();
            }
        }

	}

	/**
	 * 微视频列表结构体
	 * @param videoid			视频ID
	 * @param title				视频标题
	 * @param inviteid			邀请ID
	 * @param video_url			视频url
     * @param videoCover        视频图片（对应《12.14.获取微视频图片》的“大图”）
	 */
	LSLCVideoItem() {
		videoid = "";
		title = "";
		inviteid = "";
		video_url = "";
        videoCover = "";
	}

	virtual ~LSLCVideoItem() {

	}

	string videoid;
	string title;
	string inviteid;
	string video_url;
    string videoCover;
};

#endif /* LCVIDEOITEM_H_ */
