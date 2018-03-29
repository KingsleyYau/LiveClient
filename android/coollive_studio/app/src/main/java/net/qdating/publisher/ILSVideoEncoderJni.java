package net.qdating.publisher;

import net.qdating.player.LSVideoHardDecoderFrame;

/**
 * 视频解码接口JNI
 * @author max
 *
 */
public interface ILSVideoEncoderJni {
	/**
	 * 重置编码器
	 * @param width				视频帧宽
	 * @param height 			视频帧高
	 * @param bitRate			码率
	 * @param keyFrameInterval	关键帧间隔
	 * @param fps				帧率
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
	public LSVideoHardDecoderFrame getEncodeVideoFrame();
	
	/**
	 * 释放已经编码的帧
	 * @param byteBufferIndex
	 */
	public void releaseVideoFrame(int byteBufferIndex);
}
