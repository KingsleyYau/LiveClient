package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.beauty.LSImageSunsetFilter;

/**
 * 预设滤镜3
 */
public class LSImageSampleBeautySunsetFilter extends LSImageGroupFilter implements LSImageSampleBeautyBaseFilterEvent{
//    private LSImageBeautyFilter beautyFilter = null;
    private LSImageSampleBeautyBaseFilter beautyFilter = null;
    private LSImageSunsetFilter sakuraFilter = null;

    public LSImageSampleBeautySunsetFilter(Context context) {
//        beautyFilter = new LSImageBeautyFilter();
        beautyFilter = new LSImageSampleBeautyBaseFilter(context);
        this.addFilter(beautyFilter);
        sakuraFilter = new LSImageSunsetFilter(context);
        this.addFilter(sakuraFilter);
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
