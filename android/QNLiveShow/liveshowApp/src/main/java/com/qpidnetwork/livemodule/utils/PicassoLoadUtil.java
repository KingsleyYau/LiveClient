package com.qpidnetwork.livemodule.utils;

import android.support.annotation.DrawableRes;
import android.text.TextUtils;
import android.widget.ImageView;

import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.io.File;

/**
 * Created by Hardy on 2018/9/19.
 */
public class PicassoLoadUtil {

    private PicassoLoadUtil() {
    }

    public static void loadUrl(ImageView imageView, String url) {
//        Picasso.with(imageView.getContext())
        if(TextUtils.isEmpty(url)){
            return;
        }

        Picasso.get()
                .load(url)
                .into(imageView);
    }

    public static void loadUrlNoMCache(ImageView imageView, String url) {
//        Picasso.with(imageView.getContext())
        if(TextUtils.isEmpty(url)){
            return;
        }

        Picasso.get()
                .load(url)
                .memoryPolicy(MemoryPolicy.NO_CACHE)
                .into(imageView);
    }



    public static void loadUrl(ImageView imageView, String url, int defaultResId) {
//        Picasso.with(imageView.getContext())
        if(TextUtils.isEmpty(url)){
            loadRes(imageView, defaultResId);
            return;
        }

        Picasso.get()
                .load(url)
                .placeholder(defaultResId)
                .error(defaultResId)
                .into(imageView);
    }

    public static void loadUrlNoMCache(ImageView imageView, String url, int defaultResId) {
//        Picasso.with(imageView.getContext())
        if(TextUtils.isEmpty(url)){
            loadRes(imageView, defaultResId);
            return;
        }

        Picasso.get()
                .load(url)
                .placeholder(defaultResId)
                .error(defaultResId)
                .memoryPolicy(MemoryPolicy.NO_CACHE)
                .into(imageView);
    }


    public static void loadUrl(ImageView imageView, String url, int defaultResId, int targetW, int targetH) {
//        Picasso.with(imageView.getContext())
        if(TextUtils.isEmpty(url)){
            loadRes(imageView, defaultResId);
            return;
        }

        Picasso.get()
                .load(url)
                .placeholder(defaultResId)
                .resize(targetW, targetH)
                .onlyScaleDown()            // onlyScaleDown 配合着 上面的 Resize 一起使用，使得，当获得的图片大小，大于我们使用 Resize 设置的大小时，才起作用。
                .centerCrop()
                .into(imageView);
    }

    public static void loadUrlNoMCache(ImageView imageView, String url, int defaultResId, int targetW, int targetH) {
//        Picasso.with(imageView.getContext())
        if(TextUtils.isEmpty(url)){
            loadRes(imageView, defaultResId);
            return;
        }

        Picasso.get()
                .load(url)
                .placeholder(defaultResId)
                .resize(targetW, targetH)
                .onlyScaleDown()
                .centerCrop()   //add by Jagger 2018-12-25 解决头像被拉伸的问题 BUG#15549
                .memoryPolicy(MemoryPolicy.NO_CACHE)
                .into(imageView);
    }



    public static void loadRes(ImageView imageView, @DrawableRes int resId) {
//        Picasso.with(imageView.getContext())
        Picasso.get()
                .load(resId)
                .into(imageView);
    }

    public static void loadLocal(ImageView imageView, int defaultResId, String path) {
//        Picasso.with(imageView.getContext())
        Picasso.get()
                .load(new File(path))
                .placeholder(defaultResId)
                .into(imageView);
    }

}
