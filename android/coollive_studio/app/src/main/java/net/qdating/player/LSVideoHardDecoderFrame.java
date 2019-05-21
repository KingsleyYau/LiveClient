package net.qdating.player;

import java.nio.ByteBuffer;

import android.graphics.ImageFormat;
import android.media.Image;
import android.media.Image.Plane;
import android.media.MediaCodecInfo;
import net.qdating.utils.Log;
import net.qdating.LSConfig;
import net.qdating.filter.LSImageUtil;

/**
 * 硬解码视频帧
 * @author max
 *
 */
public class LSVideoHardDecoderFrame {
	/**
	 * 时间戳
	 */
	public int timestamp = -1;

	/**
	 * 是否错误帧
	 */
	public boolean bError = false;

	/***
	 * @see android.graphics.ImageFormat
	 */
	public int format = 0;
	public int width = 0;
	public int height = 0;

	public byte[] byteBufferY = null;
	public int byteSizeY = 0;
	public byte[] byteBufferU = null;
	public int byteSizeU = 0;
	public byte[] byteBufferV = null;
	public int byteSizeV = 0;
	public byte[] byteBufferUV = null;
	public int byteSizeUV = 0;
	
	public LSVideoHardDecoderFrame() {

	}

	/**
	 * 只支持以下格式
	 * @see android.media.MediaCodecInfo.CodecCapabilities
	 * COLOR_FormatYUV420Planar		= 19/0x13
	 * COLOR_FormatYUV420SemiPlanar	= 21/0x15
	 * @param byteBuffer
	 * @param timestamp
	 * @param format
	 * @param width				宽
	 * @param height			高
	 * @param stride			行对齐
	 * @param sliceHeight		高对齐
	 */
	public void updateImage(ByteBuffer byteBuffer, int timestamp, int format, int width, int height, int stride, int sliceHeight) {
		this.timestamp = timestamp;
		this.format = format;
		this.width = width;
		this.height = height;

		if( LSConfig.DEBUG ) {
			Log.d(LSConfig.TAG,
					String.format("LSVideoHardDecoderFrame::updateImage( "
									+ "this : 0x%x, "
									+ "[Image info], "
									+ "format : 0x%x, "
									+ "width : %d, "
									+ "height : %d, "
									+ "stride : %d, "
									+ "sliceHeight : %d, "
									+ "timestamp : %d "
									+ ")",
							hashCode(),
							format,
							width,
							height,
							stride,
							sliceHeight,
							timestamp
					)
			);
		}

		// 解码器输出是否行字节对齐
		int rowStride = (stride - width);
		// 行字节对齐
		boolean bRowStride = (rowStride == 0);

        byteBuffer.position(0);
		int size = width * height;
		byteSizeY = size;
		if( byteBufferY == null || byteBufferY.length < byteSizeY ) {
			byteBufferY = new byte[byteSizeY];
		}

		if( bRowStride ) {
			// 不需要行字节对齐
			byteBuffer.get(byteBufferY, 0, byteSizeY);
		} else {
			// 需要行字节对齐
			int position = 0;
			for(int i = 0; i < height; i++) {
				byteBuffer.get(byteBufferY, position, width);
				byteBuffer.position(byteBuffer.position() + rowStride);
				position += width;
			}
		}

		// 高字节对齐, 跳过Y到UV的字节数
		int uvOffset = sliceHeight * stride;
		byteBuffer.position(uvOffset);

		if( LSConfig.DEBUG ) {
			Log.d(LSConfig.TAG,
					String.format("LSVideoHardDecoderFrame::updateImage( "
									+ "this : 0x%x, "
									+ "[Image info], "
									+ "uvOffset : %d "
									+ ")",
							hashCode(),
							uvOffset
					)
			);
		}

		switch ( format ) {
			case MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Planar: {
				// YYYY UUVV
				byteSizeU = size / 4;
				if( byteBufferU == null || byteBufferU.length < byteSizeU ) {
					byteBufferU = new byte[byteSizeU];
				}

				if( bRowStride ) {
					// 不需要行字节对齐
					byteBuffer.get(byteBufferU, 0, byteSizeU);
				} else {
					// 需要行字节对齐
					int position = 0;
					for(int i = 0; i < height / 4; i++) {
						byteBuffer.get(byteBufferU, position, width);
						byteBuffer.position(byteBuffer.position() + rowStride);
						position += width;
					}
				}

				byteSizeV = size / 4;
				if( byteBufferV == null || byteBufferV.length < byteSizeV ) {
					byteBufferV = new byte[byteSizeV];
				}

				if( bRowStride ) {
					// 不需要行字节对齐
					byteBuffer.get(byteBufferV, 0, byteSizeV);
				} else {
					// 需要行字节对齐
					int position = 0;
					for(int i = 0; i < height / 4; i++) {
						byteBuffer.get(byteBufferV, position, width);
						byteBuffer.position(byteBuffer.position() + rowStride);
						position += width;
					}
				}

//				if( LSConfig.DEBUG ) {
//					Log.d(LSConfig.TAG,
//							String.format("LSVideoHardDecoderFrame::updateImage( "
//											+ "this : 0x%x, "
//											+ "[Image data 420P], "
//											+ "[Y] : "
//											+ "size : %d, "
//											+ "[U] : "
//											+ "size : %d, "
//											+ "[V] : "
//											+ "size : %d "
//											+ ")",
//									hashCode(),
//									byteSizeY,
//									byteSizeU,
//									byteSizeV
//									)
//					);
//				}
			}break;
			case MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420SemiPlanar: {
				// YYYY UVUV
				byteSizeUV = size / 2;
				if( byteBufferUV == null || byteBufferUV.length < byteSizeUV ) {
					byteBufferUV = new byte[byteSizeUV];
				}

				if( bRowStride ) {
					// 不需要行字节对齐
					byteBuffer.get(byteBufferUV, 0, byteSizeUV);
				} else {
					// 需要行字节对齐
					int position = 0;
					for(int i = 0; i < height / 2; i++) {
						byteBuffer.get(byteBufferUV, position, width);
						byteBuffer.position(byteBuffer.position() + rowStride);
						position += width;
					}
				}

//				if( LSConfig.DEBUG ) {
//					Log.d(LSConfig.TAG,
//							String.format("LSVideoHardDecoderFrame::updateImage( "
//											+ "this : 0x%x, "
//											+ "[Image data 420SP], "
//											+ "[Y] : "
//											+ "size : %d, "
//											+ "[UV] : "
//											+ "size : %d "
//											+ ")",
//									hashCode(),
//									byteSizeY,
//									byteSizeUV
//									)
//					);
//				}
			}
		}
	}

