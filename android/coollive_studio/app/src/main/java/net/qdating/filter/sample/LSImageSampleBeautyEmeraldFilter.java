package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.beauty.LSImageEmeraldFilter;

/**
 * 预设滤镜3
 */
public class LSImageSampleBeautyEmeraldFilter extends LSImageGroupFilter {
    private LSImageSampleBeautyBaseFilter beautyFilter = null;
    private LSImageEmeraldFilter emeraldFilter = null;

    public LSImageSampleBeautyEmeraldFilter(Context context) {
        beautyFilter = new LSImageSampleBeautyBaseFilter(context);
        this.addFilter(beautyFilter);
        emeraldFilter = new LSImageEmeraldFilter(context);
        this.addFilter(emeraldFilter);
    }

    /**
     * 设置美颜等级
     * @param beautyLevel [0.0, 1.0]
     */
    public void setBeautyLevel(float beautyLevel) {
        beautyFilter.setBeautyLevel(beautyLevel);
    }
}
