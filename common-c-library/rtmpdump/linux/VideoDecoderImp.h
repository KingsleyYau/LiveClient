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
#include <rtmpdump/VideoFrame.h>

namespace coollive {
class VideoFrame;
class RtmpPlayer;
class VideoDecoderImp : public VideoDecoder {
public:
	VideoDecoderImp();
	~VideoDecoderImp();

public:
	bool Create(VideoDecoderCallback* callback);
    void Reset();
	void Pause();
    void ResetStream();
    void DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength);
    void DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type);
    void ReleaseVideoFrame(void* frame);
    void StartDropFrame();
    
protected:
    void ReleaseBuffer(VideoFrame* decoderBuffer);

private:
    void Stop();
    
    // 空闲Buffer
    EncodeDecodeBufferList mFreeBufferList;
    
    // 解码完成回调
    VideoDecoderCallback* mpCallback;
    
};
}
#endif /* RTMPDUMP_VIDEODECODERIMP_H_ */
