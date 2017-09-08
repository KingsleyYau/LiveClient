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

#include <common/KThread.h>

#include <rtmpdump/IDecoder.h>
#include <rtmpdump/util/EncodeDecodeBuffer.h>

namespace coollive {
class AudioFrame;
class AudioDecoderImp : public AudioDecoder {
public:
	AudioDecoderImp();
	virtual ~AudioDecoderImp();

	bool Create(AudioDecoderCallback* callback);
	bool Reset();
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
    bool Start();
    void Stop();

    void ReleaseBuffer(AudioFrame* audioFrame);
    
    EncodeDecodeBufferList mFreeBufferList;
    
    AudioDecoderCallback* mpCallback;

    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;
};
}
#endif /* RTMPDUMP_AUDIODECODERIMP_H_ */
