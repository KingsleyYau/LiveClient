package net.qdating.filter;

import android.graphics.Bitmap;
import android.opengl.GLES20;
import android.opengl.GLUtils;

import net.qdating.LSConfig;
import net.qdating.utils.Log;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

/**
 * 水印滤镜
 */
public class LSImageWaterMarkFilter extends LSImageInputFilter {
    // 水印纹理
	private int[] glWaterMarkTextureId = null;

	private float filterVertex[];
	private FloatBuffer glWaterMarkVertexBuffer = null;

	private Bitmap bitmap = null;

	public LSImageWaterMarkFilter() {
        super();
	}

	public void updateBmpFrame(Bitmap bitmap) {
		this.bitmap = bitmap;
	}

	/**
	 * 设置裁剪范围
	 * 所有参数范围为0.0-1.0, 左下为原点(0, 0)
	 * @param x			x坐标
	 * @param y			y坐标
	 * @param width		宽度
	 * @param height	高度
	 */
	public void setWaterMarkRect(float x, float y, float width, float height) {
		Log.i(LSConfig.TAG,
				String.format("LSImageWaterMarkFilter::setWaterMarkRect( "
								+ "x : %f, "
								+ "y : %f, "
								+ "width : %f, "
								+ "height : %f "
								+ ")",
						x,
						y,
						width,
						height
				)
		);

		filterVertex = new float[LSImageVertex.filterVertex_180.length];
		System.arraycopy(LSImageVertex.filterVertex_180, 0, filterVertex, 0, LSImageVertex.filterVertex_180.length);

		// 右上
		filterVertex[0] = -1f + 2f * (x + width);
		filterVertex[1] = 1f - 2f * y;
		// 左上
		filterVertex[4] = -1f + 2f * x;
		filterVertex[5] = 1f - 2f * y;
		// 左下
		filterVertex[8] = -1f + 2f * x;
		filterVertex[9] = 1f - 2f * (y + height);
		// 右上
		filterVertex[12] = -1f + 2f * (x + width);
		filterVertex[13] = 1f - 2f * y;
		// 左下
		filterVertex[16] = -1f + 2f * x;
		filterVertex[17] = 1f - 2f * (y + height);
		// 右下
		filterVertex[20] = -1f + 2f * (x + width);
		filterVertex[21] = 1f - 2f * (y + height);

		glWaterMarkVertexBuffer = ByteBuffer.allocateDirect(4 * filterVertex.length)
				.order(ByteOrder.nativeOrder())
				.asFloatBuffer();
		glWaterMarkVertexBuffer.put(filterVertex, 0, filterVertex.length);
		glWaterMarkVertexBuffer.position(0);
	}

	@Override
	public boolean changeViewPointSize(int viewPointWidth, int viewPointHeight) {
		boolean bChange = super.changeViewPointSize(viewPointWidth, viewPointHeight);
		if( bChange ) {
			// 创建FBO纹理
			glWaterMarkTextureId = LSImageFilter.genPixelTexture();
			// 绑定纹理
			GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, glWaterMarkTextureId[0]);
			// 创建空白纹理
			GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, viewPointWidth, viewPointHeight, 0,
					GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);
		}
		return bChange;
	}

	@Override
	protected void onDrawStart(int textureId) {
        super.onDrawStart(textureId);
	}

	@Override
	protected int onDrawFrame(int textureId) {
        int newTextureId = super.onDrawFrame(textureId);

		GLES20.glEnable(GLES20.GL_BLEND);
		GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA);
//		GLES20.glBlendFunc(GLES20.GL_SRC_COLOR, GLES20.GL_DST_ALPHA);
        // 绘制水印
		drawWaterMark();
		GLES20.glDisable(GLES20.GL_BLEND);

        return newTextureId;
	}

	@Override
	protected void onDrawFinish(int textureId) {
        super.onDrawFinish(textureId);
	}

	private void drawWaterMark() {
		if( glWaterMarkTextureId != null ) {
			// 绑定外部纹理到纹理单元GL_TEXTURE0
			GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, glWaterMarkTextureId[0]);

			// 顶点每次读取2个值, 每4个元素(4 * 4 = 16byte)为下一组顶点开始
			glWaterMarkVertexBuffer.position(0);
			GLES20.glVertexAttribPointer(getPosition(), 2, GLES20.GL_FLOAT, false, 16, glWaterMarkVertexBuffer);
			GLES20.glEnableVertexAttribArray(getPosition());

			// 填充着色器-纹理坐标
			// 纹理坐标每次读取2个值, 每4个元素(4 * 4 = 16byte)为下一组纹理坐标开始
			glWaterMarkVertexBuffer.position(2);
			GLES20.glVertexAttribPointer(getTextureCoordinate(), 2, GLES20.GL_FLOAT, false, 16, glWaterMarkVertexBuffer);
			GLES20.glEnableVertexAttribArray(getTextureCoordinate());

			// 填充着色器-颜色采样器, 将纹理单元GL_TEXTURE1绑元定到采样器
			GLES20.glUniform1i(getInputTexture(), 0);

			if( bitmap != null ) {
				GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bitmap, 0);
			}

			GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, 6);

			// 取消着色器参数绑定
			GLES20.glDisableVertexAttribArray(getPosition());
			GLES20.glDisableVertexAttribArray(getTextureCoordinate());
			GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
		}
	}
}
