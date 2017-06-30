package net.qdating;

/**
 * 流播放器状态回调接口
 * @author max
 *
 */
public interface ILSPlayerStatusCallback {
	/***
	 * 断线回调
	 * @param player 播放器
	 */
	public void onDisconnect(LSPlayer player);
}
