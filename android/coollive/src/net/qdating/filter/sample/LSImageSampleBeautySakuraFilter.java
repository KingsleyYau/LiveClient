package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.beauty.LSImageSakuraFilter;

/**
 * 预设滤镜3
 */
public class LSImageSampleBeautySakuraFilter extends LSImageGroupFilter implements LSImageSampleBeautyBaseFilterEvent{
//    private LSImageBeautyFilter beautyFilter = null;
    private LSImageSampleBeautyBaseFilter beautyFilter = null;
    private LSImageSakuraFilter sakuraFilter = null;

    public LSImageSampleBeautySakuraFilter(Context context) {
//        beautyFilter = new LSImageBeautyFilter();
        beautyFilter = new LSImageSampleBeautyBaseFilter(context);
        this.addFilter(beautyFilter);
        sakuraFilter = new LSImageSakuraFilter(context);
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
