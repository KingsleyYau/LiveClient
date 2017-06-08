/*
 * AudioEncoderAAC.h
 * Des:	音频AAC编码器
 *
 *  Created on: 2017年5月9日
 *      Author: max
 */

#ifndef RTMPDUMP_AUDIOENCODERAAC_H_
#define RTMPDUMP_AUDIOENCODERAAC_H_

#include "IEncoder.h"
#include "EncodeDecodeBuffer.h"

class AVCodec;
class AVCodecContext;
class SwrContext;
class AudioEncoderAAC : public AudioEncoder {
public:
	AudioEncoderAAC();
	virtual ~AudioEncoderAAC();

    bool Create(int sampleRate, int channelsPerFrame, int bitPerSample);
    void Destroy();
    void EncodeAudioFrame(const char* data, int size, u_int32_t timestamp);

    EncodeDecodeBuffer* GetBuffer();
	void ReleaseBuffer(EncodeDecodeBuffer* decoderBuffer);

private:
    bool EncodeAudioFrame(const char* data, int size, EncodeDecodeBuffer* bufferFrame);

    static bool CheckBitPerSample(AVCodec *codec, int fmt);
    static int SelectSampleRate(AVCodec *codec);
    static int SelectChannelLayout(AVCodec *codec);

private:
	AVCodec *mCodec;
	AVCodecContext *mContext;
	SwrContext *mSwrCtx;

	uint8_t **mSrcData;
	uint8_t	**mDstData;

    EncodeDecodeBufferList mFreeBufferList;
    EncodeDecodeBufferList mFinishBufferList;
};

#endif /* RTMPDUMP_AUDIOENCODERAAC_H_ */
