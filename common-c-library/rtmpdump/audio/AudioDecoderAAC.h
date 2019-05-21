/*
 * AudioDecoderAAC.h
 * Des:	音频AAC解码器
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#ifndef RTMPDUMP_AUDIODECODERAAC_H_
#define RTMPDUMP_AUDIODECODERAAC_H_

#include <rtmpdump/IDecoder.h>

#include <rtmpdump/audio/AudioFrame.h>
#include <rtmpdump/audio/AudioMuxer.h>

#include <common/KThread.h>

#include <sys/types.h>

#include <string>
using namespace std;

struct AVCodec;
struct AVCodecContext;
struct AVFrame;

namespace coollive {
class DecodeAudioRunnable;
class AudioDecoderAAC : public AudioDecoder {
public:
	AudioDecoderAAC();
	virtual ~AudioDecoderAAC();

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
    void ClearAudioFrame();
    
private:
    bool Start();
    void Stop();
    
    bool CreateContext();
    void DestroyContext();
    
    bool DecodeAudioFrame(AudioFrame* audioFrame, AudioFrame* newAudioFrame);

	AVCodec *mCodec;
	AVCodecContext *mContext;

    AudioDecoderCallback* mpCallback;
    // 容器格式化
    AudioMuxer mAudioMuxer;
    
    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;
    
    // 空闲队列
    EncodeDecodeBufferList mFreeBufferList;
    // 等待解码队列
    EncodeDecodeBufferList mDecodeBufferList;
    
    // 解码线程实现体
    friend class DecodeAudioRunnable;
    DecodeAudioRunnable* mpDecodeAudioRunnable;
    void DecodeAudioHandle();
    
    // 解码线程
    KThread mDecodeAudioThread;
    
};
}
#endif /* RTMPDUMP_AUDIODECODERAAC_H_ */
