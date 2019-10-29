package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.beauty.LSImageHefeFilter;

/**
 * 预设滤镜3
 */
public class LSImageSampleBeautyHefeFilter extends LSImageGroupFilter implements LSImageSampleBeautyBaseFilterEvent {
//    private LSImageBeautyFilter beautyFilter = null;
    private LSImageSampleBeautyBaseFilter beautyFilter = null;
    private LSImageHefeFilter hefeFilter = null;

    public LSImageSampleBeautyHefeFilter(Context context) {
//        beautyFilter = new LSImageBeautyFilter();
        beautyFilter = new LSImageSampleBeautyBaseFilter(context);
        this.addFilter(beautyFilter);
        hefeFilter = new LSImageHefeFilter(context);
        this.addFilter(hefeFilter);
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
