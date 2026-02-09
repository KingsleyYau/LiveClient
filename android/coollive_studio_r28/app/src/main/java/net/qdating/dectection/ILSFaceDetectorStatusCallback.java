package net.qdating.dectection;

public interface ILSFaceDetectorStatusCallback {
	void onDetectedFace(byte[] data, int size, int x, int y, int width, int height);
}
