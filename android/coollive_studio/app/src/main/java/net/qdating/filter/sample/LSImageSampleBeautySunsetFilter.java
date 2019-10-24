package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.LSConfig;
import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.beauty.LSImageSakuraFilter;
import net.qdating.filter.beauty.LSImageSunsetFilter;
import net.qdating.utils.Log;

/**
 * 预设滤镜3
 */
public class LSImageSampleBeautySunsetFilter extends LSImageGroupFilter {
    private LSImageSampleBeautyBaseFilter beautyFilter = null;
    private LSImageSunsetFilter sakuraFilter = null;

    public LSImageSampleBeautySunsetFilter(Context context) {
        beautyFilter = new LSImageSampleBeautyBaseFilter(context);
        this.addFilter(beautyFilter);
        sakuraFilter = new LSImageSunsetFilter(context);
        this.addFilter(sakuraFilter);
    }

    /**
     * 设置美颜等级
     * @param beautyLevel [0.0, 1.0]
     */
    public void setBeautyLevel(float beautyLevel) {
        beautyFilter.setBeautyLevel(beautyLevel);
    }
}
