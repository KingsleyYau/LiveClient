package net.qdating.publisher;

/***
 * 推流器状态回调
 * @author max
 *
 */
public interface ILSPublisherCallback {
	/***
	 * 连接成功回调
	 * @param publisher 推流器
	 */
	public void onConnect(LSPublisherJni publisher);
	
	/***
	 * 断线回调
	 * @param publisher 推流器
	 */
	public void onDisconnect(LSPublisherJni publisher);

	/***
	 * 断线回调
	 * @param publisher 推流器
	 * @param code 错误码
	 * @param description 错误提示
	 */
	public void onError(LSPublisherJni publisher, String code, String description);
}
