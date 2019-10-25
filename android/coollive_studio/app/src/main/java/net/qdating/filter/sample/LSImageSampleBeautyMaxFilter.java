package net.qdating.filter.sample;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import net.qdating.filter.LSImageBeautyFilter;
import net.qdating.filter.LSImageBmpFilter;
import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.LSImageVibrateFilter;
import net.qdating.filter.LSImageWaterMarkFilter;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

/**
 * 预设滤镜1
 * 1.美颜(柔和+加光+磨皮)
 * 2.水印
 * 3.红蓝随机偏振
 */
public class LSImageSampleBeautyMaxFilter extends LSImageGroupFilter {
    private LSImageBeautyFilter beautyFilter = new LSImageBeautyFilter(1.0f);
    private LSImageWaterMarkFilter waterMarkFilter = new LSImageWaterMarkFilter();
    private LSImageVibrateFilter vibrateFilter = new LSImageVibrateFilter();

    public LSImageSampleBeautyMaxFilter(Context context) {
        // 美颜(柔和+加光+磨皮)
        this.addFilter(beautyFilter);

//        // 水印
//        File imgFile = new File("/sdcard/face_dectected/watermark.png");
//        if(imgFile.exists()) {
//            Bitmap bitmap = BitmapFactory.decodeFile(imgFile.getAbsolutePath());
//            waterMarkFilter.updateBmpFrame(bitmap);
//        }
//        waterMarkFilter.setWaterMarkRect(0.05f, 0.75f, 0.2f, 0.2f);
//        this.addFilter(waterMarkFilter);

        // 红蓝随机偏振
//        this.addFilter(vibrateFilter);
    }
}
