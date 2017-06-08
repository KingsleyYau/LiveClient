/*
 * AudioDecoderAAC.h
 * Des:	音频AAC解码器
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#ifndef RTMPDUMP_AUDIODECODERAAC_H_
#define RTMPDUMP_AUDIODECODERAAC_H_

#include "IDecoder.h"
#include <sys/types.h>

#include <string>

#include "EncodeDecodeBuffer.h"
using namespace std;

struct AVCodec;
struct AVCodecContext;
struct AVFrame;

class AudioDecoderAAC : public AudioDecoder {
public:
	AudioDecoderAAC();
	virtual ~AudioDecoderAAC();

	bool Create();
	void Destroy();

	EncodeDecodeBuffer* GetBuffer();
	void ReleaseBuffer(EncodeDecodeBuffer* decoderBuffer);

public:
    void CreateAudioDecoder(
    		AudioFrameFormat format,
			AudioFrameSoundRate sound_rate,
			AudioFrameSoundSize sound_size,
			AudioFrameSoundType sound_type
			);

    void DecodeAudioFrame(
    		AudioFrameFormat format,
			AudioFrameSoundRate sound_rate,
			AudioFrameSoundSize sound_size,
			AudioFrameSoundType sound_type,
			const char* data,
			int size,
			u_int32_t timestamp
			);

private:
    bool DecodeAudioFrame(const char* data, int size, EncodeDecodeBuffer* bufferFrame);

	AVCodec *mCodec;
	AVCodecContext *mContext;
	AVFrame* mDecodeFrame;

    EncodeDecodeBufferList mFreeBufferList;
    EncodeDecodeBufferList mFinishBufferList;

    string mFilePath;
};

#endif /* RTMPDUMP_AUDIODECODERAAC_H_ */
