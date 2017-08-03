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

#include "EncodeDecodeBuffer.h"
#include "ICodec.h"

namespace coollive {
class AudioFrame : public EncodeDecodeBuffer
{
public:
    AudioFrame();
    ~AudioFrame();
    
    void ResetFrame();
    
public:
    AudioFrameFormat mFormat;
    AudioFrameSoundRate mSoundRate;
    AudioFrameSoundSize mSoundSize;
    AudioFrameSoundType mSoundType;
};
}

#endif /* AudioFrame_h */
