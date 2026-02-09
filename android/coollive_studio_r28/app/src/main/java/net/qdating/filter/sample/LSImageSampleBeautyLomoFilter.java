package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.beauty.LSImageLomoFilter;

/**
 * 预设滤镜3
 */
public class LSImageSampleBeautyLomoFilter extends LSImageGroupFilter implements LSImageSampleBeautyBaseFilterEvent{
//    private LSImageBeautyFilter beautyFilter = null;
    private LSImageSampleBeautyBaseFilter beautyFilter = null;
    private LSImageLomoFilter lomoFilter = null;

    public LSImageSampleBeautyLomoFilter(Context context) {
//        beautyFilter = new LSImageBeautyFilter();
        beautyFilter = new LSImageSampleBeautyBaseFilter(context);
        this.addFilter(beautyFilter);
        lomoFilter = new LSImageLomoFilter(context);
        this.addFilter(lomoFilter);
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
