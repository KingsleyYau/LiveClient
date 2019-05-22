package com.qpidnetwork.livemodule.utils;

import android.content.Context;
import android.graphics.PointF;
import android.net.Uri;
import android.support.annotation.ColorInt;
import android.support.annotation.ColorRes;
import android.support.annotation.DrawableRes;
import android.widget.ImageView;

import com.facebook.common.util.UriUtil;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.generic.RoundingParams;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.common.ResizeOptions;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.qpidnetwork.livemodule.R;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.io.File;

/**
 * Fresco加载图片工具
 * Created by Jagger on 2019/4/12.
 */
public class FrescoLoadUtil {

    //------------------------ 加载网络 start -----------------------

    /**
     * 左上角对齐; 以长边比例裁剪; 下载图片时按大小压缩，减小内存使用; 可圆边;
     * @param context
     * @param imageView
     * @param url
     * @param size  图像大小(压缩、裁剪图片)
     * @param placeholderResId 占位图ID
     * @param isCircle 是否圆型
     */
    public static void loadUrl(Context context, SimpleDraweeView imageView, String url, int size, @DrawableRes int placeholderResId, boolean isCircle) {
        loadUrl(context, imageView, url, size, placeholderResId, isCircle , 0, 0, 0, 0);
    }

    /**
     * 左上角对齐; 以长边比例裁剪; 下载图片时按大小压缩，减小内存使用; 可圆边;
     * @param context
     * @param imageView
     * @param url
     * @param size  图像大小(压缩、裁剪图片)
     * @param placeholderResId 占位图ID
     * @param isCircle 是否圆型
     */
    public static void loadUrl(Context context, SimpleDraweeView imageView, String url, int size, @DrawableRes int placeholderResId, boolean isCircle, float border, @ColorInt int color) {
        loadUrl(context, imageView, url, size, placeholderResId, isCircle , border, color, 0, 0, 0, 0);
    }

    /**
     * 左上角对齐; 以长边比例裁剪; 下载图片时按大小压缩，减小内存使用; 可圆边圆角;
     * @param context
     * @param imageView
     * @param url
     * @param size  图像大小(压缩、裁剪图片)
     * @param placeholderResId 占位图ID
     * @param isCircle 是否圆型
     * @param topLeftRadius 圆角弧度（非圆型时生效）
     * @param topRightRadius 圆角弧度（非圆型时生效）
     * @param bottomRightRadius 圆角弧度（非圆型时生效）
     * @param bottomLeftRadius 圆角弧度（非圆型时生效）
     */
    public static void loadUrl(Context context, SimpleDraweeView imageView, String url, int size, @DrawableRes int placeholderResId, boolean isCircle, float topLeftRadius, float topRightRadius, float bottomLeftRadius, float bottomRightRadius) {
        loadUrl(context, imageView, url, size, placeholderResId, isCircle , 0, -1, topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius);
    }

