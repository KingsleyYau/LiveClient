package net.qdating.player;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Stack;

import android.annotation.SuppressLint;
import android.media.Image;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaCodecInfo.CodecCapabilities;
import android.media.MediaCodecList;
import android.media.MediaFormat;
import android.os.Build;
import android.util.Log;
import net.qdating.LSConfig;

/**
 * 视频硬解码器
 * @author max
 *
 */
public class LSVideoHardDecoder implements ILSVideoHardDecoderJni {
	// H.264 Advanced Video Coding
	private static final String MIME_TYPE = "video/avc";    
	
	// 视频解码器
	private MediaCodec videoCodec = null;
	private MediaFormat videoMediaFormat = null;
	
	public MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();
	private Stack<LSVideoHardDecoderFrame> videoFrameStack = null;
	
	/**
	 * h264 start code
	 */
	private static byte sync_bytes[] = {0x0, 0x0, 0x0, 0x1};
	
	/**
	 * NALU头部长度
	 */
	private int naluHeaderSize = 4;

	@SuppressLint("NewApi")  
	/**
	 * 判断是否支持硬解码
	 * @return
	 */
	static public boolean supportHardDecoder() {  
		boolean bFlag = false;
		
        if( Build.VERSION.SDK_INT >= 21 ) {
        	MediaCodecList codecList = new MediaCodecList(MediaCodecList.REGULAR_CODECS);
        	MediaCodecInfo[] codecInfos = codecList.getCodecInfos();
        	for(int i = 0; i < codecInfos.length; i++) {  
        		MediaCodecInfo codecInfo = codecInfos[i];
        		String[] supportTypes = codecInfo.getSupportedTypes();  
        		for (int j = 0; j < supportTypes.length; j++) {
        			if( LSConfig.debug ) {
	        			Log.d(LSConfig.TAG, 
	        					String.format("LSVideoHardDecoder::supportHardDecoder( "
	        							+ "codecName : [%s], "
	        							+ "codecType : [%s] "
	        							+ ")", 
	        							codecInfo.getName(), 
	        							supportTypes[j])
	        					);
        			}
        			
        			if( supportTypes[j].equalsIgnoreCase(MIME_TYPE) ) {  
        				bFlag = true;
                        Log.d(LSConfig.TAG,
                                String.format("LSVideoHardDecoder::supportHardDecoder( " +
                                                "[Find hard decoder], "
                                                + "codecName : [%s], "
                                                + "codecType : [%s] "
                                                + ")",
                                        codecInfo.getName(),
                                        supportTypes[j])
                        );
        				break;
        			}
        		}
        	}
        }  
        
        return bFlag;  
    }
	
	public LSVideoHardDecoder() {
	}
	
	public boolean init() {
		boolean bFlag = false;

		Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::init()"));

		videoFrameStack = new Stack<LSVideoHardDecoderFrame>();
		for(int i = 0; i < LSConfig.VIDEO_DECODE_FRAME_COUNT; i++) {
			LSVideoHardDecoderFrame videoFrame = new LSVideoHardDecoderFrame();
			videoFrameStack.push(videoFrame);
		}
		
		videoMediaFormat = MediaFormat.createVideoFormat(MIME_TYPE, LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT);
        videoMediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Planar);

        try {
			videoCodec = MediaCodec.createDecoderByType(MIME_TYPE);
			if( videoCodec != null ) {
				videoCodec.configure(videoMediaFormat, null, null, 0);
				videoCodec.start();
				
				Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::init( codecName : %s, mimeType : %s )", videoCodec.getName(), MIME_TYPE));
				
				CodecCapabilities caps = videoCodec.getCodecInfo().getCapabilitiesForType(MIME_TYPE);
			    for(int i = 0; i < caps.colorFormats.length; i++) {
			    	Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::init( colorFormat : 0x%x )", caps.colorFormats[i]));
			    }
				
				bFlag = true;
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			bFlag = false;
			
			Log.e(LSConfig.TAG, String.format("LSVideoHardDecoder::init( [Fail], error : %s )", e.toString()));
		}
        
        return bFlag;
	}
	
	public void uninit() {
		Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::uninit()"));

		if( videoCodec != null ) {
			videoCodec.stop();
			videoCodec.release();
		}

		synchronized (this) {
			if (videoFrameStack != null) {
				videoFrameStack.clear();
				videoFrameStack = null;
			}
		}
	}
	
	@Override
	public boolean decodeVideoKeyFrame(byte[] sps, int sps_size, byte[] pps, int pps_size, int naluHeaderSize) {
		Log.d(LSConfig.TAG,
				String.format("LSVideoHardDecoder::decodeVideoKeyFrame( "
				+ "sps_size : %d, "
				+ "pps_size : %d, "
				+ "naluHeaderSize : %d "
				+ ")",
				sps_size,
				pps_size,
				naluHeaderSize
				)
				);
		
		boolean bFlag = false;
		
		this.naluHeaderSize = naluHeaderSize;
		
		// Maybe cause getDecodeVideoFrame exception, ignore it. 
		// if not flush codec, it will cause crash when video size is increased
		videoCodec.flush();
		
        bFlag = decodeFrame(sps, 0, sps_size, 0);
        bFlag = bFlag && decodeFrame(pps, 0, pps_size, 0);
		
        return bFlag;
	}
	
