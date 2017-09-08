/*
 * LSPlayerImp.cpp
 *
 *  Created on: 2017年6月19日
 *      Author: max
 */

#include <LSPlayerImp.h>

LSPlayerImp::LSPlayerImp()
:mKmutex(KMutex::MutexType_Recursive) {
	// TODO Auto-generated constructor stub
	mIsRunning = false;

	mPlayer.SetStatusCallback(this);
	mPlayer.SetCacheMS(5000);

	CreateDecoders();
}

LSPlayerImp::~LSPlayerImp() {
	// TODO Auto-generated destructor stub
	DestroyDecoders();
}

bool LSPlayerImp::PlayUrl(const string& url, const string& recordFilePath, const string& recordH264FilePath, const string& recordAACFilePath) {
	bool bFlag = false;

	FileLog("rtmpdump",
			"LSPlayerImp::PlayUrl( "
			"url : %s "
			")",
			url.c_str()
			);

	bFlag = mPlayer.PlayUrl(url, recordFilePath, recordH264FilePath, recordAACFilePath);
	if( bFlag ) {
		mKmutex.lock();
		mIsRunning = true;
		mKmutex.unlock();
	} else {
		Stop();
	}

	FileLog("rtmpdump",
			"LSPlayerImp::PlayUrl( "
			"[Finish], "
			"url : %s, "
			"bFlag : %s "
			")",
			url.c_str(),
			bFlag?"true":"false"
			);

	return bFlag;
}

void LSPlayerImp::Stop() {
	FileLog("rtmpdump",
			"LSPlayerImp::Stop("
			")"
			);

	mPlayer.Stop();
}

bool LSPlayerImp::IsRuning() {
	return mIsRunning;
}

void LSPlayerImp::CreateDecoders() {
	FileLog("rtmpdump",
			"LSPlayerImp::CreateDecoders( "
			"player : %p "
			")",
			this
			);

	// 软解码
//	VideoDecoderH264* videoDecoder = new VideoDecoderH264();
//	videoDecoder->SetDecoderVideoFormat(VIDEO_FORMATE_RGB565);
//	AudioDecoderAAC* audioDecoder = new AudioDecoderAAC();

	// 不解码
	VideoDecoderImp* videoDecoder = new VideoDecoderImp();
	AudioDecoderImp* audioDecoder = new AudioDecoderImp();

	mpAudioDecoder = audioDecoder;
	mpVideoDecoder = videoDecoder;

	mPlayer.SetVideoDecoder(mpVideoDecoder);
	mPlayer.SetAudioDecoder(mpAudioDecoder);

	FileLog("rtmpdump",
			"LSPlayerImp::CreateDecoders( "
			"[Success], "
			"player : %p, "
			"mpVideoDecoder : %p, "
			"mpAudioDecoder : %p "
			")",
			this,
			mpVideoDecoder,
			mpAudioDecoder
			);
}

void LSPlayerImp::DestroyDecoders() {
	FileLog("rtmpdump",
			"LSPlayerImp::DestroyDecoders( "
			"player : %p "
			")",
			this
			);

	if( mpVideoDecoder ) {
		delete mpVideoDecoder;
		mpVideoDecoder = NULL;
	}

	if( mpAudioDecoder ) {
		delete mpAudioDecoder;
		mpAudioDecoder = NULL;
	}
}

void LSPlayerImp::OnPlayerDisconnect(PlayerController* pc) {
	FileLog("rtmpdump",
			"LSPlayerImp::OnPlayerDisconnect( "
			"player : %p "
			")",
			this
			);

	mKmutex.lock();
	mIsRunning = false;
	mKmutex.unlock();
}
