package net.qdating.player;

/***
 * 推流器状态回调
 * @author max
 *
 */
public interface ILSPlayerCallback {
	/***
	 * 连接成功回调
	 * @param player 播放器
	 */
	public void onConnect(LSPlayerJni player);
	/***
	 * 断线回调
	 * @param player 播放器
	 */
	public void onDisconnect(LSPlayerJni player);
	/**
	 * 播放延迟回调
	 * @param player 播放器
	 */
	public void onPlayerOnDelayMaxTime(LSPlayerJni player);
	
}
