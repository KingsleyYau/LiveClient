package net.qdating.publisher;

/***
 * 播放器状态回调JNI
 * @author max
 *
 */
public interface ILSPublisherCallbackJni {
	public void onConnect();
	public void onDisconnect();
	public void onError(String code, String description);
}
