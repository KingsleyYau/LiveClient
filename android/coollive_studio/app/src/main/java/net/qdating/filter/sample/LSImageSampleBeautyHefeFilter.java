package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.beauty.LSImageHealthyFilter;
import net.qdating.filter.beauty.LSImageHefeFilter;

/**
 * 预设滤镜3
 */
public class LSImageSampleBeautyHefeFilter extends LSImageGroupFilter {
    private LSImageSampleBeautyBaseFilter beautyFilter = null;
    private LSImageHefeFilter hefeFilter = null;

    public LSImageSampleBeautyHefeFilter(Context context) {
        beautyFilter = new LSImageSampleBeautyBaseFilter(context);
        this.addFilter(beautyFilter);
        hefeFilter = new LSImageHefeFilter(context);
        this.addFilter(hefeFilter);
    }

    /**
     * 设置美颜等级
     * @param beautyLevel [0.0, 1.0]
     */
    public void setBeautyLevel(float beautyLevel) {
        beautyFilter.setBeautyLevel(beautyLevel);
    }
}
