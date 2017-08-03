//
//  VideoHardEncoder.h
//  RtmpClient
//
//  Created by Max on 2017/7/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoHardEncoder_h
#define VideoHardEncoder_h

#include <stdio.h>

#include <rtmpdump/IEncoder.h>
#include <rtmpdump/VideoFrame.h>

#include <VideoToolbox/VideoToolbox.h>
#include <CoreFoundation/CoreFoundation.h>

namespace coollive {
class VideoHardEncoder : public VideoEncoder {
public:
    VideoHardEncoder();
    virtual ~VideoHardEncoder();
    
public:
    bool Create(VideoEncoderCallback* callback, int width, int height, int bitRate, int keyFrameInterval, int fps);
    bool Reset();
    void Pause();
    void EncodeVideoFrame(void* data, int size, void* frame);
    
private:
    static void VideoCompressionOutputCallback(
                                               void *outputCallbackRefCon,
                                               void *sourceFrameRefCon,
                                               OSStatus status,
                                               VTEncodeInfoFlags infoFlags,
                                               CMSampleBufferRef sampleBuffer
                                               );
 
private:
    bool CreateContext();
    void DestroyContext();
    
private:
    VideoEncoderCallback* mpCallback;
    
    int mWidth;
    int mHeight;
    int mBitRate;
    int mKeyFrameInterval;
    int mFPS;
    
    dispatch_queue_t mVideoEncodeQueue;
    VTCompressionSessionRef mVideoCompressionSession;
    VideoFrame mVideoEncodeFrame;
    
    int mEncodeFrameCount;
    double mLastPresentationTime;
    UInt32 mEncodeStartTimestamp;
    
};
}
#endif /* VideoHardEncoder_h */
