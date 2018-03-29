package net.qdating.player;

import net.qdating.LSPlayer;

/**
 * 流播放器状态回调接口
 * @author max
 *
 */
public interface ILSPlayerStatusCallback {
	/***
	 * 连接成功回调
	 * @param player 播放器
	 */
	public void onConnect(LSPlayer player);
	
	/***
	 * 断线回调
	 * @param player 播放器
	 */
	public void onDisconnect(LSPlayer player);
}
