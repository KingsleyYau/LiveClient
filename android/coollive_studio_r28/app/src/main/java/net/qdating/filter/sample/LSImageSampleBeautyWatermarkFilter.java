package net.qdating.filter.sample;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import net.qdating.filter.LSImageBeautyFilter;
import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.LSImageVibrateFilter;
import net.qdating.filter.LSImageWaterMarkFilter;

import java.io.IOException;
import java.io.InputStream;

/**
 * 预设滤镜1
 * 1.美颜(柔和+加光+磨皮)
 * 2.水印
 * 3.红蓝随机偏振
 */
public class LSImageSampleBeautyWatermarkFilter extends LSImageGroupFilter implements LSImageSampleBeautyBaseFilterEvent{
    private LSImageBeautyFilter beautyFilter = new LSImageBeautyFilter(1.0f);
    private LSImageWaterMarkFilter waterMarkFilter = new LSImageWaterMarkFilter();
    private LSImageVibrateFilter vibrateFilter = new LSImageVibrateFilter();

    public LSImageSampleBeautyWatermarkFilter(Context context) {
        // 美颜(柔和+加光+磨皮)
        this.addFilter(beautyFilter);

        // 水印
        try {
            InputStream watermarkInputStream = context.getAssets().open("watermark/2.png");
            Bitmap watermarkBitmap = BitmapFactory.decodeStream(watermarkInputStream);
            watermarkInputStream.close();

            waterMarkFilter.updateBmpFrame(watermarkBitmap);
            waterMarkFilter.setWaterMarkRect(0.05f, 0.75f, 0.2f, 0.2f * watermarkBitmap.getHeight() / watermarkBitmap.getWidth());

        } catch (IOException e) {
            e.printStackTrace();
        }
        this.addFilter(waterMarkFilter);

        // 红蓝随机偏振
//        this.addFilter(vibrateFilter);
    }

    @Override
    public void setBeautyLevel(float beautyLevel) {
        beautyFilter.setBeautyLevel(beautyLevel);
    }

    @Override
    public void setStrength(float strength) {

    }

}
