/*
 * LSPlayerImp.h
 *
 *  Created on: 2017年6月19日
 *      Author: max
 */

#ifndef COOLLIVE_LSPLAYERIMP_H_
#define COOLLIVE_LSPLAYERIMP_H_

#include <rtmpdump/PlayerController.h>

#include <rtmpdump/android/VideoHardDecoder.h>
#include <rtmpdump/android/VideoHardRendererImp.h>

#include <rtmpdump/android/VideoRendererImp.h>
#include <rtmpdump/android/AudioRendererImp.h>

#include <rtmpdump/video/VideoDecoderH264.h>
#include <rtmpdump/audio/AudioDecoderAAC.h>

using namespace coollive;
class LSPlayerImp : public PlayerStatusCallback {
public:
	LSPlayerImp(jobject jniCallback, jboolean useHardDecoder, jobject jniVideoRenderer, jobject jniAudioRenderer, jobject jniVideoHardDecoder, jobject jniVideoHardRenderer);
	virtual ~LSPlayerImp();

	void Destroy();
	bool PlayUrl(const string& url, const string& recordFilePath, const string& recordH264FilePath, const string& recordAACFilePath);
	void Stop();
	void SetUseHardDecoder(bool useHardDecoder);

private:
	void OnPlayerConnect(PlayerController* pc);
	void OnPlayerDisconnect(PlayerController* pc);
	void OnPlayerOnDelayMaxTime(PlayerController* pc);

private:
	void CreateDecoders();
	void DestroyDecoders();

private:
	PlayerController mPlayer;
	VideoDecoder* mpVideoDecoder;
	AudioDecoder* mpAudioDecoder;
	VideoRenderer* mpVideoRenderer;
	AudioRenderer* mpAudioRenderer;

	jobject mJniCallback;
	jobject mJniVideoRenderer;
	jobject mJniAudioRenderer;
	jobject mJniVideoHardDecoder;
	jobject mJniVideoHardRenderer;

	bool mUseHardDecoder;
};

#endif /* COOLLIVE_LSPLAYERIMP_H_ */