    /**
     * 左上角对齐; 以长边比例裁剪; 下载图片时按大小压缩，减小内存使用; 可圆边圆角;
     * @param context
     * @param imageView
     * @param url
     * @param size  图像大小(压缩、裁剪图片)
     * @param placeholderResId 占位图ID
     * @param isCircle 是否圆型
     * @param topLeftRadius 圆角弧度（非圆型时生效）
     * @param topRightRadius 圆角弧度（非圆型时生效）
     * @param bottomRightRadius 圆角弧度（非圆型时生效）
     * @param bottomLeftRadius 圆角弧度（非圆型时生效）
     */
    public static void loadUrl(Context context, SimpleDraweeView imageView, String url, int size, @DrawableRes int placeholderResId, boolean isCircle, float border, @ColorInt int color, float topLeftRadius, float topRightRadius, float bottomLeftRadius, float bottomRightRadius) {
        //对齐方式(左上角对齐)
        PointF focusPoint = new PointF();
        focusPoint.x = 0f;
        focusPoint.y = 0f;

        //占位图，拉伸方式
        GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(context.getResources());
        GenericDraweeHierarchy hierarchy = builder
                .setFadeDuration(300)
                .setPlaceholderImage(placeholderResId)    //占位图
                .setPlaceholderImageScaleType(ScalingUtils.ScaleType.FIT_XY)    //占位图拉伸
                .setActualImageFocusPoint(focusPoint)
                .setActualImageScaleType(ScalingUtils.ScaleType.FOCUS_CROP)     //图片拉伸（配合上面的focusPoint）
                .build();
        imageView.setHierarchy(hierarchy);

        //下载
        Uri imageUri = Uri.parse(url);
        ImageRequest request = ImageRequestBuilder.newBuilderWithSource(imageUri)
                .setResizeOptions(new ResizeOptions(size, size))
                .build();
        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setImageRequest(request)
                .setOldController(imageView.getController())
                .setControllerListener(new BaseControllerListener<ImageInfo>())
                .build();
        imageView.setController(controller);

        if(isCircle){
            //圆
            RoundingParams roundingParams = RoundingParams.fromCornersRadius(0);
            roundingParams.setRoundAsCircle(true);
            if(border > 0 && color != 0){
                roundingParams.setBorder(color, border);
            }
            imageView.getHierarchy().setRoundingParams(roundingParams);
        }else {
            //圆角
            RoundingParams roundingParams = RoundingParams.fromCornersRadius(0);
            roundingParams.setCornersRadii(topLeftRadius, topRightRadius, bottomRightRadius, bottomLeftRadius);
            imageView.getHierarchy().setRoundingParams(roundingParams);
        }
    }

    /**
     * 下载图片时按大小压缩，减小内存使用;
     * @param imageView
     * @param url
     * @param size  图像大小(压缩、裁剪图片)
     */
    public static void loadUrl(SimpleDraweeView imageView, String url, int size) {
        //下载
        Uri imageUri = Uri.parse(url);
        ImageRequest request = ImageRequestBuilder.newBuilderWithSource(imageUri)
                .setResizeOptions(new ResizeOptions(size, size))
                .build();
        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setImageRequest(request)
                .setOldController(imageView.getController())
                .setControllerListener(new BaseControllerListener<ImageInfo>())
                .build();
        imageView.setController(controller);

    }

    //------------------------ 加载网络 end -----------------------

    //------------------------ 加载本地 start -----------------------

    /**
     * 左上角对齐; 以长边比例裁剪; 可圆边圆角;
     * @param context
     * @param imageView
     * @param imageResId
     * @param placeholderResId 占位图ID
     * @param isCircle 是否圆型
     */
    public static void loadRes(Context context, SimpleDraweeView imageView, @DrawableRes int imageResId, @DrawableRes int placeholderResId, boolean isCircle, float border, @ColorInt int color) {
        loadRes(context, imageView, imageResId, placeholderResId, isCircle , border, color, 0, 0, 0, 0);
    }

    /**
     * 左上角对齐; 以长边比例裁剪; 可圆边圆角;
     * @param context
     * @param imageView
     * @param imageResId
     * @param placeholderResId 占位图ID
     * @param isCircle 是否圆型
     * @param topLeftRadius 圆角弧度（非圆型时生效）
     * @param topRightRadius 圆角弧度（非圆型时生效）
     * @param bottomRightRadius 圆角弧度（非圆型时生效）
     * @param bottomLeftRadius 圆角弧度（非圆型时生效）
     */
    public static void loadRes(Context context, SimpleDraweeView imageView, @DrawableRes int imageResId, @DrawableRes int placeholderResId, boolean isCircle, float border, @ColorInt int color, float topLeftRadius, float topRightRadius, float bottomLeftRadius, float bottomRightRadius) {
        //对齐方式(左上角对齐)
        PointF focusPoint = new PointF();
        focusPoint.x = 0f;
        focusPoint.y = 0f;

        //占位图，拉伸方式
        GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(context.getResources());
        GenericDraweeHierarchy hierarchy = builder
                .setFadeDuration(300)
                .setPlaceholderImage(placeholderResId)    //占位图
                .setPlaceholderImageScaleType(ScalingUtils.ScaleType.FIT_XY)    //占位图拉伸
                .setActualImageFocusPoint(focusPoint)
                .setActualImageScaleType(ScalingUtils.ScaleType.FOCUS_CROP)     //图片拉伸（配合上面的focusPoint）
                .build();
        imageView.setHierarchy(hierarchy);

        //加载
        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_RESOURCE_SCHEME)
                .path(String.valueOf(imageResId))
                .build();
        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setUri(uri)
                .setOldController(imageView.getController())
                .setControllerListener(new BaseControllerListener<ImageInfo>())
                .build();
        imageView.setController(controller);

