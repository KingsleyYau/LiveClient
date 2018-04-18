//
//  VideoRecorderH264.h
//  RtmpClient
//
//  Created by Max on 2017/8/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoH264Recorder_h
#define VideoH264Recorder_h

#include <rtmpdump/video/VideoMuxer.h>

#include <stdio.h>

#include <string>
using namespace std;

namespace coollive {
class VideoRecorderH264 {
public:
    VideoRecorderH264();
    ~VideoRecorderH264();
    
    bool Start(const string& filePath);
    void Stop();
    
    bool RecordVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int naluHeaderSize);
    bool RecordVideoFrame(const char* data, int size);
    bool RecordVideoNaluFrame(const char* data, int size);
    
private:
    string mFilePath;
    FILE* mpFile;
    
    int mNaluHeaderSize;
    
    VideoMuxer mVideoMuxer;
};
}

#endif /* VideoH264Recorder_h */
