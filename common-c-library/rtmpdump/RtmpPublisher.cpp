//
//  RtmpPublisher.cpp
//  RtmpClient
//
//  Created by Max on 2017/4/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "RtmpPublisher.h"

RtmpPublisher::RtmpPublisher() {
	mpRtmpPublisherCallback = NULL;
	mpVideoEncoder = NULL;
	mpAudioEncoder = NULL;
    mRtmpDump.SetCallback(this);
}

RtmpPublisher::~RtmpPublisher() {
}

bool RtmpPublisher::PublishUrl(const string& url, const string& recordH264FilePath, const string& recordAACFilePath) {
    return mRtmpDump.PublishUrl(url, recordH264FilePath, recordAACFilePath);
}

void RtmpPublisher::Stop() {
    mRtmpDump.Stop();
}

RtmpPublisherCallback* RtmpPublisher::GetCallback() {
	return mpRtmpPublisherCallback;
}

void RtmpPublisher::SetCallback(RtmpPublisherCallback* callback) {
	mpRtmpPublisherCallback = callback;
}

void RtmpPublisher::SetVideoEncoder(VideoEncoder* encoder) {
    mpVideoEncoder = encoder;
}

VideoEncoder* RtmpPublisher::GetVideoEncoder() {
	return mpVideoEncoder;
}

void RtmpPublisher::SetAudioEncoder(AudioEncoder* encoder) {
	mpAudioEncoder = encoder;
}

AudioEncoder* RtmpPublisher::GetAudioEncoder() {
	return mpAudioEncoder;
}

bool RtmpPublisher::SendVideoFrame(char* frame, int frame_size) {
    return mRtmpDump.SendVideoFrame(frame, frame_size);
}

void RtmpPublisher::AddVideoTimestamp(u_int32_t timestamp) {
    mRtmpDump.AddVideoTimestamp(timestamp);
}

bool RtmpPublisher::SendAudioFrame(
                                   AudioFrameFormat sound_format,
                                   AudioFrameSoundRate sound_rate,
                                   AudioFrameSoundSize sound_size,
                                   AudioFrameSoundType sound_type,
                                   char* frame,
                                   int frame_size
                                   ) {
    return mRtmpDump.SendAudioFrame(sound_format, sound_rate, sound_size, sound_type, frame, frame_size);
}

void RtmpPublisher::AddAudioTimestamp(u_int32_t timestamp) {
    mRtmpDump.AddAudioTimestamp(timestamp);
}

void RtmpPublisher::OnDisconnect(RtmpDump* rtmpDump) {
    if( mpRtmpPublisherCallback ) {
        mpRtmpPublisherCallback->OnDisconnect(this);
    }
}

void RtmpPublisher::OnChangeVideoSpsPps(RtmpDump* rtmpDump, const char* sps, int sps_size, const char* pps, int pps_size, int NALUnitHeaderLength) {

}

void RtmpPublisher::OnRecvVideoFrame(RtmpDump* rtmpDump, const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {

}

void RtmpPublisher::OnChangeAudioFormat(RtmpDump* rtmpDump,
                                        AudioFrameFormat format,
                                        AudioFrameSoundRate sound_rate,
                                        AudioFrameSoundSize sound_size,
                                        AudioFrameSoundType sound_type
                                        ) {

}

void RtmpPublisher::OnRecvAudioFrame(
                                  RtmpDump* rtmpDump,
                                  AudioFrameFormat format,
                                  AudioFrameSoundRate sound_rate,
                                  AudioFrameSoundSize sound_size,
                                  AudioFrameSoundType sound_type,
                                  char* data,
                                  int size,
                                  u_int32_t timestamp
                                  ) {

}
