package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.beauty.LSImageHefeFilter;
import net.qdating.filter.beauty.LSImageLomoFilter;

/**
 * 预设滤镜3
 */
public class LSImageSampleBeautyLomoFilter extends LSImageGroupFilter {
    private LSImageSampleBeautyBaseFilter beautyFilter = null;
    private LSImageLomoFilter lomoFilter = null;

    public LSImageSampleBeautyLomoFilter(Context context) {
        beautyFilter = new LSImageSampleBeautyBaseFilter(context);
        this.addFilter(beautyFilter);
        lomoFilter = new LSImageLomoFilter(context);
        this.addFilter(lomoFilter);
    }

    /**
     * 设置美颜等级
     * @param beautyLevel [0.0, 1.0]
     */
    public void setBeautyLevel(float beautyLevel) {
        beautyFilter.setBeautyLevel(beautyLevel);
    }
}
