package net.qdating.filter;

/**
 * 翻转滤镜
 * @author max
 *
 */
public class LSImageFlipFilter extends LSImageInputFilter {
	public enum FlipType {
		FlipType_Vertical,
		FlipType_Horizontal
	}

	static private float[] getFilterVertex(FlipType type) {
		float filterVertex[] = LSImageVertex.filterVertex_0;
		switch (type) {
			case FlipType_Vertical:{
				filterVertex = LSImageVertex.filterVertex_180;
			}break;
			case FlipType_Horizontal:{
				filterVertex = LSImageVertex.filterVertex_0;
			}break;
			default:break;
		}
		return filterVertex;
	}

	public LSImageFlipFilter(FlipType type) {
		super();
		updateVertexBuffer(getFilterVertex(type));
	}
}
