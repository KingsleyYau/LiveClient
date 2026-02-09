package net.qdating.publisher;

/**
 * 视频解码接口JNI
 * @author max
 *
 */
public interface ILSVideoHardEncoderJni {
	/**
	 * 重置编码器
	 * @param width
	 * @param height
	 * @param bitRate
	 * @param keyFrameInterval
	 * @param fps
	 * @return
	 */
	public boolean reset(int width, int height, int bitRate, int keyFrameInterval, int fps);
	
	/**
	 * 暂停编码器
	 */
	public void pause();
	
	/**
	 * 编码视频帧
	 * @param data
	 * @param size
	 * @return
	 */
	public boolean encodeVideoFrame(byte[] data, int size);
	
	/**
	 * 获取一个已经编码的视频帧
	 * @return
	 */
	public LSVideoHardEncoderFrame getEncodeVideoFrame();

	/**
	 * 释放已经编码的帧
	 * @param videoFrame 视频帧
	 */
	public void releaseVideoFrame(LSVideoHardEncoderFrame videoFrame);

}