	@Override
	public boolean decodeVideoFrame(byte[] data, int size, int timestamp) {
		// TODO Auto-generated method stub
		
		// 放到解码队列
		return decodeFrame(data, this.naluHeaderSize, size, timestamp);
	}

	private boolean decodeFrame(byte[] data, int offset, int size, int timestamp) {
		boolean bFlag = false;
		
		// 阻塞等待
		int inIndex = -1;
        inIndex = videoCodec.dequeueInputBuffer(-1);
        
        if( LSConfig.debug ) {
    		Log.d(LSConfig.TAG,
    				String.format("LSVideoHardDecoder::decodeFrame( "
    				+ "inIndex : %d, "
    				+ "size : %d, "
    				+ "timestamp : %d "
    				+ ")",
    				inIndex,
    				size,
    				timestamp
    				)
    				);
        }
		
        if ( inIndex >= 0 ) {
        	ByteBuffer[] inputBuffers = videoCodec.getInputBuffers();
            ByteBuffer buffer = inputBuffers[inIndex];
            buffer.clear();
            buffer.put(sync_bytes);
            buffer.put(data, offset, size - offset);
            
            // 放进硬解码器
            videoCodec.queueInputBuffer(inIndex, 0, buffer.position(), timestamp, 0/*MediaCodec.BUFFER_FLAG_CODEC_CONFIG*/);

            bFlag = true;
        }
      
        return bFlag;
	}

	@Override
	public void releaseVideoFrame(LSVideoHardDecoderFrame videoFrame) {
		// TODO Auto-generated method stub
		if( videoFrame != null ) {
			synchronized (this) {
				videoFrameStack.push(videoFrame);
			}
		}
	}
	
	@Override
	public LSVideoHardDecoderFrame getDecodeVideoFrame() {
    	// 获取解码数据
		LSVideoHardDecoderFrame videoFrame = null;
		int bufferIndex = -1;

		boolean bFlag = false;

		try {
			long timeoutUs = 500 * 1000;
	    	bufferIndex = videoCodec.dequeueOutputBuffer(bufferInfo, timeoutUs);
	    	
	        if (bufferIndex == MediaCodec.INFO_TRY_AGAIN_LATER) {
	            // no output available yet
	        } else if (bufferIndex == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
	            // The storage associated with the direct ByteBuffer may already be unmapped,
	            // so attempting to access data through the old output buffer array could
	            // lead to a native crash.
//	        	Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::getDecodeVideoFrame( [INFO_OUTPUT_BUFFERS_CHANGED] )"));
//	        	outputBuffers = videoCodec.getOutputBuffers();
	        					
	        } else if (bufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
	            // this happens before the first frame is returned
	        	videoMediaFormat = videoCodec.getOutputFormat();
	        	Log.i(LSConfig.TAG, 
	        			String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
	        					+ "[INFO_OUTPUT_FORMAT_CHANGED], "
	        					+ "videoMediaFormat : %s "
	        					+ ")", 
	        					videoMediaFormat.toString()
	        					)
	        			);
	        } else if( bufferIndex >= 0 ) {	
	        	synchronized (this) {
		            if( videoFrameStack.isEmpty() ) {
		            	videoFrame = new LSVideoHardDecoderFrame();
			        	Log.d(LSConfig.TAG,
			        			String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
			        					+ "[New videoFrame is created], "
			        					+ "videoFrame : 0x%x "
			        					+ ")", 
			        					videoFrame.hashCode()
			        					)
			        			);
		            } else {
		            	videoFrame = videoFrameStack.pop();
		            }
				}

	            videoFrame.timestamp = (int)bufferInfo.presentationTimeUs;
	            Image image = videoCodec.getOutputImage(bufferIndex);
	            if( image != null ) {
					videoFrame.updateImage(image);
					bFlag = true;
				} else {
					Log.d(LSConfig.TAG,
							String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
											+ "[Fail, image is null], "
											+ "bufferIndex : %d "
											+ ")",
									bufferIndex
							)
					);
				}
                videoCodec.releaseOutputBuffer(bufferIndex, false);

	        } else {
	    		Log.d(LSConfig.TAG,
	    				String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
	    				+ "[Fail, unknow], "
	    				+ "bufferIndex : %d "
	    				+ ")", 
	    				bufferIndex
	    				)
	    				);
	        }
	        
		} catch(Exception e) {
			Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
					+ "[Fail, exception], "
					+ "bufferIndex : %d, "
					+ "e : %s "
					+ ")", 
					bufferIndex,
					e.toString()
					)
					);
		}

		if( !bFlag ) {
			if( videoFrame != null ) {
				videoFrameStack.push(videoFrame);
				videoFrame = null;
			}
		}
		
        return videoFrame;
	}
}
