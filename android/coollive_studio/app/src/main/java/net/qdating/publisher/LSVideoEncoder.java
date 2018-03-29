package net.qdating.publisher;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

import android.annotation.SuppressLint;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaCodecList;
import android.media.MediaFormat;
import android.os.Build;
import android.util.Log;
import net.qdating.LSConfig;
import net.qdating.player.LSVideoHardDecoderFrame;

/**
 * 视频硬解码器
 * @author max
 *
 */
public class LSVideoEncoder implements ILSVideoEncoderJni {
	private static final String MIME_TYPE = "video/avc";    // H.264 Advanced Video Coding
	
	private static final int LSVIDEOFRAME_SZIE = 10;
	
	// 视频解码器
	private MediaCodec videoCodec = null;
	private MediaFormat videoMediaFormat = null;
	
	public MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();
	private LSVideoHardDecoderFrame unvalidVideoFrame = new LSVideoHardDecoderFrame();
	private LSVideoHardDecoderFrame videoFrames[] = new LSVideoHardDecoderFrame[LSVIDEOFRAME_SZIE];
	
	/**
	 * h264 start code
	 */
	private static byte sync_bytes[] = {0x0, 0x0, 0x0, 0x1};
	
	/**
	 * 测试输出
	 */
	private FileOutputStream videoFileStream = null;
	
	/**
	 * NALU头部长度
	 */
	private int naluHeaderSize = 4;
	
	@SuppressLint("NewApi")  
	/**
	 * 判断是否支持硬解码
	 * @return
	 */
	static public boolean supportAvcCodec() {  
        if( Build.VERSION.SDK_INT >= 18 ) {  
            for(int j = MediaCodecList.getCodecCount() - 1; j >= 0; j--){  
                MediaCodecInfo codecInfo = MediaCodecList.getCodecInfoAt(j);  
      
                String[] types = codecInfo.getSupportedTypes();
                for (int i = 0; i < types.length; i++) {  
                    if (types[i].equalsIgnoreCase(MIME_TYPE)) {  
                    	Log.i(LSConfig.TAG, String.format("LSVideoEncoder::supportAvcCodec()"));
                        return true;  
                    }  
                }  
            }  
        }  
        return false;  
    }
	
	public LSVideoEncoder() {
		for(int i = 0; i < LSVIDEOFRAME_SZIE; i++) {
			videoFrames[i] = new LSVideoHardDecoderFrame();
		}
	}

	@Override
	public boolean reset(int width, int height, int bitRate, int keyFrameInterval, int fps) {
		Log.i(LSConfig.TAG, String.format("LSVideoEncoder::reset()"));
		
		boolean bFlag = false;
		
		videoMediaFormat = MediaFormat.createVideoFormat(MIME_TYPE, LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT);
        videoMediaFormat.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, LSConfig.VIDEO_WIDTH * LSConfig.VIDEO_HEIGHT);
        videoMediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible);
