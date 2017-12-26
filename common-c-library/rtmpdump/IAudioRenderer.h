//
//  IAudioRenderer.h
//  RtmpClient
//
//  Created by Max on 2017/6/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef IAudioRenderer_h
#define IAudioRenderer_h

namespace coollive {
    class AudioRenderer {
    public:
        virtual ~AudioRenderer(){};
        virtual void RenderAudioFrame(void* audioFrame) = 0;
        virtual bool Start() = 0;
        virtual void Stop() = 0;
        virtual void Reset() = 0;
    };
}

#endif /* IAudioRenderer_h */
