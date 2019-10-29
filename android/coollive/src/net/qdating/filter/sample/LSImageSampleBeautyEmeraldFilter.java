package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.beauty.LSImageEmeraldFilter;

/**
 * 预设滤镜3
 */
public class LSImageSampleBeautyEmeraldFilter extends LSImageGroupFilter implements LSImageSampleBeautyBaseFilterEvent{
//    private LSImageBeautyFilter beautyFilter = null;
    private LSImageSampleBeautyBaseFilter beautyFilter = null;
    private LSImageEmeraldFilter emeraldFilter = null;

    public LSImageSampleBeautyEmeraldFilter(Context context) {
//        beautyFilter = new LSImageBeautyFilter();
        beautyFilter = new LSImageSampleBeautyBaseFilter(context);
        this.addFilter(beautyFilter);
        emeraldFilter = new LSImageEmeraldFilter(context);
        this.addFilter(emeraldFilter);
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
