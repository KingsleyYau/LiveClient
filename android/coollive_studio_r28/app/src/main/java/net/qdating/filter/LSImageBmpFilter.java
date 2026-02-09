package net.qdating.filter;

import android.graphics.Bitmap;
import android.opengl.GLES20;
import android.opengl.GLUtils;

/**
 * BMP渲染滤镜
 * @author max
 *
 */
public class LSImageBmpFilter extends LSImageInputFilter {
	private Bitmap bitmap = null;

	public LSImageBmpFilter() {
		super();
		updateVertexBuffer(LSImageVertex.filterVertex_180);
	}

	public void updateBmpFrame(Bitmap bitmap) {
		this.bitmap = bitmap;
	}

	public Bitmap getBitmap() {
		return bitmap;
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
