/*
 * VideoEncoderH264.h
 *
 *  Created on: 2017年5月8日
 *      Author: max
 */

#ifndef RTMPDUMP_VIDEOENCODERH264_H_
#define RTMPDUMP_VIDEOENCODERH264_H_

#include "IEncoder.h"

#include <sys/types.h>

#include <string>
using namespace std;

#include "VideoBuffer.h"

struct AVCodec;
struct AVCodecContext;
struct AVFrame;

class VideoEncoderH264 : public VideoEncoder {
public:
	VideoEncoderH264();
	virtual ~VideoEncoderH264();

	bool Create(int width, int height, int frameInterval, int bitRate, int keyFrameInterval);
	void Destroy();
	void EncodeVideoFrame(const char* data, int size, u_int32_t timestamp);

	void ReleaseBuffer(VideoBuffer* decoderBuffer);

private:
	bool EncodeVideoFrame(const char* data, int size, VideoBuffer* bufferFrame);

private:
	AVCodec *mCodec;
	AVCodecContext *mContext;

    // 解码的格式
    int mDecoderFormat;

    EncodeDecodeBufferList mFreeBufferList;
};

#endif /* RTMPDUMP_VIDEOENCODERH264_H_ */
