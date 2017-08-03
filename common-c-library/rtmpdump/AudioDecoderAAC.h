/*
 * AudioDecoderAAC.h
 * Des:	音频AAC解码器
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#ifndef RTMPDUMP_AUDIODECODERAAC_H_
#define RTMPDUMP_AUDIODECODERAAC_H_

#include <sys/types.h>

#include <string>
using namespace std;

#include <rtmpdump/IDecoder.h>
#include <rtmpdump/AudioFrame.h>

struct AVCodec;
struct AVCodecContext;
struct AVFrame;

namespace coollive {
class RtmpPlayer;
class AudioDecoderAAC : public AudioDecoder {
public:
	AudioDecoderAAC();
	virtual ~AudioDecoderAAC();

	bool Create(AudioDecoderCallback* callback);
	void Pause();
    void DecodeAudioFormat(
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
    void ReleaseAudioFrame(void* frame);
    
private:
    bool CreateContext();
    void DestroyContext();
    void ReleaseBuffer(AudioFrame* audioFrame);
    
    bool DecodeAudioFrame(const char* data, int size, AudioFrame* bufferFrame);

	AVCodec *mCodec;
	AVCodecContext *mContext;
	AVFrame* mDecodeFrame;

    EncodeDecodeBufferList mFreeBufferList;

    string mFilePath;
    
    AudioDecoderCallback* mpCallback;
};
}
#endif /* RTMPDUMP_AUDIODECODERAAC_H_ */
