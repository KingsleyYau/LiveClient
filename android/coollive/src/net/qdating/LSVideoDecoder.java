package net.qdating;

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

/**
 * 视频硬解码器
 * @author max
 *
 */
public class LSVideoDecoder implements ILSVideoDecoderJni {
	private static final String MIME_TYPE = "video/avc";    // H.264 Advanced Video Coding
	
	private static final int LSVIDEOFRAME_SZIE = 10;
	
	// 视频解码器
	private MediaCodec videoCodec = null;
	private MediaFormat videoMediaFormat = null;
	
	public MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();
	private LSVideoFrame unvalidVideoFrame = new LSVideoFrame();
	private LSVideoFrame videoFrames[] = new LSVideoFrame[LSVIDEOFRAME_SZIE];
	
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
	static public boolean SupportAvcCodec() {  
        if( Build.VERSION.SDK_INT >= 18 ) {  
            for(int j = MediaCodecList.getCodecCount() - 1; j >= 0; j--){  
                MediaCodecInfo codecInfo = MediaCodecList.getCodecInfoAt(j);  
      
                String[] types = codecInfo.getSupportedTypes();  
                for (int i = 0; i < types.length; i++) {  
                    if (types[i].equalsIgnoreCase(MIME_TYPE)) {  
                        return true;  
                    }  
                }  
            }  
        }  
        return false;  
    }
	
