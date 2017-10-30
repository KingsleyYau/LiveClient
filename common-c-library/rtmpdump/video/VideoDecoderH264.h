/*
 * VideoDecoderH264.h
 *
 *  Created on: 2017年4月21日
 *      Author: max
 */

#ifndef RTMPDUMP_VIDEODECODERH264_H_
#define RTMPDUMP_VIDEODECODERH264_H_

#include <rtmpdump/IDecoder.h>

#include <rtmpdump/video/VideoFrame.h>
#include <rtmpdump/video/VideoFormatConverter.h>
#include <rtmpdump/video/VideoMuxer.h>

#include <common/KThread.h>

#include <sys/types.h>

#include <string>
using namespace std;

struct AVCodec;
struct AVCodecContext;
struct AVFrame;
struct SwsContext;

namespace coollive {
class VideoFrame;
class DecodeVideoRunnable;
class ConvertVideoRunnable;
class VideoDecoderH264 : public VideoDecoder {
public:
	VideoDecoderH264();
	~VideoDecoderH264();
    static void GobalInit();
    
public:
	bool Create(VideoDecoderCallback* callback);
    bool Reset();
	void Pause();
    void ResetStream();
    void DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength);
    void DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type);
    void ReleaseVideoFrame(void* frame);
    void StartDropFrame();
    
public:
    void SetDecoderVideoFormat(VIDEO_FORMATE_TYPE type);
  
protected:
    bool Start();
    void Stop();
    
private:
    bool CreateContext();
    void DestroyContext();
    bool DecodeVideoFrame(VideoFrame* videoFrame, VideoFrame* newVideoFrame);
    void ReleaseBuffer(VideoFrame* videoFrame);
    
	AVCodec *mCodec;
	AVCodecContext *mContext;

	int mGotPicture;
	int mLen;

    // 解码的格式
    int mDecoderFormat;

    // 剪切视频容器
    AVFrame *mCorpFrame;
    char *mCorpBuffer;

    // NALU头部大小
    int mNaluHeaderSize;
    
    // 关键帧参数
    VideoFrame mSPS_PPS_IDR;
    VideoFrame mSyncBuffer;
    VideoFrame mDataBuffer;
    
    // 解码线程实现体
    friend class DecodeVideoRunnable;
    void DecodeVideoHandle();
    
    // 空闲Buffer
    EncodeDecodeBufferList mFreeBufferList;
    // 待解码Buffer
    EncodeDecodeBufferList mDecodeBufferList;
    
    // 解码线程
    KThread mDecodeVideoThread;
    DecodeVideoRunnable* mpDecodeVideoRunnable;
    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;
    
    KMutex mDropFrameMutex;
    bool mbDropFrame;
    bool mbWaitForInterFrame;
    
    // 是否允许丢帧
    bool mbCanDropFrame;
    
    // 解码完成回调
    VideoDecoderCallback* mpCallback;

private:
    // 格式转换线程实现体
    friend class ConvertVideoRunnable;
    void ConvertVideoHandle();
    
    // 显示格式转换
    VideoFormatConverter mVideoFormatConverter;
    // 待格式转换Buffer
    EncodeDecodeBufferList mConvertBufferList;
    // 式转换线程
    KThread mConvertVideoThread;
    ConvertVideoRunnable* mpConvertVideoRunnable;
    // H264格式转换器
    VideoMuxer mVideoMuxer;
};
}
#endif /* RTMPDUMP_VIDEODECODERH264_H_ */
