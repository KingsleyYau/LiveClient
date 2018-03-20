package net.qdating.filter;

import android.graphics.Bitmap;
import android.opengl.GLES20;
import android.opengl.GLUtils;

public class LSImageRawBmpFilter extends LSImageRawTextureFilter {
	private Bitmap bitmap = null;
	public LSImageRawBmpFilter() {
		
	}
	
	public void updateBmpFrame(Bitmap bitmap) {
		this.bitmap = bitmap;
	}
	
	@Override
	protected int onDrawFrame(int textureId) {
		// 绘制
		if( bitmap != null ) {
			GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bitmap, 0);
		}
		return super.onDrawFrame(textureId);
	}
}