	public LSVideoDecoder() {
		for(int i = 0; i < LSVIDEOFRAME_SZIE; i++) {
			videoFrames[i] = new LSVideoFrame();
		}
		
		videoMediaFormat = MediaFormat.createVideoFormat(MIME_TYPE, LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT);
        videoMediaFormat.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, LSConfig.VIDEO_WIDTH * LSConfig.VIDEO_HEIGHT);
        videoMediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible);
        
        try {
			videoCodec = MediaCodec.createDecoderByType(MIME_TYPE);
			videoCodec.configure(videoMediaFormat, null, null, 0);
			videoCodec.start();
			
			Log.i(LSConfig.TAG, String.format("LSVideoDecoder::LSVideoDecoder( [Success] )"));
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			Log.i(LSConfig.TAG, String.format("LSVideoDecoder::LSVideoDecoder( [Fail] )"));
		}
        
	}
	
	@Override
	public boolean decodeVideoKeyFrame(byte[] sps, int sps_size, byte[] pps, int pps_size, int naluHeaderSize) {
		Log.i(LSConfig.TAG, String.format("LSVideoDecoder::decodeVideoKeyFrame( "
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
		
		try {
			videoFileStream = new FileOutputStream("/sdcard/livestream/play_hard_decode.h264");
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

        try {
        	videoFileStream.write(sync_bytes);
			videoFileStream.write(sps, 0, sps_size);
			videoFileStream.write(sync_bytes);
			videoFileStream.write(pps, 0, pps_size);
			videoFileStream.flush();
			
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
        
//        if( videoCodec != null ) {
//        	videoCodec.stop();
//        	videoCodec.release();
//        	videoCodec = null;
//        }
//        
//        try {
//    		videoMediaFormat = MediaFormat.createVideoFormat(MIME_TYPE, LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT);
//            videoMediaFormat.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, LSConfig.VIDEO_WIDTH * LSConfig.VIDEO_HEIGHT);
//            
//			videoCodec = MediaCodec.createDecoderByType(MIME_TYPE);
//			videoCodec.configure(videoMediaFormat, null, null, 0);
//			videoCodec.start();
//			
//			// 解码SPS/PPS
//			bFlag = decodeFrame(sps, 0, sps_size, 0);
//			bFlag = bFlag && decodeFrame(pps, 0, pps_size, 0);
//			
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//			Log.i(LSConfig.TAG, String.format("LSVideoDecoder::decodeVideoKeyFrame( [Fail] )"));
//		}
        
        bFlag = decodeFrame(sps, 0, sps_size, 0);
        bFlag = bFlag && decodeFrame(pps, 0, pps_size, 0);
        
		Log.i(LSConfig.TAG, String.format("LSVideoDecoder::decodeVideoKeyFrame( "
				+ "sps_size : %d, "
				+ "pps_size : %d, "
				+ "naluHeaderSize : %d, "
				+ "bFlag : %s "
				+ ")", 
				sps_size, 
				pps_size,
				naluHeaderSize,
				bFlag?"true":"false"
				)
				);
		
        return bFlag;
	}
	
	@Override
	public boolean decodeVideoFrame(byte[] data, int size, int timestamp) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, 
				String.format("LSVideoDecoder::decodeVideoFrame( "
				+ "size : %d, "
				+ "timestamp : %d "
				+ ")", 
				size, 
				timestamp
				)
				);
		
		// 放到解码队列
		return decodeFrame(data, this.naluHeaderSize, size, timestamp);

	}

	private boolean decodeFrame(byte[] data, int offset, int size, int timestamp) {
		boolean bFlag = false;
		
		// 阻塞等待
		int inIndex = -1;
        inIndex = videoCodec.dequeueInputBuffer(-1);
        
		Log.i(LSConfig.TAG, 
				String.format("LSVideoDecoder::decodeFrame( "
				+ "inIndex : %d "
				+ ")", 
				inIndex
				)
				);
		
        if ( inIndex >= 0 ) {
        	ByteBuffer[] inputBuffers = videoCodec.getInputBuffers();
            ByteBuffer buffer = inputBuffers[inIndex];
            buffer.clear();
            buffer.put(sync_bytes);
            buffer.put(data, offset, size - offset);
            
            // 记录到文件
            try {
            	videoFileStream.write(sync_bytes);
    			videoFileStream.write(data, 4, size - 4);
    			videoFileStream.flush();
    			
    		} catch (IOException e1) {
    			// TODO Auto-generated catch block
    			e1.printStackTrace();
    		}
            
            // 放进硬解码器
            videoCodec.queueInputBuffer(inIndex, 0, buffer.position(), timestamp, 0/*MediaCodec.BUFFER_FLAG_CODEC_CONFIG*/);

            bFlag = true;
            
    		Log.i(LSConfig.TAG, 
    				String.format("LSVideoDecoder::decodeFrame( [Success], "
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
				String.format("LSVideoDecoder::releaseVideoFrame( "
						+ "byteBufferIndex : %d "
						+ ")",
						byteBufferIndex
						)
				);
		videoCodec.releaseOutputBuffer(byteBufferIndex, false);
	}
	
	@Override
	public LSVideoFrame getDecodeVideoFrame() {
//		Log.i(LSConfig.TAG, 
//				String.format("LSVideoDecoder::getDecodeVideoFrame("
//				+ ")"
//				)
//				);
		
    	// 获取解码数据
		LSVideoFrame videoFrame = unvalidVideoFrame;
		int outIndex = -1;
				
		try {
			ByteBuffer[] outputBuffers = null;
	    	outIndex = videoCodec.dequeueOutputBuffer(bufferInfo, 0);
	    	
	        if (outIndex == MediaCodec.INFO_TRY_AGAIN_LATER) {
	            // no output available yet
//	            if (VERBOSE) Log.d(TAG, "no output from decoder available");
	        } else if (outIndex == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
	            // The storage associated with the direct ByteBuffer may already be unmapped,
	            // so attempting to access data through the old output buffer array could
	            // lead to a native crash.
//	        	outputBuffers = videoCodec.getOutputBuffers();
	        	Log.d(LSConfig.TAG, String.format("LSVideoDecoder::getDecodeVideoFrame( [INFO_OUTPUT_BUFFERS_CHANGED] )"));
	        					
	        } else if (outIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
	            // this happens before the first frame is returned
	        	videoMediaFormat = videoCodec.getOutputFormat();
	        	Log.d(LSConfig.TAG, 
	        			String.format("LSVideoDecoder::getDecodeVideoFrame( "
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
	            
//	            Image image = videoCodec.getOutputImage(outIndex);
//	            int format = image.getFormat();
	            
	            Log.i(LSConfig.TAG, String.format("LSVideoDecoder::getDecodeVideoFrame( "
	            		+ "outIndex : %d, "
	            		+ "timestamp : %d "
	            		+ ")", 
	            		outIndex, 
	            		bufferInfo.presentationTimeUs
	            		)
	            		);
	            
	            videoFrame = videoFrames[outIndex];
	            videoFrame.bufferIndex = outIndex;
	            videoFrame.timestamp = (int)bufferInfo.presentationTimeUs;
	            videoFrame.width = videoMediaFormat.getInteger(MediaFormat.KEY_WIDTH);
	            videoFrame.height = videoMediaFormat.getInteger(MediaFormat.KEY_HEIGHT);
	            
	            if( videoFrame.data != null && byteBuffer.remaining() > videoFrame.data.length ) {
	            	videoFrame.data = new byte[byteBuffer.remaining()];
	            } else if( videoFrame.data == null ){
	            	videoFrame.data = new byte[byteBuffer.remaining()];
	            }
	            
	            videoFrame.size = byteBuffer.remaining();
	            byteBuffer.get(videoFrame.data, 0, byteBuffer.remaining());
	            
	        } else {
	    		Log.i(LSConfig.TAG, String.format("LSVideoDecoder::getDecodeVideoFrame( "
	    				+ "[Unknow], "
	    				+ "outIndex : %d "
	    				+ ")", 
	    				outIndex)
	    				);
	        }
	        
		} catch(Exception e) {
			Log.i(LSConfig.TAG, String.format("LSVideoDecoder::getDecodeVideoFrame( "
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
