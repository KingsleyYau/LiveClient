package net.qdating.dectection;

public interface ILSFaceDetectorStatusCallback {
	void onDetectedFace(int x, int y, int width, int height);
}
