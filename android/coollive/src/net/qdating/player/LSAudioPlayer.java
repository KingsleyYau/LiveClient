package net.qdating.player;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.util.Log;
import net.qdating.LSConfig;

/***
 * 音频播放器
 * @author max
 *
 */
public class LSAudioPlayer implements ILSAudioRendererJni {
	private AudioTrack audioTrack = null;
	
	public LSAudioPlayer() {
		
	}
	
	/**
	 * 音频格式改变
	 * @param sampleRate		采样率
	 * @param channelPerFrame	声道
	 * @param bitPerSample		精度
	 * @return
	 */
	public boolean changeAudioFormat(int sampleRate, int channelPerFrame, int bitPerSample) {
		boolean bFlag = false;
		
		if( audioTrack == null ) {
	        int sampleRateInHz = sampleRate;
	        int channelConfig = (channelPerFrame==2)?AudioFormat.CHANNEL_OUT_STEREO:AudioFormat.CHANNEL_OUT_MONO;
	        int audioFormat = (bitPerSample==16)?AudioFormat.ENCODING_PCM_16BIT:AudioFormat.ENCODING_PCM_8BIT;
			int bufferSizeInBytes = AudioTrack.getMinBufferSize(sampleRateInHz,	channelConfig, audioFormat);
			
			Log.d(LSConfig.TAG, 
					String.format("LSAudioPlayer:changeAudioFormat( "
					+ "sampleRateInHz : %d, "
					+ "channelPerFrame : %d, "
					+ "channelConfig : %d, "
					+ "bitPerSample : %d, "
					+ "audioFormat : %d, "
					+ "bufferSizeInBytes : %d "
					+ ")", 
					sampleRateInHz,
					channelPerFrame,
					channelConfig,
					bitPerSample,
					audioFormat,
					bufferSizeInBytes
					)
					);
			
			audioTrack = new AudioTrack(
					AudioManager.STREAM_MUSIC,
					sampleRateInHz,
					channelConfig,
					audioFormat,
	                bufferSizeInBytes, 
	                AudioTrack.MODE_STREAM
	                );
			
			if( audioTrack != null ) {
				audioTrack.play();
			}
		}
		
		return bFlag;
	}
	
	/**
	 * 停止播放
	 */
	public void stop() {
		if( audioTrack != null ) {
			audioTrack.stop();
			audioTrack = null;
		}
	}
	
	/**
	 * 播放一个音频帧
	 * @param data
	 */
	public void playAudioFrame(byte[] data) {
//		Log.d(LSConfig.TAG, String.format("LSAudioPlayer:playAudioFrame( size : %d )", data.length));
		if( audioTrack != null ) {
			audioTrack.write(data, 0, data.length);
		}
	}

	@Override
	public void renderAudioFrame(byte[] data, int sampleRate, int channelPerFrame, int bitPerSample) {
		// TODO Auto-generated method stub
		changeAudioFormat(sampleRate, channelPerFrame, bitPerSample);
		playAudioFrame(data);
	}

	@Override
	public void reset() {
		// TODO Auto-generated method stub
//		Log.d(LSConfig.TAG, String.format("LSAudioPlayer:reset()"));

		if( audioTrack != null ) {
			audioTrack.pause();
			audioTrack.flush();
			audioTrack.play();
		}
	}
	
}
