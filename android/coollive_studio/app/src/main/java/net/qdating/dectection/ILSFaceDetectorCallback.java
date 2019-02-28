package net.qdating.dectection;

public interface ILSFaceDetectorCallback {
	void onDetectedFace(LSFaceDetectorJni detector, byte[] data, int size, int x, int y, int width, int height);
}
