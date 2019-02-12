package net.qdating.publisher;

public interface ILSVideoCaptureCallback {
	public void onChangeRotation(int rotation);
	public void onVideoCapture(byte[] data, int size, int width, int height);
	public void onVideoCaptureError(int error);
}
