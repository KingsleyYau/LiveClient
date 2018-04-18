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

#include <rtmpdump/video/VideoFrame.h>
#include <rtmpdump/video/VideoMuxer.h>

#include <common/KMutex.h>

#include <VideoToolbox/VideoToolbox.h>

namespace coollive {
class RtmpPlayer;
class VideoHardDecoder : public VideoDecoder {
public:
    VideoHardDecoder();
    virtual ~VideoHardDecoder();
        
// VideoDecoder
public:
    bool Create(VideoDecoderCallback* callback);
    bool Reset();
    void Pause();
    void ResetStream();
    void DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int naluHeaderSize);
    void DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type);
    void ReleaseVideoFrame(void* frame);
    void StartDropFrame();
    
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
    void ResetParam();
    bool CreateContext();
    void DestroyContext();
    char* FindSlice(char* start, int size, int& sliceSize);
    
private:
    VideoDecoderCallback* mpCallback;
    
    dispatch_queue_t mVideoDecodeQueue;
    VTDecompressionSessionRef   mSession;
    CMFormatDescriptionRef      mFormatDesc;
    
    // 解码器变量
    char* mpSps;
    int mSpSize;
    char* mpPps;
    int mPpsSize;
    int mNaluHeaderSize;
    
    // 状态锁
    KMutex mRuningMutex;
    int mInputIndex;
    
    VideoFrame mVideoDecodeFrame;
    
    VideoMuxer mVideoMuxer;
};
}

#endif /* VideoHardDecoder_h */
