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
	private static final String MIME_TYPE = "video/avc";    // H.264 Advanced Video Coding

	// 视频解码器
	private MediaCodec videoCodec = null;
	private MediaFormat videoMediaFormat = null;
	
	public MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();
	private Stack<LSVideoHardEncoderFrame> videoFrameStack = null;
	
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
			for(int i = 0; i < codecInfos.length; i++) {
				// 检查编码类型
				MediaCodecInfo codecInfo = codecInfos[i];
				String[] supportTypes = codecInfo.getSupportedTypes();
				for (int j = 0; j < supportTypes.length; j++) {
					if( LSConfig.debug ) {
						Log.d(LSConfig.TAG,
								String.format("LSVideoHardEncoder::supportHardEncoder( "
										+ "[Check codec], "
										+ "codecName : [%s], "
										+ "codecType : [%s] "
										+ ")",
										codecInfo.getName(),
										supportTypes[j]
								)
						);
					}

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
									if( LSConfig.debug ) {
										Log.d(LSConfig.TAG, String.format("LSVideoHardEncoder::supportHardEncoder( [Check color format], colorFormat : 0x%x )", caps.colorFormats[k]));
									}
									
									if( caps.colorFormats[k] == MediaCodecInfo.CodecCapabilities.COLOR_Format32bitARGB8888 ) {
										codecName = codecInfo.getName();
										codecType = supportTypes[j];
										colorFormat = caps.colorFormats[k];

										bFlag = true;

										Log.i(LSConfig.TAG,
												String.format("LSVideoHardEncoder::supportHardEncoder( "
														+ "[Find video hard encoder], "
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
			Log.e(LSConfig.TAG, String.format("LSVideoHardEncoder::supportHardEncoder( [Video hard encoder not found] )"));
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
		
		if( videoCodec == null ) {
	        try {
				videoCodec = MediaCodec.createEncoderByType(MIME_TYPE);
				if( videoCodec != null ) {
					videoMediaFormat = MediaFormat.createVideoFormat(MIME_TYPE, width, height);
			        videoMediaFormat.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, 0);
			        videoMediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_Format32bitARGB8888);
			        videoMediaFormat.setInteger(MediaFormat.KEY_BIT_RATE, bitRate);
			        videoMediaFormat.setInteger(MediaFormat.KEY_FRAME_RATE, fps);
			        videoMediaFormat.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, keyFrameInterval);
			        
					videoCodec.configure(videoMediaFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
					videoCodec.start();
					
					bFlag = true;
					Log.d(LSConfig.TAG, String.format("LSVideoHardEncoder::reset( this : 0x%x, codecName : %s, mimeType : %s )", hashCode(), videoCodec.getName(), MIME_TYPE));
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
	        if( LSConfig.debug ) {
	       		Log.d(LSConfig.TAG, 
	    				String.format("LSVideoHardEncoder::encodeVideoFrame( "
			    				+ "inIndex : %d, "
			    				+ "timestamp : %d "
			    				+ ")", 
			    				inIndex,
			    				timestamp
						)
				);
	        }
	        
	        if( inIndex >= 0 ) {
	        	ByteBuffer[] inputBuffers = videoCodec.getInputBuffers();
	            ByteBuffer buffer = inputBuffers[inIndex];
	            buffer.clear();
	            buffer.put(data, 0, size);
	            
	            // 放进硬编码器
	            videoCodec.queueInputBuffer(inIndex, 0, buffer.position(), timestamp, 0/*MediaCodec.BUFFER_FLAG_CODEC_CONFIG*/);
	            
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
		        					+ "[INFO_OUTPUT_FORMAT_CHANGED], "
		        					+ "bufferIndex : %d, "
		        					+ "videoMediaFormat : %s "
		        					+ ")",
									bufferIndex,
		        					videoMediaFormat.toString()
							)
					);

		        } else if( bufferIndex >= 0 ) {
		        	synchronized (this) {
			            if( videoFrameStack.isEmpty() ) {
			            	videoFrame = new LSVideoHardEncoderFrame();
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
		        	ByteBuffer[] outputBuffers = videoCodec.getOutputBuffers();
		            ByteBuffer byteBuffer = outputBuffers[bufferIndex];

					videoFrame.update(byteBuffer, (int)bufferInfo.presentationTimeUs);
					videoCodec.releaseOutputBuffer(bufferIndex, false);

		        } else {
		    		Log.i(LSConfig.TAG,
							String.format("LSVideoHardEncoder::getEncodeVideoFrame( "
											+ "[Unknow], "
											+ "bufferIndex : %d "
											+ ")",
									bufferIndex
							)
					);
		        }
		        
			} catch(Exception e) {
				Log.i(LSConfig.TAG,
						String.format("LSVideoHardEncoder::getEncodeVideoFrame( "
										+ "[Exception], "
										+ "bufferIndex : %d, "
										+ "e : %s "
										+ ")",
								bufferIndex,
								e.toString()
						)
				);
			}
		}
		
        return videoFrame;
	}
}
