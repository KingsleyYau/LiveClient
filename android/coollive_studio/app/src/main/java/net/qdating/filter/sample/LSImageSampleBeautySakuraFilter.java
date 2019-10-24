package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.beauty.LSImageLomoFilter;
import net.qdating.filter.beauty.LSImageSakuraFilter;

/**
 * 预设滤镜3
 */
public class LSImageSampleBeautySakuraFilter extends LSImageGroupFilter {
    private LSImageSampleBeautyBaseFilter beautyFilter = null;
    private LSImageSakuraFilter sakuraFilter = null;

    public LSImageSampleBeautySakuraFilter(Context context) {
        beautyFilter = new LSImageSampleBeautyBaseFilter(context);
        this.addFilter(beautyFilter);
        sakuraFilter = new LSImageSakuraFilter(context);
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
