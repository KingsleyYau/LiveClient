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
}