	public void updateImage(Image image, int timestamp) {
		this.timestamp = timestamp;
		this.format = image.getFormat();
		this.width = image.getWidth();
		this.height = image.getHeight();

		Plane[] plane = image.getPlanes();
		
//		if( LSConfig.DEBUG ) {
//			/**
//			 * @see android.graphics.ImageFormat
//			 */
//			int cropLeft = image.getCropRect().left;
//			int cropTop = image.getCropRect().top;
//			int cropWidth = image.getCropRect().width();
//			int cropHeight = image.getCropRect().height();
//			int bitPerPixel = ImageFormat.getBitsPerPixel(format);
//	        Log.d(LSConfig.TAG,
//	        		String.format("LSVideoFrame::updateImage( "
//	        				+ "this : 0x%x, "
//	        				+ "[Image info], "
//	        				+ "format : 0x%x, "
//	        				+ "width : %d, "
//	        				+ "height : %d, "
//	        				+ "cropLeft : %d, "
//	        				+ "cropTop : %d, "
//	        				+ "cropWidth : %d, "
//	        				+ "cropHeight : %d, "
//	        				+ "bitPerPixel : %d, "
//							+ "timestamp : %d "
//	        				+ ")",
//	        				hashCode(),
//	        				format,
//	        				width,
//	        				height,
//	        				cropLeft,
//	        				cropTop,
//	        				cropWidth,
//	        				cropHeight,
//	        				bitPerPixel,
//							timestamp
//	        				)
//	        		);
//	        // Dump yuv data to file
////	        dumpYuvData(image);
//		}
		
		// Get Y
        int rowStrideY = plane[0].getRowStride();
        int pixelStrideY = plane[0].getPixelStride();
		
		ByteBuffer yBuffer = plane[0].getBuffer();
		yBuffer.position(0);
		byteSizeY = yBuffer.limit();
		if( byteBufferY == null || byteBufferY.length < byteSizeY ) {
			byteBufferY = new byte[byteSizeY];
		}
		yBuffer.get(byteBufferY, 0, byteSizeY);
		
		// Get U
        int rowStrideU = plane[1].getRowStride();
        int pixelStrideU = plane[1].getPixelStride();
        
		ByteBuffer uBuffer = plane[1].getBuffer();
		uBuffer.position(0);
		byteSizeU = uBuffer.limit();
		if( byteBufferU == null || byteBufferU.length < byteSizeU ) {
			byteBufferU = new byte[byteSizeU];
		}
		uBuffer.get(byteBufferU, 0, byteSizeU);
		
		// Get V
        int rowStrideV = plane[2].getRowStride();
        int pixelStrideV = plane[2].getPixelStride();
        
		ByteBuffer vBuffer = plane[2].getBuffer();
		vBuffer.position(0);
		byteSizeV = vBuffer.limit();
		if( byteBufferV == null || byteBufferV.length < byteSizeV ) {
			byteBufferV = new byte[byteSizeV];
		}
		vBuffer.get(byteBufferV, 0, byteSizeV);
		
//		if( LSConfig.DEBUG ) {
//	        Log.d(LSConfig.TAG,
//	        		String.format("LSVideoDecoder::updateImage( "
//	        				+ "this : 0x%x, "
//	        				+ "[Image data], "
//	        				+ "[Y] : "
//	        				+ "rowStride : %d, "
//	        				+ "pixelStride : %d, "
//	        				+ "size : %d, "
//	        				+ "[U] : "
//	        				+ "rowStride : %d, "
//	        				+ "pixelStride : %d, "
//	        				+ "size : %d, "
//	        				+ "[V] : "
//	        				+ "rowStride : %d, "
//	        				+ "pixelStride : %d, "
//	        				+ "size : %d "
//	        				+ ")",
//	        				this.hashCode(),
//	        				rowStrideY,
//	        				pixelStrideY,
//	        				byteSizeY,
//	        				rowStrideU,
//	        				pixelStrideU,
//	        				byteSizeU,
//	        				rowStrideV,
//	        				pixelStrideV,
//	        				byteSizeV
//	        				)
//	        		);
//		}
	}
	
