package net.qdating.publisher;

/***
 * 推流器状态回调
 * @author max
 *
 */
public interface ILSPublisherCallback {
	/***
	 * 断线回调
	 * @param publisher 推流器
	 */
	public void onDisconnect(LSPublisherJni publisher);
}
