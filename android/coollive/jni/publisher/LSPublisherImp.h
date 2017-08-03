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

#include <rtmpdump/android/VideoHardEncoder.h>

#include <rtmpdump/VideoEncoderH264.h>
//#include <rtmpdump/AudioEncoderAAC.h>

using namespace coollive;
class LSPublisherImp : public PublisherStatusCallback {
public:
	LSPublisherImp(jobject jniCallback, jobject jniVideoEncoder, int width, int height, int bitRate, int keyFrameInterval, int fps);
	virtual ~LSPublisherImp();

	void Destroy();
	bool PublishUrl(const string& url, const string& recordH264FilePath, const string& recordAACFilePath);
	void Stop();
	void SetUseHardEncoder(bool useHardEncoder);
    void PushVideoFrame(void* data, int size);

private:
    void OnPublisherConnect(PublisherController* pc);
    void OnPublisherDisconnect(PublisherController* pc);

private:
	void CreateEncoders();
	void DestroyEncoders();

private:
	PublisherController mPublisher;
	VideoEncoder* mpVideoEncoder;
	AudioEncoder* mpAudioEncoder;

	/**
	 * Java回调
	 */
	jobject mJniCallback;
	/**
	 * Java视频硬编码器
	 */
	jobject mJniVideoEncoder;

	/**
	 * 是否使用硬编码
	 */
	bool mUseHardEncoder;
};

#endif /* COOLLIVE_LSPUBLISHERIMP_H_ */
