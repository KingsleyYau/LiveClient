package net.qdating;

/***
 * 播放器状态回调
 * @author max
 *
 */
public interface ILSPlayerCallback {
	/***
	 * 断线回调
	 * @param player 播放器
	 */
	public void onDisconnect(LSPlayerJni player);
}
