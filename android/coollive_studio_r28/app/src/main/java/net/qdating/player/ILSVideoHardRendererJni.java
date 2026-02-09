package net.qdating.player;

/**
 * 视频硬渲染接口JNI
 * @author max
 *
 */
public interface ILSVideoHardRendererJni {
	/**
	 * 渲染一个视频帧
	 * @param videoFrame		帧数据
	 */
	void renderVideoFrame(LSVideoHardDecoderFrame videoFrame);
}