//        videoMediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420SemiPlanar);
        
        videoMediaFormat.setInteger(MediaFormat.KEY_BIT_RATE, 125000);
        videoMediaFormat.setInteger(MediaFormat.KEY_FRAME_RATE, 20);
        videoMediaFormat.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 20);
        
        try {
			videoCodec = MediaCodec.createEncoderByType(MIME_TYPE);
			videoCodec.configure(videoMediaFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
			videoCodec.start();
			bFlag = true;
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			Log.i(LSConfig.TAG, String.format("LSVideoEncoder::reset( [Fail] )"));
			bFlag = false;
		}
        return bFlag;
	}
	
	@Override
	public void pause() {
		Log.i(LSConfig.TAG, String.format("LSVideoEncoder::pause()"));
		
		if( videoCodec != null ) {
			videoCodec.stop();
			videoCodec.release();
		}
	}
	
	@Override
	public boolean encodeVideoFrame(byte[] data, int size) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, 
				String.format("LSVideoEncoder::encodeVideoFrame( "
				+ "size : %d "
				+ ")", 
				size
				)
				);
		
		// 放到解码队列
		boolean bFlag = false;
		
		// 阻塞等待
		int inIndex = -1;
        inIndex = videoCodec.dequeueInputBuffer(-1);
        if ( inIndex >= 0 ) {
        	ByteBuffer[] inputBuffers = videoCodec.getInputBuffers();
            ByteBuffer buffer = inputBuffers[inIndex];
            buffer.clear();
            buffer.put(data, 0, size);
            
            // 放进硬编码器
            videoCodec.queueInputBuffer(inIndex, 0, buffer.position(), 0, 0/*MediaCodec.BUFFER_FLAG_CODEC_CONFIG*/);

            bFlag = true;
            
    		Log.i(LSConfig.TAG, 
    				String.format("LSVideoEncoder::encodeVideoFrame( "
    						+ "[Success], "
		    				+ "inIndex : %d "
		    				+ ")", 
		    				inIndex
		    				)
		    				);
        }
        
		return bFlag;
	}

	@Override
	public void releaseVideoFrame(int byteBufferIndex) {
		// TODO Auto-generated method stub
		// 释放帧
		Log.i(LSConfig.TAG, 
				String.format("LSVideoEncoder::releaseVideoFrame( "
						+ "byteBufferIndex : %d "
						+ ")",
						byteBufferIndex
						)
				);
		videoCodec.releaseOutputBuffer(byteBufferIndex, false);
	}
	
	@Override
	public LSVideoHardDecoderFrame getEncodeVideoFrame() {
		Log.i(LSConfig.TAG, 
				String.format("LSVideoEncoder::getDecodeVideoFrame("
				+ ")"
				)
				);
		
    	// 获取编码数据
		LSVideoHardDecoderFrame videoFrame = unvalidVideoFrame;
		int outIndex = -1;
				
		try {
			ByteBuffer[] outputBuffers = null;
	    	outIndex = videoCodec.dequeueOutputBuffer(bufferInfo, 0);
	    	
	        if (outIndex == MediaCodec.INFO_TRY_AGAIN_LATER) {
	            // no output available yet
	        } else if (outIndex == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
	            // The storage associated with the direct ByteBuffer may already be unmapped,
	            // so attempting to access data through the old output buffer array could
	            // lead to a native crash.
//	        	outputBuffers = videoCodec.getOutputBuffers();
	        	Log.d(LSConfig.TAG, String.format("LSVideoEncoder::getEncodeVideoFrame( [INFO_OUTPUT_BUFFERS_CHANGED] )"));
	        					
	        } else if (outIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
	            // this happens before the first frame is returned
	        	videoMediaFormat = videoCodec.getOutputFormat();
	        	Log.d(LSConfig.TAG, 
	        			String.format("LSVideoEncoder::getEncodeVideoFrame( "
	        					+ "[INFO_OUTPUT_FORMAT_CHANGED], "
	        					+ "outIndex : %d, "
	        					+ "videoMediaFormat : %s "
	        					+ ")", 
	        					outIndex,
	        					videoMediaFormat.toString()
	        					)
	        			);

	        } else if( outIndex >= 0 ) {	
	            outputBuffers = videoCodec.getOutputBuffers();
	            ByteBuffer byteBuffer = outputBuffers[outIndex];
	            
	            Log.i(LSConfig.TAG, String.format("LSVideoEncoder::getEncodeVideoFrame( "
	            		+ "outIndex : %d, "
	            		+ "timestamp : %d "
	            		+ ")", 
	            		outIndex, 
	            		bufferInfo.presentationTimeUs
	            		)
	            		);
	            
//	            videoFrame = videoFrames[outIndex];
//	            videoFrame.bufferIndex = outIndex;
	            videoFrame.timestamp = (int)bufferInfo.presentationTimeUs;
	            videoFrame.width = videoMediaFormat.getInteger(MediaFormat.KEY_WIDTH);
	            videoFrame.height = videoMediaFormat.getInteger(MediaFormat.KEY_HEIGHT);
	            
//	            if( videoFrame.data != null && byteBuffer.remaining() > videoFrame.data.length ) {
//	            	videoFrame.data = new byte[byteBuffer.remaining()];
//	            } else if( videoFrame.data == null ){
//	            	videoFrame.data = new byte[byteBuffer.remaining()];
//	            }
//	            
//	            videoFrame.size = byteBuffer.remaining();
//	            byteBuffer.get(videoFrame.data, 0, byteBuffer.remaining());
	            
	        } else {
	    		Log.i(LSConfig.TAG, String.format("LSVideoEncoder::getEncodeVideoFrame( "
	    				+ "[Unknow], "
	    				+ "outIndex : %d "
	    				+ ")", 
	    				outIndex)
	    				);
	        }
	        
		} catch(Exception e) {
			Log.i(LSConfig.TAG, String.format("LSVideoEncoder::getEncodeVideoFrame( "
					+ "[Exception], "
					+ "outIndex : %d, "
					+ "e : %s "
					+ ")", 
					outIndex,
					e.toString()
					)
					);
		}
		
        return videoFrame;
	}
}
