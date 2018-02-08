package net.qdating.player;

/***
 * 推流器状态回调
 * @author max
 *
 */
public interface ILSPlayerCallback {
	/***
	 * 断线回调
	 * @param player 推流器
	 */
	public void onDisconnect(LSPlayerJni player);
}
