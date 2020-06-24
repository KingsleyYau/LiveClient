//
//  VideoMuxer.h
//  RtmpClient
//
//  Created by Max on 2017/8/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoMuxer_h
#define VideoMuxer_h

#include <stdio.h>

#include <rtmpdump/video/VideoFrame.h>

namespace coollive {
class Slice {
  public:
    Slice();
    ~Slice();

    bool Parse(const char *sliceData, int sliceDataSize);
    const char *GetSlice();
    int GetSliceSize();
    bool IsFirstSlice();

  private:
    const char *mpSliceData;
    int mSliceSize;
};

class Nalu {
  public:
    Nalu();
    ~Nalu();

  public:
    bool Parse(const char *naluData, int naluDataSize, int naluHeaderSize);
    const char *GetNalu();
    int GetNaluSize();
    const char *GetNaluBody();
    int GetNaluBodySize();
    VideoFrameType GetNaluType();

    void GetSlices(Slice **sliceArray, int &sliceArraySize);

  private:
    bool ParseSlices();
    const char *FindSlice(const char *start, int size, int &sliceSize);

  private:
    const char *mpNaluData;
    int mNaluSize;
    int mNaluHeaderSize;

    Slice mSliceArray[16];
    int mSliceArraySize;
};

class VideoMuxer {
  public:
    VideoMuxer();
    ~VideoMuxer();

    bool GetNalus(const char *data, int size, int naluHeaderSize, Nalu *naluArray, int &naluArraysize);
};
}

#endif /* VideoMuxer_h */
