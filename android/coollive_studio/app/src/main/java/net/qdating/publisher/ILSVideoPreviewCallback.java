package net.qdating.publisher;

import android.graphics.SurfaceTexture;
import android.graphics.SurfaceTexture.OnFrameAvailableListener;

public interface ILSVideoPreviewCallback extends OnFrameAvailableListener {
	public void onCreateTexture(SurfaceTexture surfaceTexture);
	public void onRenderFrame(byte[] data, int size, int width, int height);
}
