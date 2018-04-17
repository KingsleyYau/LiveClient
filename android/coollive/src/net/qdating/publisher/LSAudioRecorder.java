package net.qdating.publisher;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import net.qdating.LSConfig;
import net.qdating.utils.Log;

public class LSAudioRecorder {
	private AudioRecord audioRecorder = null;
    private Thread recordingThread = null;
    private boolean recording = false;
    private byte[] audioBuffer;
    private ILSAudioRecorderCallback recorderCallback;
    
    public LSAudioRecorder() {
		// TODO Auto-generated constructor stub
	}
    
	public boolean init(ILSAudioRecorderCallback callback) {
		boolean bFlag = false;
		
		Log.d(LSConfig.TAG, String.format("LSAudioRecorder::init( this : 0x%x )", hashCode()));
		
		this.recorderCallback = callback;
		
        int sampleRateInHz = LSConfig.SAMPLE_RATE;
        int channelConfig = (LSConfig.CHANNEL_PER_FRAME==2)?AudioFormat.CHANNEL_IN_STEREO:AudioFormat.CHANNEL_IN_MONO;
        int audioFormat = (LSConfig.BIT_PER_SAMPLE==16)?AudioFormat.ENCODING_PCM_16BIT:AudioFormat.ENCODING_PCM_8BIT;
        int bufferSizeInBytes = AudioRecord.getMinBufferSize(sampleRateInHz, channelConfig, audioFormat);
        if( bufferSizeInBytes > 0 ) {
            audioBuffer = new byte[bufferSizeInBytes];
            
    		audioRecorder = new AudioRecord(
    				MediaRecorder.AudioSource.MIC,
    				sampleRateInHz, 
    				channelConfig,
    				audioFormat, 
    				bufferSizeInBytes
    				);

    		if( audioRecorder != null ) {
    			bFlag = true;
    		}
        }
		
		return bFlag;
	}
	
	public void uninit() {
		Log.d(LSConfig.TAG, String.format("LSAudioRecorder::uninit( this : 0x%x )", hashCode()));

		if( audioRecorder != null ) {
			audioRecorder.release();
			audioRecorder = null;
		}
	}
	
	public boolean start() {
		boolean bFlag = true;
		
		if( audioRecorder != null ) {
			audioRecorder.startRecording();
			recording = true;
			
			recordingThread = new Thread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					int bufferRead = 0;
					int samplePerFrame = 1024;
					int frameSize = LSConfig.BIT_PER_SAMPLE / 8 * samplePerFrame;
					while( recording ) {
						bufferRead = audioRecorder.read(audioBuffer, 0, frameSize);
						if( bufferRead > 0 ) {
//							Log.d(LSConfig.TAG, String.format("LSAudioRecorder::start( [Record Buffer], size : %d )", bufferRead));
							if( recorderCallback != null ) {
								recorderCallback.onAudioRecord(audioBuffer, bufferRead);
							}
						}
					}
				}
			});
			recordingThread.start();
			
			bFlag = true;
		}

		Log.d(LSConfig.TAG, String.format("LSAudioRecorder::start( this : 0x%x, [%s] )", hashCode(), bFlag?"Success":"Fail"));
		
		return bFlag;
	}
	
	public void stop() {
		Log.d(LSConfig.TAG, String.format("LSAudioRecorder::stop( this : 0x%x )", hashCode()));
		
		recording = false;
		
		if( audioRecorder != null ) {
			try{
				audioRecorder.stop();
			}catch(Exception e){
				e.printStackTrace();
			}
		}
	}
}
