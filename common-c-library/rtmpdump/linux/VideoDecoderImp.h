/*
 * VideoDecoderImp.h
 *
 *  Created on: 2017年4月21日
 *      Author: max
 */

#ifndef RTMPDUMP_VIDEODECODERIMP_H_
#define RTMPDUMP_VIDEODECODERIMP_H_

#include <sys/types.h>

#include <string>
using namespace std;

#include <common/KThread.h>

#include <rtmpdump/IDecoder.h>
#include <rtmpdump/util/EncodeDecodeBuffer.h>

namespace coollive {
class VideoFrame;
class VideoDecoderImp : public VideoDecoder {
public:
	VideoDecoderImp();
	~VideoDecoderImp();

public:
	bool Create(VideoDecoderCallback* callback);
    bool Reset();
	void Pause();
    void ResetStream();
    void DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int naluHeaderSize);
    void DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type);
    void ReleaseVideoFrame(void* frame);
    void StartDropFrame();
    
protected:
    void ReleaseBuffer(VideoFrame* decoderBuffer);

private:
    bool Start();
    void Stop();
    
    // 空闲Buffer
    EncodeDecodeBufferList mFreeBufferList;
    
    // 解码完成回调
    VideoDecoderCallback* mpCallback;
    
    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;
};
}
#endif /* RTMPDUMP_VIDEODECODERIMP_H_ */
