package net.qdating.player;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Handler;
import android.os.Message;

import net.qdating.utils.Log;
import net.qdating.LSConfig;

import java.util.Arrays;

/***
 * 音频播放器
 * @author max
 *
 */
public class LSAudioPlayer implements ILSAudioRendererJni {
	private AudioTrack audioTrack = null;

	/**
	 * 主线程消息处理
	 */
	private Handler handler = null;
	/**
	 * 状态锁
	 */
	private Object statusLock = new Object();
	private boolean isRunning = false;
	/**
	 * 是否静音
	 */
	private boolean isMute = false;

	public LSAudioPlayer() {
		handler = new Handler() {
			@Override
			public void handleMessage(Message msg) {
				if (audioTrack != null) {
					audioTrack.pause();
					audioTrack.flush();
					audioTrack.play();
				}

				Log.d(LSConfig.TAG, String.format("LSAudioPlayer:handleMessage( " +
								"this : 0x%x, " +
								"[Reset success] " +
								")",
						(msg.obj!=null)?msg.obj.hashCode():0
				));

				synchronized (statusLock) {
					isRunning = true;
				}
			}
		};
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

		if (audioTrack == null) {
			int sampleRateInHz = sampleRate;
			int channelConfig = (channelPerFrame == 2) ? AudioFormat.CHANNEL_OUT_STEREO : AudioFormat.CHANNEL_OUT_MONO;
			int audioFormat = (bitPerSample == 16) ? AudioFormat.ENCODING_PCM_16BIT : AudioFormat.ENCODING_PCM_8BIT;
			int bufferSizeInBytes = AudioTrack.getMinBufferSize(sampleRateInHz, channelConfig, audioFormat);

			Log.d(LSConfig.TAG,
					String.format("LSAudioPlayer:changeAudioFormat( "
									+ "this : 0x%x, "
									+ "sampleRateInHz : %d, "
									+ "channelPerFrame : %d, "
									+ "channelConfig : %d, "
									+ "bitPerSample : %d, "
									+ "audioFormat : %d, "
									+ "bufferSizeInBytes : %d "
									+ ")",
							hashCode(),
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

			if (audioTrack != null) {
				audioTrack.play();

				synchronized (statusLock) {
					isRunning = true;
				}
			}

		}

		return bFlag;
	}
	
	/**
	 * 停止播放
	 */
	public void stop() {
		Log.d(LSConfig.TAG, String.format("LSAudioPlayer:stop( this : 0x%x )", hashCode()));
		if (audioTrack != null) {
			audioTrack.stop();
			audioTrack = null;
		}
	}

	/**
	 * 当前是否静音
	 * @return
	 */
	public boolean getMute() {
		return isMute;
	}

	/**
	 * 设置是否静音
	 * @param isMute 是否静音
	 */
	public void setMute(boolean isMute) {
		Log.d(LSConfig.TAG, String.format("LSAudioPlayer::setMute( this : 0x%x, %s )", hashCode(), Boolean.toString(isMute)));
		this.isMute = isMute;
	}

	/**
	 * 播放一个音频帧
	 * @param data
	 */
	public void playAudioFrame(byte[] data) {
//		Log.d(LSConfig.TAG, String.format("LSAudioPlayer:playAudioFrame( size : %d )", data.length));
		synchronized (statusLock) {
			if( isRunning ) {
				if( !isMute ) {
					audioTrack.write(data, 0, data.length);
				} else {
					Arrays.fill(data, (byte)0);
					audioTrack.write(data, 0, data.length);
				}
			}
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
		Log.d(LSConfig.TAG, String.format("LSAudioPlayer:reset( this : 0x%x )", hashCode()));
		synchronized (statusLock) {
			if( isRunning ) {
				isRunning = false;
				Message msg = Message.obtain();
				msg.obj = this;
				handler.sendMessage(msg);
			}
		}
	}
	
}