	private void dumpYuvData(Image image) {
        // dump YUV together
		Plane[] planes = image.getPlanes();
        int total = planes[0].getBuffer().remaining() + planes[1].getBuffer().remaining() + planes[2].getBuffer().remaining();
        byte[] yuvBuffer = new byte[total];
        Log.d(LSConfig.TAG, 
        		String.format("LSVideoFrame::dumpYuvData( "
        				+ "yuvBuffer.length : %d "
        				+ ")", 
        				yuvBuffer.length
        				)
        		);
        int offset = 0;
        planes[0].getBuffer().get(yuvBuffer, offset, planes[0].getBuffer().remaining());
        offset += planes[0].getBuffer().remaining();
        planes[1].getBuffer().get(yuvBuffer, offset, planes[1].getBuffer().remaining());
        offset += planes[1].getBuffer().remaining();
        planes[2].getBuffer().get(yuvBuffer, offset, planes[2].getBuffer().remaining());
		offset += planes[2].getBuffer().remaining();
        LSImageUtil.saveYuvToFile("yuv", yuvBuffer, offset);
        
        planes[0].getBuffer().rewind();
        planes[1].getBuffer().rewind();
        planes[2].getBuffer().rewind();
	}
	
//    private byte[] getDataFromImage(Image image) {
//        Rect crop = image.getCropRect();
//        int format = image.getFormat();
//        int width = crop.width();
//        int height = crop.height();
//        int rowStride, pixelStride;
//        byte[] data = null;
//
//        // Read image data
//        Image.Plane[] planes = image.getPlanes();
//
//        // Check image validity
//        switch (format) {
//            case ImageFormat.YUV_420_888:
//                Log.d(LSConfig.TAG, String.format("LSVideoDecoder::getDataFromImage( format : YUV_420_888 )"));
//                break;
//            case ImageFormat.NV21:
//            	Log.d(LSConfig.TAG, String.format("LSVideoDecoder::getDataFromImage( format : NV21 )"));
//                break;
//            case ImageFormat.YV12:
//                Log.d(LSConfig.TAG, String.format("LSVideoDecoder::getDataFromImage( format : YV12 )"));
//                break;
//            default:
//                Log.e(LSConfig.TAG, String.format("LSVideoDecoder::getDataFromImage( Unsupported format : %d )", format));
//                return null;
//        }
//        if (((format == ImageFormat.YUV_420_888) || (format == ImageFormat.NV21)
//                ||(format == ImageFormat.YV12)) && (planes.length != 3)) {
//            Log.e(LSConfig.TAG, String.format("LSVideoDecoder::getDataFromImage( YUV420 format Images should have 3 planes )"));
//            return null;
//        }
//
//        ByteBuffer buffer = null;
//
//        int offset = 0;
//        data = new byte[width * height * ImageFormat.getBitsPerPixel(format) / 8];
//        Log.d(LSConfig.TAG, 
//        		String.format("LSVideoDecoder::getDataFromImage( "
//        		+ "deocde image w : %d, h : %d, byte : %d "
//        		+ ")",
//        		width,
//        		height,
//        		ImageFormat.getBitsPerPixel(format) / 8
//        		));
//        byte[] rowData = new byte[planes[0].getRowStride()];
//        for (int i = 0; i < planes.length; i++) {
//            int shift = (i == 0) ? 0 : 1;
//            buffer = planes[i].getBuffer();
//            rowStride = planes[i].getRowStride();
//            pixelStride = planes[i].getPixelStride();
//            // For multi-planar yuv images, assuming yuv420 with 2x2 chroma subsampling.
//            int w = crop.width() >> shift;
//            int h = crop.height() >> shift;
//			int pos = rowStride * (crop.top >> shift) + pixelStride * (crop.left >> shift);
//            buffer.position(pos);
//            for (int row = 0; row < h; row++) {
//                Log.d(LSConfig.TAG, 
//                		String.format("LSVideoDecoder::getDataFromImage( "
//                				+ "i : %d, "
//                				+ "w : %d, "
//                				+ "h : %d, "
//                				+ "pos : %d, "
//                				+ "offset : %d "
//                				+ ")",
//                				i,
//                				w,
//                				h,
//                				pos,
//                				offset
//                				));
//                
//                int bytesPerPixel = ImageFormat.getBitsPerPixel(format) / 8;
//                int length = 0;
//                if (pixelStride == bytesPerPixel) {
//                    // Special case: optimized read of the entire row
//                    length = w * bytesPerPixel;
//                    buffer.get(data, offset, length);
//                    offset += length;
//                } else {
//                    // Generic case: should work for any pixelStride but slower.
//                    // Use intermediate buffer to avoid read byte-by-byte from
//                    // DirectByteBuffer, which is very bad for performance
//                    length = (w - 1) * pixelStride + bytesPerPixel;
//                    buffer.get(rowData, 0, length);
//                    for (int col = 0; col < w; col++) {
//                        data[offset++] = rowData[col * pixelStride];
//                    }
//                }
//                // Advance buffer the remainder of the row stride
//                if (row < h - 1) {
//                    pos = buffer.position() + rowStride - length;
//                    buffer.position(pos);
//                }
//            }
//        }
//        
//        Log.d(LSConfig.TAG, 
//        		String.format("LSVideoFrame::getDataFromImage( "
//        				+ "data size : %d "
//        				+ ")", 
//        				data.length
//        				)
//        		);
//        
//        return data;
//    }
}
