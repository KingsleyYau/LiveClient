package net.qdating.publisher;

import net.qdating.LSPublisher;

/**
 * 流推送器状态回调接口
 * @author max
 *
 */
public interface ILSPublisherStatusCallback {
	/***
	 * 连接成功回调
	 * @param publisher 推流器
	 */
	public void onConnect(LSPublisher publisher);
	
	/***
	 * 断线回调
	 * @param publisher 推流器
	 */
	public void onDisconnect(LSPublisher publisher);

	/***
	 * 录制视频出错回调
	 * @param publisher 推流器
	 * @param error 错误码
	 */
	public void onVideoCaptureError(LSPublisher publisher, int error);

//	/***
//	 * 录制到视频帧回调
//	 * @param publisher 推流器
//	 * @param data 数据
//	 * @param size 数据大小
//	 * @param width 图像宽
//	 * @param height 图像高
//	 */
//	public void onVideoCapture(LSPublisher publisher, final byte[] data, int size, final int width, final int height);

	/***
	 * 推流出错回调
	 * @param publisher 推流器
	 * @param code 错误码
	 * @param description 错误提示
	 */
	public void onError(LSPublisher publisher, String code, String description);
}
