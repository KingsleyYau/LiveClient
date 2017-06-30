package net.qdating;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.AudioTrack;
import android.media.MediaRecorder;

/**
 * 音频录制
 * @author max
 *
 */
public class LSAudioRecorder {
	/**
	 * 录制设备
	 */
	private AudioRecord audioRecord; 
	
	/**
	 * 解码线程
	 */
	private Thread recordThread;
	
	/**
	 * 是否录制
	 */
	private boolean running = false;
	
	/**
	 * 缓冲Buffer
	 */
	private byte[] audioBuffer;

	LSAudioRecorder() {
	}
	
	void init(int sampleRate, int channelPerFrame, int bitPerSample) {
        int sampleRateInHz = sampleRate;
        int channelConfig = (channelPerFrame==2)?AudioFormat.CHANNEL_IN_STEREO:AudioFormat.CHANNEL_IN_MONO ;
        int audioFormat = (bitPerSample==16)?AudioFormat.ENCODING_PCM_16BIT:AudioFormat.ENCODING_PCM_8BIT;
        
        int bufferSizeInBytes = AudioTrack.getMinBufferSize(sampleRateInHz, channelConfig, audioFormat);// 4096;
        audioBuffer = new byte[bufferSizeInBytes];
        
        audioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, sampleRateInHz, channelConfig, audioFormat, bufferSizeInBytes);

	}
	
	void startRecording() {
        if( audioRecord != null ) {
        	audioRecord.startRecording();
        	
        	running = true;
        	
        	// 开线程循环获取
        	recordThread = new Thread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					while( running ) {
						int bufferRead = audioRecord.read(audioBuffer, 0, audioBuffer.length);
						if( bufferRead > 0 ) {
						}
					}
				}
        	});
        	recordThread.start();
        }
	}
	
	void stopRecording() {
		running = false;
		
        if( audioRecord != null ) {
        	audioRecord.stop();
        }
	}
	
}
