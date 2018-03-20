package net.qdating.filter;

public interface LSImageRecordFilterCallback {
	public void onRecordFrame(byte[] data, int size, int width, int height);
}
