//
//  AudioFrame.h
//  Camshare
//
//  Created on: 2017-03-27
//      Author: Samson
// Description: 用于存放音频解码后的1帧数据
//

#ifndef AudioFrame_h
#define AudioFrame_h

#include <rtmpdump/ICodec.h>

#include <rtmpdump/util/EncodeDecodeBuffer.h>

#define DEFAULT_AUDIO_BUFFER_COUNT 50
#define DEFAULT_AUDIO_BUFFER_MAX_COUNT 300
#define DEFAULT_AUDIO_BUFFER_SIZE 1024 * 8

struct AVFrame;

namespace coollive {
class AudioFrame : public EncodeDecodeBuffer {
  public:
    AudioFrame();
    ~AudioFrame();

    AudioFrame(const AudioFrame &item);
    AudioFrame &operator=(const AudioFrame &item);

    void ResetFrame();
    void InitFrame(AudioFrameFormat format, AudioFrameSoundRate rate, AudioFrameSoundSize size, AudioFrameSoundType channel);

  public:
    AudioFrameFormat mSoundFormat;
    AudioFrameSoundRate mSoundRate;
    AudioFrameSoundSize mSoundSize;
    AudioFrameSoundType mSoundType;

    AVFrame *mpAVFrame;
};
}

#endif /* AudioFrame_h */
