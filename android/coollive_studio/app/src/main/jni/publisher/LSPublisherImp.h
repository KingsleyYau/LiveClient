/*
 * LSPUBLISHERIMP.h
 *
 *  Created on: 2017年6月19日
 *      Author: max
 */

#ifndef COOLLIVE_LSPUBLISHERIMP_H_
#define COOLLIVE_LSPUBLISHERIMP_H_

#include <AndroidCommon/JniCommonFunc.h>

#include <rtmpdump/PublisherController.h>

#include <rtmpdump/IEncoder.h>
#include <rtmpdump/IDecoder.h>
#include <rtmpdump/IVideoRenderer.h>

#include <rtmpdump/video/VideoFormatConverter.h>
#include <rtmpdump/video/VideoFilters.h>
#include <rtmpdump/video/VideoRotateFilter.h>

using namespace coollive;
class LSPublisherImp : public PublisherStatusCallback {
public:
	LSPublisherImp(jobject jniCallback, jboolean useHardEncoder, jobject jniVideoEncoder, int width, int height, int bitRate, int keyFrameInterval, int fps);
	virtual ~LSPublisherImp();

	void Destroy();
	bool PublishUrl(const string& url, const string& recordH264FilePath, const string& recordAACFilePath);
	void Stop();
	void SetUseHardEncoder(bool useHardEncoder);
    void PushVideoFrame(void* data, int size, int width, int height);
    void PausePushVideo();
    void ResumePushVideo();
    void PushAudioFrame(void* data, int size);
    void ChangeVideoRotate(int rotate);

private:
    void OnPublisherConnect(PublisherController* pc);
    void OnPublisherDisconnect(PublisherController* pc);

private:
    void OnFilterVideoFrame(VideoFilters* filters, VideoFrame* videoFrame);

private:
	void CreateEncoders();
	void DestroyEncoders();

private:
	PublisherController mPublisher;
	VideoEncoder* mpVideoEncoder;
	AudioEncoder* mpAudioEncoder;

	jobject mJniCallback;
	jobject mJniVideoEncoder;

	// 是否使用硬编码
	bool mUseHardEncoder;

    // 视频参数
    int mWidth;
    int mHeight;
    int mBitRate;
    int mKeyFrameInterval;
    int mFPS;

    // 音频参数
    int mSampleRate;
    int mChannelsPerFrame;
    int mBitPerSample;

    KMutex mPublisherMutex;
};

#endif /* COOLLIVE_LSPUBLISHERIMP_H_ */
