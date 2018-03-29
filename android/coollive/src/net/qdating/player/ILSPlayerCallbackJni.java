package net.qdating.player;

/***
 * 播放器状态回调JNI
 * @author max
 *
 */
public interface ILSPlayerCallbackJni {
	public void onConnect();
	public void onDisconnect();
	public void onPlayerOnDelayMaxTime();
}
