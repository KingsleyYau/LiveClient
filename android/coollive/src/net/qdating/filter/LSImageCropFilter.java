package net.qdating.filter;

import net.qdating.utils.Log;

import net.qdating.LSConfig;

/**
 * 裁剪滤镜
 * @author max
 *
 */
public class LSImageCropFilter extends LSImageInputFilter {
    private float width = 1f;
    private float height = 1f;
	private float filterVertex[];
	private boolean bChange = false;

	static private int bTest;

	public LSImageCropFilter() {
		super();
	}

	/**
	 * 设置裁剪范围
	 * 所有参数范围为0.0-1.0, 左下为原点(0, 0)
	 * @param x			x坐标
	 * @param y			y坐标
	 * @param width		宽度
	 * @param height	高度
	 */
	public void setCropRect(float x, float y, float width, float height) {
		Log.d(LSConfig.TAG,
				String.format("LSImageCropFilter::setCropRect( "
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

	    this.width = width;
	    this.height = height;

		filterVertex = new float[LSImageVertex.filterVertex_0.length];
		System.arraycopy(LSImageVertex.filterVertex_0, 0, filterVertex, 0, LSImageVertex.filterVertex_0.length);

		// 右上
		filterVertex[2] = (x + width);
		filterVertex[3] = (y + height);
		// 左上
		filterVertex[6] = x;
		filterVertex[7] = (y + height);
		// 左下
		filterVertex[10] = x;
		filterVertex[11] = y;
		// 右上
		filterVertex[14] = (x + width);
		filterVertex[15] = (y + height);
		// 左下
		filterVertex[18] = x;
		filterVertex[19] = y;
		// 右下
		filterVertex[22] = (x + width);
		filterVertex[23] = y;

		updateVertexBuffer(filterVertex);
	}

	@Override
	protected ImageSize changeInputSize(int inputWidth, int inputHeight) {
		ImageSize imageSize = super.changeInputSize((int)(inputWidth * width), (int)(inputHeight * height));
		return imageSize;
	}
}
