package net.qdating.player;

/**
 * 视频渲染接口JNI
 * @author max
 *
 */
public interface ILSVideoRendererJni {
	/**
	 * 渲染一个视频帧
	 * @param data		帧数据
	 * @param size		帧大小
	 * @param width		帧宽度
	 * @param height	帧高度
	 */
	void renderVideoFrame(byte[] data, int size, int width, int height);
}
