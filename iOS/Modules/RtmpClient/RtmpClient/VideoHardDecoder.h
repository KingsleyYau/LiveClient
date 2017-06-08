//
//  VideoHardDecoder.h
//  RtmpClient
//
//  Created by  Samson on 05/06/2017.
//  Copyright © 2017 net.qdating. All rights reserved.
//  视频硬解码实现类

#ifndef VideoHardDecoder_h
#define VideoHardDecoder_h

#include <rtmpdump/IDecoder.h>
#include <VideoToolbox/VideoToolbox.h>

class RtmpPlayer;
class VideoHardDecoder : public VideoDecoder {
public:
    VideoHardDecoder();
    virtual ~VideoHardDecoder();
        
// VideoDecoder
public:
    bool Create(RtmpPlayer* player);
    void Destroy();
    void DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength);
    void DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type);
    
private:
    // 硬解码callback
    static void DecodeOutputCallback (
                                     void* decompressionOutputRefCon,
                                     void* sourceFrameRefCon,
                                     OSStatus status,
                                     VTDecodeInfoFlags infoFlags,
                                     CVImageBufferRef imageBuffer,
                                     CMTime presentationTimeStamp,
                                     CMTime presentationDuration
                                     );
    // 硬解码回调
    void DecodeCallbackProc(void* frame, u_int32_t timestamp);
    
private:
    RtmpPlayer* mpPlayer;
    VTDecompressionSessionRef   mSession;
    CMFormatDescriptionRef      mFormatDesc;
};


#endif /* VideoHardDecoder_h */