        if(isCircle){
            //圆
            RoundingParams roundingParams = RoundingParams.fromCornersRadius(0);
            roundingParams.setRoundAsCircle(true);
            if(border > 0 && color != 0){
                roundingParams.setBorder(color, border);
            }
            imageView.getHierarchy().setRoundingParams(roundingParams);
        }else {
            //圆角
            RoundingParams roundingParams = RoundingParams.fromCornersRadius(0);
            roundingParams.setCornersRadii(topLeftRadius, topRightRadius, bottomRightRadius, bottomLeftRadius);
            imageView.getHierarchy().setRoundingParams(roundingParams);
        }
    }

    /**
     * 加载本地图片
     * @param imageView
     * @param imageResId
     */
    public static void loadRes(SimpleDraweeView imageView, @DrawableRes int imageResId) {
        //加载
        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_RESOURCE_SCHEME)
                .path(String.valueOf(imageResId))
                .build();
        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setUri(uri)
                .setOldController(imageView.getController())
                .setControllerListener(new BaseControllerListener<ImageInfo>())
                .build();
        imageView.setController(controller);
    }

    /**
     * 加载本地SD卡图片
     * @param imageView
     * @param path 本地路径 如:/sdcard/pics/logo.jpg
     */
    public static void loadFile(SimpleDraweeView imageView, String path){
        loadFile(imageView, path, 0, 0);
    }

    /**
     * 加载本地SD卡图片; 压缩图片;
     * @param imageView
     * @param path 本地路径 如:/sdcard/pics/logo.jpg
     * @param reSizeWidth  压缩宽度
     * @param reSizeHeight 压缩高度
     */
    public static void loadFile(SimpleDraweeView imageView, String path, int reSizeWidth, int reSizeHeight) {
        //加载
        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_FILE_SCHEME)
                .path(path)
                .build();
        ImageRequest request;
        if(reSizeWidth > 0 && reSizeHeight > 0){
            //压缩
            request = ImageRequestBuilder
                    .newBuilderWithSource(uri)
                    .setResizeOptions(new ResizeOptions(reSizeWidth, reSizeHeight))
                    .build();
        }else{
            //不压缩
            request = ImageRequestBuilder
                    .newBuilderWithSource(uri)
                    .build();
        }

        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setImageRequest(request)
                .setOldController(imageView.getController())
                .setControllerListener(new BaseControllerListener<ImageInfo>())
                .build();
        imageView.setController(controller);
    }

    //------------------------ 加载本地 end -----------------------


    //------------------------ 图片拉伸方式 start ------------------------

    /**
     * 左上角对齐; 以长边比例裁剪; 可圆边;
     * (应用场景：由于重复创建Hierarchy会比较耗内存，例如在RecyclerView中, 所以当ViewHolder创建时，即可使用此方法为SimpleDraweeView创建一个Hierarchy,
     * 在onBindViewHolder时，set入数据即可)
     * @param context
     * @param imageView
     * @param placeholderResId 占位图ID
     * @param isCircle 是否圆型
     */
    public static void setHierarchy(Context context, SimpleDraweeView imageView, @DrawableRes int placeholderResId, boolean isCircle) {
        setHierarchy(context, imageView, placeholderResId, isCircle , 0, 0, 0, 0);
    }

    /**
     * 左上角对齐; 以长边比例裁剪; 可边框; 可圆边;
     * (应用场景：由于重复创建Hierarchy会比较耗内存，例如在RecyclerView中, 所以当ViewHolder创建时，即可使用此方法为SimpleDraweeView创建一个Hierarchy,
     * 在onBindViewHolder时，set入数据即可)
     * @param context
     * @param imageView
     * @param placeholderResId 占位图ID
     * @param isCircle 是否圆型
     */
    public static void setHierarchy(Context context, SimpleDraweeView imageView, @DrawableRes int placeholderResId, boolean isCircle, float border, @ColorInt int color) {
        setHierarchy(context, imageView, placeholderResId, isCircle , border, color, 0, 0, 0, 0);
    }

    /**
     * 左上角对齐; 以长边比例裁剪; 可圆边圆角;
     * (应用场景：由于重复创建Hierarchy会比较耗内存，例如在RecyclerView中, 所以当ViewHolder创建时，即可使用此方法为SimpleDraweeView创建一个Hierarchy,
     * 在onBindViewHolder时，set入数据即可)
     * @param context
     * @param imageView
     * @param placeholderResId 占位图ID
     * @param isCircle 是否圆型
     * @param topLeftRadius 圆角弧度（非圆型时生效）
     * @param topRightRadius 圆角弧度（非圆型时生效）
     * @param bottomRightRadius 圆角弧度（非圆型时生效）
     * @param bottomLeftRadius 圆角弧度（非圆型时生效）
     */
    public static void setHierarchy(Context context, SimpleDraweeView imageView, @DrawableRes int placeholderResId, boolean isCircle, float topLeftRadius, float topRightRadius, float bottomLeftRadius, float bottomRightRadius) {
        setHierarchy(context, imageView, placeholderResId, isCircle , 0, -1, topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius);
    }

    /**
     * 左上角对齐; 以长边比例裁剪; 可边框; 可圆边圆角;
     * (应用场景：由于重复创建Hierarchy会比较耗内存，例如在RecyclerView中, 所以当ViewHolder创建时，即可使用此方法为SimpleDraweeView创建一个Hierarchy,
     * 在onBindViewHolder时，set入数据即可)
     * @param context
     * @param imageView
     * @param placeholderResId 占位图ID
     * @param isCircle 是否圆型
     * @param topLeftRadius 圆角弧度（非圆型时生效）
     * @param topRightRadius 圆角弧度（非圆型时生效）
     * @param bottomRightRadius 圆角弧度（非圆型时生效）
     * @param bottomLeftRadius 圆角弧度（非圆型时生效）
     */
    public static void setHierarchy(Context context, SimpleDraweeView imageView, @DrawableRes int placeholderResId, boolean isCircle, float border, @ColorInt int color, float topLeftRadius, float topRightRadius, float bottomLeftRadius, float bottomRightRadius) {
        //对齐方式(左上角对齐)
        PointF focusPoint = new PointF();
        focusPoint.x = 0f;
        focusPoint.y = 0f;

        //占位图，拉伸方式
        GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(context.getResources());
        GenericDraweeHierarchy hierarchy = builder
                .setFadeDuration(300)
                .setPlaceholderImage(placeholderResId)    //占位图
                .setPlaceholderImageScaleType(ScalingUtils.ScaleType.FIT_XY)    //占位图拉伸
                .setActualImageFocusPoint(focusPoint)
                .setActualImageScaleType(ScalingUtils.ScaleType.FOCUS_CROP)     //图片拉伸（配合上面的focusPoint）
                .build();
        imageView.setHierarchy(hierarchy);

        if(isCircle){
            //圆
            RoundingParams roundingParams = RoundingParams.fromCornersRadius(0);
            roundingParams.setRoundAsCircle(true);
            if(border > 0 && color != 0){
                roundingParams.setBorder(color, border);
            }
            imageView.getHierarchy().setRoundingParams(roundingParams);
        }else {
            //圆角
            RoundingParams roundingParams = RoundingParams.fromCornersRadius(0);
            roundingParams.setCornersRadii(topLeftRadius, topRightRadius, bottomRightRadius, bottomLeftRadius);
            imageView.getHierarchy().setRoundingParams(roundingParams);
        }
    }

    //------------------------ 图片拉伸方式 end ------------------------
}
