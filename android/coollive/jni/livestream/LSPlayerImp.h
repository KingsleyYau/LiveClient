/*
 * LSPlayerImp.h
 *
 *  Created on: 2017年6月19日
 *      Author: max
 */

#ifndef LIVESTREAM_LSPLAYERIMP_H_
#define LIVESTREAM_LSPLAYERIMP_H_

#include <rtmpdump/PlayerController.h>

#include <rtmpdump/android/VideoHardDecoder.h>
#include <rtmpdump/android/VideoHardRendererImp.h>

#include <rtmpdump/android/VideoRendererImp.h>
#include <rtmpdump/android/AudioRendererImp.h>

#include <rtmpdump/VideoDecoderH264.h>
#include <rtmpdump/AudioDecoderAAC.h>

using namespace coollive;
class LSPlayerImp : public PlayerStatusCallback {
public:
	LSPlayerImp(jobject jniCallback, jobject jniVideoRenderer, jobject jniAudioRenderer, jobject jniVideoDecoder);
	virtual ~LSPlayerImp();

	void Destroy();
	bool PlayUrl(const string& url, const string& recordFilePath, const string& recordH264FilePath, const string& recordAACFilePath);
	void Stop();
	void SetUseHardDecoder(bool useHardDecoder);

private:
	void OnPlayerDisconnect(PlayerController* pc);

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
	jobject mJniVideoDecoder;

	bool mUseHardDecoder;
};

#endif /* LIVESTREAM_LSPLAYERIMP_H_ */
