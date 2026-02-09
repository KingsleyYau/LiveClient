package net.qdating.filter.sample;

import android.content.Context;

import net.qdating.LSConfig;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.beauty.LSImageAdjustFilter;
import net.qdating.filter.beauty.LSImageBlur2Filter;
import net.qdating.filter.beauty.LSImageBlurFilter;
import net.qdating.filter.beauty.LSImageComplexionFilter;
import net.qdating.filter.beauty.LSImageHighPassFilter;
import net.qdating.utils.Log;

/**
 * 预设滤镜2
 */
public class LSImageSampleBeautyBaseFilter extends LSImageFilter implements LSImageSampleBeautyBaseFilterEvent {
    private LSImageComplexionFilter complexionFilter = null;
    private LSImageBlurFilter blurFilter = new LSImageBlurFilter();
    private LSImageBlurFilter blurFilterVertical = new LSImageBlurFilter(LSImageBlurFilter.FlipType.FlipType_Vertical);

    private LSImageHighPassFilter highPassFilter = new LSImageHighPassFilter();
    private LSImageBlur2Filter blurFilter2 = new LSImageBlur2Filter();
    private LSImageBlur2Filter blurFilterVertical2 = new LSImageBlur2Filter(LSImageBlur2Filter.FlipType.FlipType_Vertical);

    private LSImageAdjustFilter adjustFilter = new LSImageAdjustFilter();

    public LSImageSampleBeautyBaseFilter(Context context) {
        complexionFilter = new LSImageComplexionFilter(context);
    }

    public void init() {
        Log.d(LSConfig.TAG, String.format("LSImageSampleBeautyBaseFilter::init( this : 0x%x )", hashCode()));

        complexionFilter.init();
        blurFilter.init();
        blurFilterVertical.init();
        highPassFilter.init();

        blurFilter2.init();
        blurFilterVertical2.init();

        adjustFilter.init();
    }

    public void uninit() {
        Log.d(LSConfig.TAG, String.format("LSImageSampleBeautyBaseFilter::uninit( this : 0x%x )", hashCode()));

        complexionFilter.uninit();
        blurFilter.uninit();
        blurFilterVertical.uninit();
        highPassFilter.uninit();

        blurFilter2.uninit();
        blurFilterVertical2.uninit();

        adjustFilter.uninit();
    }


    @Override
    public void setBeautyLevel(float beautyLevel) {
        adjustFilter.setBeautyLevel(beautyLevel);
    }

    @Override
    public void setStrength(float strength) {
        complexionFilter.setStrength(strength);
    }

    @Override
    protected void onDrawStart(int textureId) {

    }

    @Override
    protected int onDrawFrame(int textureId) {
        int newTextureId = textureId;

        /**
         * 1.输入纹理处理
         */
        newTextureId = complexionFilter.draw(newTextureId, inputWidth, inputHeight);

        /**
         * 2.做高反差保留处理
         * a.高斯模糊
         * b.高通滤波
         * c.高通滤波纹理做高斯模糊处理, 去掉边沿细节
         * d.利用前2步得出的结果进行高反差调节
         */
        // a.高斯模糊
        int blurTextureId = blurFilter.draw(newTextureId, inputWidth, inputHeight);
        blurTextureId = blurFilterVertical.draw(blurTextureId, inputWidth, inputHeight);

        // b.高通滤波
        highPassFilter.setBlurTexture(blurTextureId);
        int highTextureId = highPassFilter.draw(newTextureId, inputWidth, inputHeight);

        // c.高通滤波纹理做高斯模糊处理, 去掉边沿细节
        int blurTextureId2 = blurFilter2.draw(highTextureId, inputWidth, inputHeight);
        blurTextureId2 = blurFilterVertical2.draw(blurTextureId2, inputWidth, inputHeight);

        // d.利用前2步得出的结果进行高反差调节
        adjustFilter.setBlurTexture(blurTextureId, blurTextureId2);
        newTextureId = adjustFilter.draw(newTextureId, inputWidth, inputHeight);

        return newTextureId;
    }

    @Override
    protected void onDrawFinish(int textureId) {

    }

}
