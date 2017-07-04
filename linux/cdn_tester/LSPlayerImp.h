/*
 * LSPlayerImp.h
 *
 *  Created on: 2017年6月19日
 *      Author: max
 */

#ifndef LIVESTREAM_LSPLAYERIMP_H_
#define LIVESTREAM_LSPLAYERIMP_H_

#include <common/KMutex.h>

#include <rtmpdump/PlayerController.h>

#include <rtmpdump/VideoDecoderH264.h>
#include <rtmpdump/AudioDecoderAAC.h>

using namespace coollive;
class LSPlayerImp : public PlayerStatusCallback {
public:
	LSPlayerImp();
	virtual ~LSPlayerImp();

	void Destroy();
	bool PlayUrl(const string& url, const string& recordFilePath, const string& recordH264FilePath, const string& recordAACFilePath);
	void Stop();

	bool IsRuning();

private:
	void OnPlayerDisconnect(PlayerController* pc);

private:
	void CreateDecoders();
	void DestroyDecoders();

private:
	PlayerController mPlayer;
	VideoDecoder* mpVideoDecoder;
	AudioDecoder* mpAudioDecoder;

	KMutex mKmutex;
	bool mIsRunning;
};

#endif /* LIVESTREAM_LSPLAYERIMP_H_ */
