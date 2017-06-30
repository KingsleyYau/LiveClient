//
//  Statistics.h
//  RtmpClient
//  统计流播放信息类
//  Created by Max on 2017/6/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef Statistics_h
#define Statistics_h

#include <stdio.h>

#include <rtmpdump/IVideoRenderer.h>
#include <rtmpdump/RtmpPlayer.h>
#include <rtmpdump/FrameBuffer.h>

namespace coollive {
    
class Statistics {
public:
    Statistics();
    ~Statistics();
    
    void SetVideoDecoder(VideoDecoder* decoder);
    void SetRtmpPlayer(RtmpPlayer* player);
    
    /**
     是否需要丢弃视频帧

     @return <#return value description#>
     */
    bool IsDropVideoFrame();
    
private:
    unsigned int mLastVideoCacheMS;
    bool mDecrease;
    
    VideoDecoder* mpDecoder;
    RtmpPlayer* mpPlayer;
};
    
}
#endif /* Statistics_h */
