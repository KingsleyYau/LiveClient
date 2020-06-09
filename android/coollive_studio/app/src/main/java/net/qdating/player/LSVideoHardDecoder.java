package net.qdating.player;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.LinkedList;
import java.util.Stack;
import java.util.Vector;

import android.annotation.SuppressLint;
import android.media.Image;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaCodecList;
import android.media.MediaFormat;
import android.os.Build;
import net.qdating.utils.Log;
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

	private LSVideoHardDecoderFrame videoErrorFrame = new LSVideoHardDecoderFrame();
	public MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();
	private Stack<LSVideoHardDecoderFrame> videoFrameStack = null;

	// 输入源的采样格式
	private static final int INVALID_COLOR_FORMAT = 0xFFFFFFFF;
	private static int outputColorFormat = INVALID_COLOR_FORMAT;

	/**
	 * h264 start code
	 */
	private static byte sync_bytes[] = {0x0, 0x0, 0x0, 0x1};
	
	/**
	 * NALU头部长度
	 */
	private int naluHeaderSize = 4;

	/**
	 * 当前解码缓存
	 */
	private int decodeFrameCount = LSConfig.VIDEO_DECODE_FRAME_COUNT;

	/**
	 * 解码输出宽
	 */
	private int width = 0;
	/**
	 * 解码输出高
	 */
	private int height = 0;
	/**
	 * 解码输出格式
	 */
	private int format = 0;
	/**
	 * 解码输出行对齐
	 */
	private int stride = 0;
	/**
	 * 解码输出Y的高对齐
	 */
	private int sliceHeight = 0;

	/**
	 * 获取支持的硬解码采样格式
	 * @return
	 */
	static public int supportHardDecoderFormat() {
		if( outputColorFormat == INVALID_COLOR_FORMAT ) {
			// 尝试获取采样格式
			supportHardDecoder();
		}
		return outputColorFormat;
	}

	@SuppressLint("NewApi")  
	/**
	 * 判断是否支持硬解码
	 * @return
	 */
    public static boolean supportHardDecoder() {
		boolean bFlag = false;
		String codecName = "";
		String codecType = "";
		int colorFormat = 0;
		
        if( Build.VERSION.SDK_INT >= 21 ) {
        	MediaCodecList codecList = new MediaCodecList(MediaCodecList.REGULAR_CODECS);
        	MediaCodecInfo[] codecInfos = codecList.getCodecInfos();
			int count = codecInfos.length;
//            int count = MediaCodecList.getCodecCount();
        	for(int i = 0; i < count; i++) {
        		MediaCodecInfo codecInfo = codecInfos[i];
//                MediaCodecInfo codecInfo = MediaCodecList.getCodecInfoAt(i);
        		String[] supportTypes = codecInfo.getSupportedTypes();
        		for (int j = 0; j < supportTypes.length; j++) {
//        			if( LSConfig.DEBUG ) {
//	        			Log.d(LSConfig.TAG,
//								String.format("LSVideoHardDecoder::supportHardDecoder( "
//												+ "[Check video codec], "
//												+ "codecName : [%s], "
//												+ "codecType : [%s] "
//												+ ")",
//										codecInfo.getName(),
//	        							supportTypes[j])
//	        					);
//        			}
        			
        			if( !codecInfo.isEncoder() && supportTypes[j].equalsIgnoreCase(MIME_TYPE) ) {
                        Log.i(LSConfig.TAG,
                                String.format("LSVideoHardDecoder::supportHardDecoder( "
                                                + "[Check video codec matched], "
                                                + "codecName : [%s], "
                                                + "codecType : [%s] "
                                                + ")",
                                        codecInfo.getName(),
                                        supportTypes[j]
								)
                        );

						MediaCodec videoCodec = null;
						try {
							// 检查编码支持的采样格式
							videoCodec = MediaCodec.createEncoderByType(MIME_TYPE);
							if( videoCodec != null ) {
								MediaCodecInfo.CodecCapabilities caps = videoCodec.getCodecInfo().getCapabilitiesForType(MIME_TYPE);
								for (int k = 0; k < caps.colorFormats.length; k++) {
									if( LSConfig.DEBUG ) {
										Log.d(LSConfig.TAG,
												String.format("LSVideoHardDecoder::supportHardDecoder( "
														+ "[Check color format], "
														+ "codecName : [%s], "
														+ "colorFormat : 0x%x "
														+ ")",
														codecInfo.getName(),
														caps.colorFormats[k]
												)
										);
									}

									if( (caps.colorFormats[k] == MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Planar)
											|| (caps.colorFormats[k] == MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420SemiPlanar)
											) {
										codecName = codecInfo.getName();
										codecType = supportTypes[j];
										colorFormat = caps.colorFormats[k];
										outputColorFormat = caps.colorFormats[k];

										bFlag = true;

										Log.i(LSConfig.TAG,
												String.format("LSVideoHardDecoder::supportHardDecoder( "
														+ "[Video hard decoder found], "
														+ "codecName : [%s], "
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
										Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::supportHardDecoder( [Color format not found] )"));
									}
								}

								videoCodec.release();
							}
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
							Log.e(LSConfig.TAG, String.format("LSVideoHardDecoder::supportHardDecoder( e : %s )", e.toString()));

							if (videoCodec != null) {
								videoCodec.release();
							}
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
			Log.e(LSConfig.TAG, String.format("LSVideoHardDecoder::supportHardDecoder( [Video hard decoder not found], SDK_VERSION : %d )", Build.VERSION.SDK_INT));
		}
		
        return bFlag;  
    }
	
	public LSVideoHardDecoder() {
    	videoErrorFrame.bError = true;

		videoFrameStack = new Stack<LSVideoHardDecoderFrame>();
		for(int i = 0; i < LSConfig.VIDEO_DECODE_FRAME_COUNT; i++) {
			LSVideoHardDecoderFrame videoFrame = new LSVideoHardDecoderFrame();
			videoFrameStack.push(videoFrame);
		}
	}
	
	public boolean reset() {
		boolean bFlag = false;

		Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::reset( this : 0x%x )", hashCode()));

		if( videoCodec == null && outputColorFormat != INVALID_COLOR_FORMAT ) {
	        try {
				videoCodec = MediaCodec.createDecoderByType(MIME_TYPE);
				if( videoCodec != null ) {
					videoMediaFormat = MediaFormat.createVideoFormat(MIME_TYPE, 360, 240);
			        videoMediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, outputColorFormat);
			        
					videoCodec.configure(videoMediaFormat, null, null, 0);
					videoCodec.start();

					bFlag = true;
					Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::reset( this : 0x%x, [Success], codecName : [%s], mimeType : %s )", hashCode(), videoCodec.getName(), MIME_TYPE));
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
		Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::pause( this : 0x%x )", hashCode()));

		try {
			if (videoCodec != null) {
				videoCodec.stop();
				videoCodec.release();
				videoCodec = null;
			}
		} catch (IllegalStateException e) {
			Log.e(LSConfig.TAG, String.format("LSVideoHardDecoder::pause( this : 0x%x, [Fail], error : %s )", hashCode(), e.toString()));
		}
	}
	
	@Override
	public boolean decodeVideoKeyFrame(byte[] sps, int sps_size, byte[] pps, int pps_size, int naluHeaderSize, int timestamp) {
		Log.d(LSConfig.TAG,
				String.format("LSVideoHardDecoder::decodeVideoKeyFrame( "
				+ "this : 0x%x, "
				+ "sps_size : %d, "
				+ "pps_size : %d, "
				+ "naluHeaderSize : %d "
				+ "timestamp : %d "
				+ ")",
				hashCode(),
				sps_size,
				pps_size,
				naluHeaderSize,
				timestamp
				)
        );
		
		boolean bFlag = false;
		
		this.naluHeaderSize = naluHeaderSize;
		
        bFlag = decodeVideoFrame(sps, 0, sps_size, timestamp);
        bFlag = bFlag && decodeVideoFrame(pps, 0, pps_size, timestamp);
		
        return bFlag;
	}
	
	@Override
	public boolean decodeVideoFrame(byte[] data, int size, int timestamp) {
		// TODO Auto-generated method stub
		
		// 放到解码队列
		return decodeVideoFrame(data, this.naluHeaderSize, size, timestamp);
	}

	private boolean decodeVideoFrame(byte[] data, int offset, int size, int timestamp) {
		boolean bFlag = false;
		
		if( videoCodec != null ) {
			// 阻塞等待
			int inputIndex = -1;
			inputIndex = videoCodec.dequeueInputBuffer(-1);

	        if( LSConfig.DEBUG ) {
	    		Log.d(LSConfig.TAG,
	    				String.format("LSVideoHardDecoder::decodeVideoFrame( "
										+ "this : 0x%x, "
										+ "inputIndex : %d, "
										+ "size : %d, "
										+ "timestamp : %d "
										+ ")",
								hashCode(),
								inputIndex,
								size,
								timestamp
						)
	            );
	        }

	        if ( inputIndex >= 0 ) {
	        	ByteBuffer[] inputBuffers = videoCodec.getInputBuffers();
	            ByteBuffer buffer = inputBuffers[inputIndex];
	            buffer.clear();
	            buffer.put(sync_bytes);
	            buffer.put(data, offset, size - offset);

	            // 放进硬解码器
	            videoCodec.queueInputBuffer(inputIndex, 0, buffer.position(), timestamp, 0/*MediaCodec.BUFFER_FLAG_CODEC_CONFIG*/);

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
		int outputIndex = -1;

		boolean bFlag = false;

		if( videoCodec != null ) {
			try {
				long timeoutUs = 500 * 1000;
				outputIndex = videoCodec.dequeueOutputBuffer(bufferInfo, timeoutUs);

		        if (outputIndex == MediaCodec.INFO_TRY_AGAIN_LATER) {
		            // no output available yet
		        } else if (outputIndex == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
		            // The storage associated with the direct ByteBuffer may already be unmapped,
		            // so attempting to access data through the old output buffer array could
		            // lead to a native crash.
//		        	Log.d(LSConfig.TAG, String.format("LSVideoHardDecoder::getDecodeVideoFrame( [INFO_OUTPUT_BUFFERS_CHANGED] )"));
//		        	outputBuffers = videoCodec.getOutputBuffers();

		        } else if (outputIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
		            // this happens before the first frame is returned
		        	videoMediaFormat = videoCodec.getOutputFormat();
					width = videoMediaFormat.getInteger(MediaFormat.KEY_WIDTH);
					height = videoMediaFormat.getInteger(MediaFormat.KEY_HEIGHT);
					format = videoMediaFormat.getInteger(MediaFormat.KEY_COLOR_FORMAT);
					stride = videoMediaFormat.getInteger(MediaFormat.KEY_STRIDE);
					sliceHeight = videoMediaFormat.getInteger(MediaFormat.KEY_SLICE_HEIGHT);

//					int strideMod = width % 16;
//					stride = (strideMod == 0)?0:(((width / 16) + 1) * 16 - width);
//					stride = keyStride - width;

					Log.i(LSConfig.TAG,
							String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
											+ "this : 0x%x, "
											+ "[INFO_OUTPUT_FORMAT_CHANGED], "
											+ "stride : %d, "
											+ "sliceHeight : %d, "
											+ "width : %d, "
											+ "height : %d, "
											+ "videoMediaFormat : %s "
											+ ")",
									hashCode(),
									stride,
									sliceHeight,
									width,
									height,
									videoMediaFormat.toString()
							)
					);

		        } else if( outputIndex >= 0 ) {
		        	synchronized (this) {
			            if( videoFrameStack.isEmpty() ) {
//			            	if( decodeFrameCount < LSConfig.VIDEO_DECODE_FRAME_MAX_COUNT ) {
								videoFrame = new LSVideoHardDecoderFrame();
							decodeFrameCount++;

								Log.w(LSConfig.TAG,
										String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
														+ "this : 0x%x, "
														+ "[New Video Frame], "
														+ "videoFrame : 0x%x, "
														+ "decodeFrameCount : %d "
														+ ")",
												hashCode(),
												videoFrame.hashCode(),
												decodeFrameCount
										)
								);
//							} else {
//								Log.w(LSConfig.TAG,
//										String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
//														+ "this : 0x%x, "
//														+ "[Too many videoFrame is created], "
//														+ "decodeFrameCount : %d "
//														+ ")",
//												hashCode(),
//												decodeFrameCount
//										)
//								);
//
//								videoFrame = videoErrorFrame;
//							}
			            } else {
			            	videoFrame = videoFrameStack.pop();
			            }
					}

					if( LSConfig.DEBUG ) {
						Log.d(LSConfig.TAG,
								String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
												+ "this : 0x%x, "
												+ "outputIndex : %d, "
												+ "size : %d, "
												+ "timestamp : %d "
												+ ")",
										hashCode(),
										outputIndex,
										bufferInfo.size,
										(int) bufferInfo.presentationTimeUs
								)
						);
					}

					// API 16
					ByteBuffer byteBuffer = videoCodec.getOutputBuffer(outputIndex);
		        	if( byteBuffer != null ) {
		        	    int width = videoMediaFormat.getInteger(MediaFormat.KEY_WIDTH);
                        int height = videoMediaFormat.getInteger(MediaFormat.KEY_HEIGHT);
                        int format = videoMediaFormat.getInteger(MediaFormat.KEY_COLOR_FORMAT);
                        if( videoFrame != null ) {
							videoFrame.updateImage(byteBuffer, (int) bufferInfo.presentationTimeUs, format, width, height, stride, sliceHeight);
							bFlag = true;
						}
                    } else {
                        Log.e(LSConfig.TAG,
                                String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
                                                + "this : 0x%x, "
                                                + "[Fail, byteBuffer is null], "
                                                + "outputIndex : %d "
                                                + ")",
                                        hashCode(),
										outputIndex
                                )
                        );
                    }

                    // API 21
//		            Image image = videoCodec.getOutputImage(outputIndex);
//		            if( image != null ) {
//						videoFrame.updateImage(image, (int)bufferInfo.presentationTimeUs);
//						bFlag = true;
//					} else {
//						Log.e(LSConfig.TAG,
//								String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
//												+ "this : 0x%x, "
//												+ "[Fail, image is null], "
//												+ "outputIndex : %d "
//												+ ")",
//										hashCode(),
//										outputIndex
//								)
//						);
//					}

		        } else {
		    		Log.d(LSConfig.TAG,
		    				String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
											+ "this : 0x%x, "
											+ "[Fail, unknow], "
											+ "outputIndex : %d "
											+ ")",
									hashCode(),
									outputIndex
	                        )
	                );
		        }

			} catch(Exception e) {
				Log.d(LSConfig.TAG,
	                    String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
	                                    + "this : 0x%x, "
	                                    + "[Fail, exception], "
	                                    + "outputIndex : %d, "
	                                    + "e : %s "
	                                    + ")",
	                            hashCode(),
								outputIndex,
	                            e.toString()
	                    )
	            );
			} finally {
				if( outputIndex >= 0 ) {
					try {
						videoCodec.releaseOutputBuffer(outputIndex, false);
					} catch(Exception e) {
						Log.d(LSConfig.TAG,
								String.format("LSVideoHardDecoder::getDecodeVideoFrame( "
												+ "this : 0x%x, "
												+ "[releaseOutputBuffer Fail, exception], "
												+ "outputIndex : %d, "
												+ "e : %s "
												+ ")",
										hashCode(),
										outputIndex,
										e.toString()
								)
						);
					}
				}
			}

			if( !bFlag ) {
				if( videoFrame != null && (videoFrame != videoErrorFrame) ) {
					synchronized (this) {
						videoFrameStack.push(videoFrame);
					}
					videoFrame = null;
				}
			}
		}
		
        return videoFrame;
	}
}
