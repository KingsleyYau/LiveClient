package net.qdating.dectection;

public interface ILSFaceDetectorCallbackJni {
	void onDetectedFace(byte[] data, int size, int x, int y, int width, int height);
}
