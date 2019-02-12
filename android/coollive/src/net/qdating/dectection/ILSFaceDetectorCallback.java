package net.qdating.dectection;

public interface ILSFaceDetectorCallback {
	void onDetectedFace(LSFaceDetectorJni detector, int x, int y, int width, int height);
}
