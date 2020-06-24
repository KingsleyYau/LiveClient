/*
 * AudioEncoderAAC.h
 *
 *  Created on: 2017年8月9日
 *      Author: max
 */

#ifndef RTMPDUMP_AUDIOENCODERAAC_H_
#define RTMPDUMP_AUDIOENCODERAAC_H_

#include <string>
using namespace std;

#include <common/KThread.h>

#include <rtmpdump/IEncoder.h>

#include <rtmpdump/audio/AudioFrame.h>

struct AVCodec;
struct AVCodecContext;
struct AVFrame;
class SwrContext;

namespace coollive {

class EncodeAudioRunnable;
class AudioEncoderAAC : public AudioEncoder {
  public:
    AudioEncoderAAC();
    virtual ~AudioEncoderAAC();

  public:
    bool Create(int sampleRate, int channelsPerFrame, int bitPerSample);
    void SetCallback(AudioEncoderCallback *callback);
    bool Reset();
    void Pause();
    void EncodeAudioFrame(void *data, int size, void *frame);

  private:
    bool Start();
    void Stop();
    void ReleaseAudioFrame(AudioFrame *audioFrame);
    bool EncodeAudioFrame(AudioFrame *srcFrame, AudioFrame *dstFrame);

  private:
    bool CreateContext();
    void DestroyContext();
    void ClearAudioFrame();

  private:
    AudioEncoderCallback *mpCallback;

    // 参数
    int mSampleRate;
    int mBitPerSample;
    int mChannelsPerFrame;
    int mSamplesPerChannel;

    // 编码器句柄
    AVCodec *mCodec;
    AVCodecContext *mContext;

    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;

    // 当前采样帧数
    int mPts;

    // 空闲帧队列
    EncodeDecodeBufferList mFreeBufferList;

    // 等待编码队列
    EncodeDecodeBufferList mEncodeBufferList;

    // 编码线程实现体
    friend class EncodeAudioRunnable;
    EncodeAudioRunnable *mpEncodeAudioRunnable;
    void EncodeAudioHandle();

    // 编码线程
    KThread mEncodeAudioThread;
};

} /* namespace coollive */

#endif /* RTMPDUMP_AUDIOENCODERAAC_H_ */
