/*
 * AudioDecoderImp.h
 * Des:	音频AAC解码器
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#ifndef RTMPDUMP_AUDIODECODERIMP_H_
#define RTMPDUMP_AUDIODECODERIMP_H_

#include <sys/types.h>

#include <string>
using namespace std;

#include <rtmpdump/IDecoder.h>
#include <rtmpdump/AudioFrame.h>

namespace coollive {
class RtmpPlayer;
class AudioDecoderImp : public AudioDecoder {
public:
	AudioDecoderImp();
	virtual ~AudioDecoderImp();

	bool Create(AudioDecoderCallback* callback);
	void Destroy();
    void Reset();
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
    void ReleaseBuffer(AudioFrame* audioFrame);
    
    EncodeDecodeBufferList mFreeBufferList;
    
    AudioDecoderCallback* mpCallback;
};
}
#endif /* RTMPDUMP_AUDIODECODERIMP_H_ */
