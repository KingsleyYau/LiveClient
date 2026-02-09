package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.beauty.LSImageHealthyFilter;

/**
 * 预设滤镜3
 */
public class LSImageSampleBeautyHealthyFilter extends LSImageGroupFilter implements LSImageSampleBeautyBaseFilterEvent{
//    private LSImageBeautyFilter beautyFilter = null;
    private LSImageSampleBeautyBaseFilter beautyFilter = null;
    private LSImageHealthyFilter healthyFilter = null;

    public LSImageSampleBeautyHealthyFilter(Context context) {
//        beautyFilter = new LSImageBeautyFilter();
        beautyFilter = new LSImageSampleBeautyBaseFilter(context);
        this.addFilter(beautyFilter);
        healthyFilter = new LSImageHealthyFilter(context);
        this.addFilter(healthyFilter);
    }

    @Override
    public void setBeautyLevel(float beautyLevel) {
        beautyFilter.setBeautyLevel(beautyLevel);
    }

    @Override
    public void setStrength(float strength) {
        beautyFilter.setStrength(strength);
    }

}
