package net.qdating.player;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Stack;

import android.annotation.SuppressLint;
import android.media.Image;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
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
		String codecName = "";
		String codecType = "";
		int colorFormat = 0;
		
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
												+ "[Find video codec], "
												+ "codecName : [%s], "
												+ "codecType : [%s] "
												+ ")",
										codecInfo.getName(),
	        							supportTypes[j])
	        					);
        			}
        			
        			if( !codecInfo.isEncoder() && supportTypes[j].equalsIgnoreCase(MIME_TYPE) ) {
                        Log.i(LSConfig.TAG,
                                String.format("LSVideoHardDecoder::supportHardDecoder( "
                                                + "[Find video codec], "
                                                + "codecName : [%s], "
                                                + "codecType : [%s] "
                                                + ")",
                                        codecInfo.getName(),
                                        supportTypes[j]
								)
                        );
                        
						try {
							// 检查编码支持的采样格式
							MediaCodec videoCodec = MediaCodec.createEncoderByType(MIME_TYPE);
							if( videoCodec != null ) {
								MediaCodecInfo.CodecCapabilities caps = videoCodec.getCodecInfo().getCapabilitiesForType(MIME_TYPE);
								for (int k = 0; k < caps.colorFormats.length; k++) {
									if( LSConfig.debug ) {
										Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::supportHardDecoder( [Check color format], colorFormat : 0x%x )", caps.colorFormats[k]));
									}
									
									if( caps.colorFormats[k] == MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Planar ) {
										codecName = codecInfo.getName();
										codecType = supportTypes[j];
										colorFormat = caps.colorFormats[k];

										bFlag = true;

										Log.i(LSConfig.TAG,
												String.format("LSVideoHardDecoder::supportHardDecoder( "
														+ "[Find video hard decoder], "
														+ "codecName : %s, "
														+ "codecType : %s, "
														+ "colorFormat : 0x%x "
														+ ")",
														codecName,
														codecType,
														colorFormat
												)
										);

										break;
									}
								}

								if( !bFlag ) {
									if( LSConfig.debug ) {
										Log.d(LSConfig.TAG, String.format("LSVideoHardEncoder::supportHardDecoder( [Color format not found] )"));
									}
								}
								videoCodec.release();
							}
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
							Log.d(LSConfig.TAG, String.format("LSVideoHardEncoder::supportHardDecoder( e : %s )", e.toString()));
						}

        				break;
        			}
        		}
        		if( bFlag ) {
        			break;
				}
        	}
        }  
        
		if( !bFlag ) {
			Log.e(LSConfig.TAG, String.format("LSVideoHardEncoder::supportHardDecoder( [Video hard decoder not found] )"));
		}
		
        return bFlag;  
    }
	
	public LSVideoHardDecoder() {
		videoFrameStack = new Stack<LSVideoHardDecoderFrame>();
		for(int i = 0; i < LSConfig.VIDEO_DECODE_FRAME_COUNT; i++) {
			LSVideoHardDecoderFrame videoFrame = new LSVideoHardDecoderFrame();
			videoFrameStack.push(videoFrame);
		}
	}
	
	public boolean reset() {
		boolean bFlag = false;

		Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::reset( this : 0x%x )", hashCode()));

		if( videoCodec == null ) {
	        try {
				videoCodec = MediaCodec.createDecoderByType(MIME_TYPE);
				if( videoCodec != null ) {
					videoMediaFormat = MediaFormat.createVideoFormat(MIME_TYPE, LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT);
			        videoMediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Planar);
			        
					videoCodec.configure(videoMediaFormat, null, null, 0);
					videoCodec.start();
					bFlag = true;
					Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::reset( codecName : %s, mimeType : %s )", videoCodec.getName(), MIME_TYPE));
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				Log.e(LSConfig.TAG, String.format("LSVideoHardDecoder::reset( this : 0x%x, [Fail], error : %s )", hashCode(), e.toString()));

				bFlag = false;
			}
		}

        
        return bFlag;
	}
	
	public void pause() {
		Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::pause()"));

		if( videoCodec != null ) {
			videoCodec.stop();
			videoCodec.release();
            videoCodec = null;
		}
		
	}
	
	@Override
	public boolean decodeVideoKeyFrame(byte[] sps, int sps_size, byte[] pps, int pps_size, int naluHeaderSize) {
		Log.d(LSConfig.TAG,
				String.format("LSVideoHardDecoder::decodeVideoKeyFrame( "
				+ "this : 0x%x, "
				+ "sps_size : %d, "
				+ "pps_size : %d, "
				+ "naluHeaderSize : %d "
				+ ")",
				hashCode(),
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
		
		if( videoCodec != null ) {
			// 阻塞等待
			int inIndex = -1;
	        inIndex = videoCodec.dequeueInputBuffer(-1);
	        if( LSConfig.debug ) {
	    		Log.d(LSConfig.TAG,
	    				String.format("LSVideoHardDecoder::decodeFrame( "
										+ "this : 0x%x, "
										+ "inIndex : %d, "
										+ "size : %d, "
										+ "timestamp : %d "
										+ ")",
								hashCode(),
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

		if( videoCodec != null ) {
			try {
				long timeoutUs = 500 * 1000;
		    	bufferIndex = videoCodec.dequeueOutputBuffer(bufferInfo, timeoutUs);
		    	
		        if (bufferIndex == MediaCodec.INFO_TRY_AGAIN_LATER) {
		            // no output available yet
		        } else if (bufferIndex == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
		            // The storage associated with the direct ByteBuffer may already be unmapped,
		            // so attempting to access data through the old output buffer array could
		            // lead to a native crash.
//		        	Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::getDecodeVideoFrame( [INFO_OUTPUT_BUFFERS_CHANGED] )"));
//		        	outputBuffers = videoCodec.getOutputBuffers();
		        					
		        } else if (bufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
		            // this happens before the first frame is returned
		        	videoMediaFormat = videoCodec.getOutputFormat();
		        	Log.i(LSConfig.TAG, 
		        			String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
											+ "this : 0x%x, "
											+ "[INFO_OUTPUT_FORMAT_CHANGED], "
											+ "videoMediaFormat : %s "
											+ ")",
									hashCode(),
									videoMediaFormat.toString()
		        					)
		        			);
		        } else if( bufferIndex >= 0 ) {	
		        	synchronized (this) {
			            if( videoFrameStack.isEmpty() ) {
			            	videoFrame = new LSVideoHardDecoderFrame();
				        	Log.d(LSConfig.TAG,
				        			String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
													+ "this : 0x%x, "
													+ "[New videoFrame is created], "
													+ "videoFrame : 0x%x "
													+ ")",
											hashCode(),
				        					videoFrame.hashCode()
				        					)
				        			);
			            } else {
			            	videoFrame = videoFrameStack.pop();
			            }
					}

		            Image image = videoCodec.getOutputImage(bufferIndex);
		            if( image != null ) {
						videoFrame.updateImage(image, (int)bufferInfo.presentationTimeUs);
						bFlag = true;
					} else {
						Log.e(LSConfig.TAG,
								String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
												+ "this : 0x%x, "
												+ "[Fail, image is null], "
												+ "bufferIndex : %d "
												+ ")",
										hashCode(),
										bufferIndex
								)
						);
					}
	                videoCodec.releaseOutputBuffer(bufferIndex, false);

		        } else {
		    		Log.d(LSConfig.TAG,
		    				String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
											+ "this : 0x%x, "
											+ "[Fail, unknow], "
											+ "bufferIndex : %d "
											+ ")",
									hashCode(),
	                                bufferIndex
	                        )
	                );
		        }
		        
			} catch(Exception e) {
				Log.d(LSConfig.TAG,
	                    String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
	                                    + "this : 0x%x, "
	                                    + "[Fail, exception], "
	                                    + "bufferIndex : %d, "
	                                    + "e : %s "
	                                    + ")",
	                            hashCode(),
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
		}
		
        return videoFrame;
	}
}
