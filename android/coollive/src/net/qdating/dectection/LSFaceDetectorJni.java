package net.qdating.dectection;

import net.qdating.LSConfig;
import net.qdating.utils.Log;

public class LSFaceDetectorJni implements ILSFaceDetectorCallbackJni {
	static {
		System.loadLibrary("opencv_java3");
		System.loadLibrary("lsfddb");
		Log.i(LSConfig.TAG, String.format("LSFaceDectection::static( Load Library, version : %s )", LSConfig.VERSION));
	}

	/**
	 * 无效的指针
	 */
	private static long INVALID_OBJECT = 0;

	/**
	 * C实例指针
	 */
	private long detector = INVALID_OBJECT;

	/**
	 * 状态回调
	 */
	ILSFaceDetectorCallback callback = null;

	/**
	 * 创建实例
	 * @param callback		检测回调
	 */
	public boolean Create(
			ILSFaceDetectorCallback callback
	) {
		// 状态回调
		this.callback = callback;

		detector = Create(this);
		return detector != INVALID_OBJECT;
	}

	/**
	 * 创建实例
	 * @param callback		检测回调
	 */
	public native long Create(ILSFaceDetectorCallbackJni callback);

	/**
	 * 销毁实例
	 */
	public void Destroy() {
		if( detector != INVALID_OBJECT ) {
			Destroy(detector);
			detector = INVALID_OBJECT;
		}
	}
	/**
	 * 销毁实例
	 * @param detector	实例指针
	 */
	private native void Destroy(long detector);

	/**
	 * 检测图片中的人脸
	 * @param width		图片宽度
	 * @param height	图片高度
	 * @param data		图片数据
	 */
	public void DetectPicture(byte[] data, int size, int width, int height) {
		if( detector != INVALID_OBJECT ) {
			DetectPicture(detector, data, size, width, height);
		}
	}
	public native void DetectPicture(long detector, byte[] data, int size, int width, int height);

	@Override
	public void onDetectedFace(byte[] data, int size, int x, int y, int width, int height) {
		// TODO Auto-generated method stub
		if( callback != null ) {
			callback.onDetectedFace(this, data, size, x, y, width, height);
		}
	}
}
