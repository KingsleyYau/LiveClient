package net.qdating.publisher;

import net.qdating.LSPublisher;

/**
 * 流播放器状态回调接口
 * @author max
 *
 */
public interface ILSPublisherStatusCallback {
	/***
	 * 断线回调
	 * @param player 播放器
	 */
	public void onDisconnect(LSPublisher publisher);
}
