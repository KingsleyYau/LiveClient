package net.qdating.player;

/**
 * 视频解码接口JNI
 * @author max
 *
 */
public interface ILSVideoHardDecoderJni {
	/**
	 * 解码视频关键帧
	 * @param sps
	 * @param sps_size
	 * @param pps
	 * @param pps_size
	 * @param naluHeaderSize
	 * @return
	 */
	public boolean decodeVideoKeyFrame(byte[] sps, int sps_size, byte[] pps, int pps_size, int naluHeaderSize);
	
	/**
	 * 解码视频帧
	 * @param data
	 * @param size
	 * @param timestamp
	 * @return
	 */
	public boolean decodeVideoFrame(byte[] data, int size, int timestamp);
	
	/**
	 * 获取一个已经解码的视频帧
	 * @return 视频帧
	 */
	public LSVideoHardDecoderFrame getDecodeVideoFrame();
	
	/**
	 * 释放已经解码的帧
	 * @param videoFrame 视频帧
	 */
	public void releaseVideoFrame(LSVideoHardDecoderFrame videoFrame);
}
