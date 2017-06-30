package net.qdating;

/**
 * 硬解码视频帧
 * @author max
 *
 */
public class LSVideoFrame {
	public int bufferIndex = -1;
	public int timestamp = -1;
	public byte[] data;
	public int size = 0;
	public int width = 0;
	public int height = 0;
	
	public LSVideoFrame() {

	}
}
