package net.qdating.publisher;

import java.nio.ByteBuffer;

/**
 * 硬编码视频帧
 * @author max
 *
 */
public class LSVideoHardEncoderFrame {
	public int timestamp = -1;
	public byte[] data = null;
	public int size = 0;

	public LSVideoHardEncoderFrame() {

	}

	public void update(ByteBuffer byteBuffer, int timestamp) {
		this.timestamp = timestamp;
		
		byteBuffer.position(0);
		size = byteBuffer.remaining();
		if( data == null || data.length < size ) {
			data = new byte[size];
		}
		
		byteBuffer.get(data, 0, size);
	}
}
