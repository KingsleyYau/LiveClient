package net.qdating.publisher;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Stack;

import android.annotation.SuppressLint;
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
public class LSVideoHardEncoder implements ILSVideoHardEncoderJni {
	// H.264 Advanced Video Coding
	private static final String MIME_TYPE = "video/avc";
	// 输入源的采样格式
	private static final int INVALID_COLOR_FORMAT = 0xFFFFFFFF;
	private static int inputColorFormat = INVALID_COLOR_FORMAT;
	private static MediaCodecInfo.VideoCapabilities inputVideoCaps = null;

	// 视频解码器
	private MediaCodec videoCodec = null;
	private MediaFormat videoMediaFormat = null;

	public MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();
	private Stack<LSVideoHardEncoderFrame> videoFrameStack = null;

	/**
	 * 获取支持的硬编码采样格式
	 * @return
	 */
	static public int supportHardEncoderFormat() {
		if( inputColorFormat == INVALID_COLOR_FORMAT ) {
			// 尝试获取采样格式
			supportHardEncoder();
		}
		return inputColorFormat;
	}

	@SuppressLint("NewApi")
	/**
	 * 判断是否支持硬解码
	 * @return
	 */
	static public boolean supportHardEncoder() {
		boolean bFlag = false;
		String codecName = "";
		String codecType = "";
		int colorFormat = 0;

		// 检查系统版本
		if( Build.VERSION.SDK_INT >= 21 ) {
			MediaCodecList codecList = new MediaCodecList(MediaCodecList.REGULAR_CODECS);
            MediaCodecInfo[] codecInfos = codecList.getCodecInfos();
			int count = codecInfos.length;
//            int count = MediaCodecList.getCodecCount();
			for(int i = 0; i < count; i++) {
				// 检查编码类型
				MediaCodecInfo codecInfo = codecInfos[i];
//                MediaCodecInfo codecInfo = MediaCodecList.getCodecInfoAt(i);
				String[] supportTypes = codecInfo.getSupportedTypes();
				for (int j = 0; j < supportTypes.length; j++) {
//					if( LSConfig.DEBUG ) {
//						Log.d(LSConfig.TAG,
//								String.format("LSVideoHardEncoder::supportHardEncoder( "
//										+ "[Check video codec], "
//										+ "codecName : [%s], "
//										+ "codecType : [%s] "
//										+ ")",
//										codecInfo.getName(),
//										supportTypes[j]
//								)
//						);
//					}

					if( codecInfo.isEncoder() && supportTypes[j].equalsIgnoreCase(MIME_TYPE) ) {
						Log.i(LSConfig.TAG,
								String.format("LSVideoHardEncoder::supportHardEncoder( "
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
									inputVideoCaps = caps.getVideoCapabilities();
									if( LSConfig.DEBUG ) {
										Log.d(LSConfig.TAG,
												String.format("LSVideoHardEncoder::supportHardEncoder( " +
														"[Check color format], " +
														"colorFormat : 0x%x, " +
														"width : [%d - %d], " +
														"height : [%d - %d], " +
														"widthAlignment : %d, " +
														"heightAlignment : %d " +
														")",
														caps.colorFormats[k],
														inputVideoCaps.getSupportedWidths().getLower(),
														inputVideoCaps.getSupportedWidths().getUpper(),
														inputVideoCaps.getSupportedHeights().getLower(),
														inputVideoCaps.getSupportedHeights().getUpper(),
														inputVideoCaps.getWidthAlignment(),
														inputVideoCaps.getHeightAlignment()
												)
										);
									}
									
									if(
											inputVideoCaps.isSizeSupported(LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT) &&
													(
															(caps.colorFormats[k] == MediaCodecInfo.CodecCapabilities.COLOR_Format32bitARGB8888)
																	|| (caps.colorFormats[k] == MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Planar)
																	|| (caps.colorFormats[k] == MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420SemiPlanar)
													)
											) {
										codecName = codecInfo.getName();
										codecType = supportTypes[j];
										colorFormat = caps.colorFormats[k];
										inputColorFormat = caps.colorFormats[k];

										bFlag = true;

										Log.i(LSConfig.TAG,
												String.format("LSVideoHardEncoder::supportHardEncoder( "
														+ "[Video hard encoder found], "
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
									if( LSConfig.DEBUG ) {
										Log.d(LSConfig.TAG, String.format("LSVideoHardEncoder::supportHardEncoder( [Color format not found] )"));
									}
								}
								videoCodec.release();
							}
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
							Log.d(LSConfig.TAG, String.format("LSVideoHardEncoder::supportHardEncoder( e : %s )", e.toString()));
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
			Log.e(LSConfig.TAG, String.format("LSVideoHardEncoder::supportHardEncoder( [Video hard encoder not found], SDK_VERSION : %d )", Build.VERSION.SDK_INT));
		}

		return bFlag;
	}

	public LSVideoHardEncoder() {
		videoFrameStack = new Stack<LSVideoHardEncoderFrame>();
		for(int i = 0; i < LSConfig.VIDEO_ENCODE_FRAME_COUNT; i++) {
			LSVideoHardEncoderFrame videoFrame = new LSVideoHardEncoderFrame();
			videoFrameStack.push(videoFrame);
		}
	}

	public boolean reset(int width, int height, int bitRate, int keyFrameInterval, int fps) {
		Log.i(LSConfig.TAG, String.format("LSVideoHardEncoder::reset( this : 0x%x )", hashCode()));
		
		boolean bFlag = false;
		
		if( videoCodec == null && inputColorFormat != INVALID_COLOR_FORMAT ) {
	        try {
				videoCodec = MediaCodec.createEncoderByType(MIME_TYPE);
				if( videoCodec != null ) {
					// 基本参数
					videoMediaFormat = MediaFormat.createVideoFormat(MIME_TYPE, width, height);
			        videoMediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, inputColorFormat);
			        videoMediaFormat.setInteger(MediaFormat.KEY_BIT_RATE, bitRate);
			        videoMediaFormat.setInteger(MediaFormat.KEY_FRAME_RATE, fps);
			        // Android 25后才可以使用浮点
			        videoMediaFormat.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, keyFrameInterval / fps);

					/**
					 * 在SAMSUNG的机器必须选用BITRATE_MODE_CQ(质量优先), 否则某些机器编码后图像会越来越模糊
					 */
					videoMediaFormat.setInteger(MediaFormat.KEY_BITRATE_MODE, MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_CQ);
					/**
					 * 不能开, 否则在魅族的机器会Crash
					 * android.media.MediaCodec$CodecException: Error 0x80001001
					 */
//					videoMediaFormat.setInteger(MediaFormat.KEY_PROFILE, MediaCodecInfo.CodecProfileLevel.AVCProfileBaseline);
//					videoMediaFormat.setInteger(MediaFormat.KEY_LEVEL, MediaCodecInfo.CodecProfileLevel.AVCLevel3);

					videoCodec.configure(videoMediaFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
					videoCodec.start();
					
					bFlag = true;
					Log.d(LSConfig.TAG,
							String.format("LSVideoHardEncoder::reset( "
											+ "this : 0x%x, "
											+ "codecName : %s, "
											+ "codecType : %s, "
											+ "colorFormat : 0x%x "
											+ ")",
									hashCode(),
									videoCodec.getName(),
									MIME_TYPE,
									inputColorFormat
							)
					);
				}

			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				Log.e(LSConfig.TAG, String.format("LSVideoHardEncoder::reset( this : 0x%x, [Fail], error : %s )", hashCode(), e.toString()));

				bFlag = false;
			}
		}

        return bFlag;
	}

	public void pause() {
		Log.i(LSConfig.TAG, String.format("LSVideoHardEncoder::pause()"));
		
		if( videoCodec != null ) {
			videoCodec.stop();
			videoCodec.release();
			videoCodec = null;
		}
	}
	
	@Override
	public boolean encodeVideoFrame(byte[] data, int size) {
		// TODO Auto-generated method stub
		// 放到解码队列
		boolean bFlag = false;
		
		if( videoCodec != null ) {
			// 阻塞等待
			int inIndex = -1;
	        inIndex = videoCodec.dequeueInputBuffer(-1);
	        int timestamp = (int) (System.nanoTime() / 1000 / 1000);

//	        if( LSConfig.DEBUG ) {
//	       		Log.d(LSConfig.TAG,
//	    				String.format("LSVideoHardEncoder::encodeVideoFrame( "
//								+ "this : 0x%x, "
//			    				+ "inIndex : %d, "
//			    				+ "timestamp : %d "
//			    				+ ")",
//			    				hashCode(),
//			    				inIndex,
//			    				timestamp
//						)
//				);
//	        }
	        
	        if( inIndex >= 0 ) {
	        	ByteBuffer[] inputBuffers = videoCodec.getInputBuffers();
	            ByteBuffer buffer = inputBuffers[inIndex];
	            buffer.clear();
	            buffer.put(data, 0, size);
				buffer.rewind();
	            
	            // 放进硬编码器
	            videoCodec.queueInputBuffer(inIndex, 0, size, timestamp, 0/*MediaCodec.BUFFER_FLAG_CODEC_CONFIG*/);
	            
	            bFlag = true;
	        }
		}
        
		return bFlag;
	}

	@Override
	public void releaseVideoFrame(LSVideoHardEncoderFrame videoFrame) {
		// TODO Auto-generated method stub
		if( videoFrame != null ) {
			synchronized (this) {
				videoFrameStack.push(videoFrame);
			}
		}
	}
	
	@Override
	public LSVideoHardEncoderFrame getEncodeVideoFrame() {
    	// 获取编码数据
		LSVideoHardEncoderFrame videoFrame = null;
		int bufferIndex = -1;
				
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
		        	Log.d(LSConfig.TAG, String.format("LSVideoHardEncoder::getEncodeVideoFrame( [INFO_OUTPUT_BUFFERS_CHANGED] )"));
		        					
		        } else if (bufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
		            // this happens before the first frame is returned
		        	videoMediaFormat = videoCodec.getOutputFormat();
		        	Log.d(LSConfig.TAG, 
		        			String.format("LSVideoHardEncoder::getEncodeVideoFrame( "
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
			            	videoFrame = new LSVideoHardEncoderFrame();
				        	Log.d(LSConfig.TAG,
				        			String.format("LSVideoHardDecoder::getEncodeVideoFrame( "
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

		        	ByteBuffer[] outputBuffers = videoCodec.getOutputBuffers();
		            ByteBuffer byteBuffer = outputBuffers[bufferIndex];

//					if( LSConfig.DEBUG ) {
//						Log.d(LSConfig.TAG,
//								String.format("LSVideoHardDecoder::getEncodeVideoFrame( "
//												+ "this : 0x%x, "
//												+ "bufferIndex : %d, "
//												+ "size : %d, "
//												+ "timestamp : %d "
//												+ ")",
//										hashCode(),
//										bufferIndex,
//										byteBuffer.remaining(),
//										(int) bufferInfo.presentationTimeUs
//								)
//						);
//					}

					videoFrame.update(byteBuffer, (int)bufferInfo.presentationTimeUs);
					videoCodec.releaseOutputBuffer(bufferIndex, false);

		        } else {
		    		Log.i(LSConfig.TAG,
							String.format("LSVideoHardEncoder::getEncodeVideoFrame( "
											+ "this : 0x%x, "
											+ "[Unknow], "
											+ "bufferIndex : %d "
											+ ")",
									hashCode(),
									bufferIndex
							)
					);
		        }
		        
			} catch(Exception e) {
				Log.i(LSConfig.TAG,
						String.format("LSVideoHardEncoder::getEncodeVideoFrame( "
										+ "this : 0x%x, "
										+ "[Exception], "
										+ "bufferIndex : %d, "
										+ "e : %s "
										+ ")",
								hashCode(),
								bufferIndex,
								e.toString()
						)
				);
			}
		}
		
        return videoFrame;
	}
}
