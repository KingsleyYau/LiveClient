/*
 * VideoDecoderH264.h
 *
 *  Created on: 2017年4月21日
 *      Author: max
 */

#ifndef RTMPDUMP_VIDEODECODERH264_H_
#define RTMPDUMP_VIDEODECODERH264_H_

#include "IDecoder.h"
#include <sys/types.h>

#include <string>

#include "VideoBuffer.h"
using namespace std;

struct AVCodec;
struct AVCodecContext;
struct AVFrame;

class VideoDecoderH264 : public VideoDecoder {
public:
	VideoDecoderH264();
	~VideoDecoderH264();

public:
	bool Create();
	void Destroy();

	VideoBuffer* GetBuffer();
	void ReleaseBuffer(VideoBuffer* decoderBuffer);

protected:
    void DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength);
    void DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type);

private:
    bool SetDecoderVideoFormat(VIDEO_FORMATE_TYPE type);
    bool DecodeVideoFrame(const char* data, int size, VideoBuffer* bufferFrame, VideoFrameType video_type);

	AVCodec *mCodec;
	AVCodecContext *mContext;

	int mGotPicture;
	int mLen;

    // 解码的格式
    int mDecoderFormat;

    // 剪切视频容器
    AVFrame *mCorpFrame;
    char *mCorpBuffer;

    EncodeDecodeBufferList mFreeBufferList;
    EncodeDecodeBufferList mFinishBufferList;

    VideoBuffer mSPS_PPS_IDR;
    VideoBuffer mSyncBuffer;

    // NALU头部大小
    int mNaluHeaderSize;

};

#endif /* RTMPDUMP_VIDEODECODERH264_H_ */
