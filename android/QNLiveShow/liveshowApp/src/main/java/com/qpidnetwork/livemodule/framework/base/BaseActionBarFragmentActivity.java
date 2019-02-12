package com.qpidnetwork.livemodule.framework.base;

import android.graphics.PointF;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.DrawableRes;
import android.support.transition.Slide;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

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
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.view.MaterialAppBar;

/**
 * 添加基础ActionBar
 *
 * @author Hunter
 * @since 2015.4.24
 */
public class BaseActionBarFragmentActivity extends BaseFragmentActivity {

    private LinearLayout llContainer;

    protected View fl_commTitleBar;
    protected ImageView iv_commBack;
    protected TextView tv_commTitle;
    protected SimpleDraweeView img_commTitle;
    protected LinearLayout ll_title_body, ll_title_right;

    protected View mBottomDivider;

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setContentView(R.layout.activity_live_base_actionbar);
        initView();
    }

    private void initView() {
        //状态栏颜色
//		StatusBarUtil.setColor(this, Color.parseColor("#5d0e86"),0);

        fl_commTitleBar = findViewById(R.id.view_commTitleBar);
        iv_commBack = (ImageView) findViewById(R.id.iv_commBack);
        iv_commBack.setOnClickListener(this);
        tv_commTitle = (TextView) findViewById(R.id.tv_commTitle);
        tv_commTitle.setTextSize(18);
        tv_commTitle.setOnClickListener(this);
        llContainer = (LinearLayout) findViewById(R.id.llContainer);
        img_commTitle = (SimpleDraweeView) findViewById(R.id.img_commTitle);
        img_commTitle.setOnClickListener(this);
        ll_title_body = findViewById(R.id.ll_title_body);
        ll_title_right = findViewById(R.id.ll_title_right);

        mBottomDivider = (View) findViewById(R.id.bottomDivider);
    }

    protected void setCustomContentView(int layoutResId) {
        LayoutInflater.from(this).inflate(layoutResId, llContainer);
    }

    public MaterialAppBar getCustomActionBar(String title, int txtColor) {
        return null;
    }

    /**
     * 隐藏标题栏底部分割线
     */
    public void hideTitleBarBottomDivider() {
        if (mBottomDivider != null) {
            mBottomDivider.setVisibility(View.GONE);
        }
    }

    protected void setTitle(String title, int txtColorResId) {
        if (!TextUtils.isEmpty(title)) {
            tv_commTitle.setText(title);
        }
        tv_commTitle.setTextColor(getResources().getColor(txtColorResId));
    }

    /**
     * Add By Hardy
     *
     * @param title
     */
    protected void setOnlyTitle(String title) {
        if (!TextUtils.isEmpty(title)) {
            tv_commTitle.setText(title);
        }
    }

    /**
     * 设置标题图标
     * add by Jagger 2018-11-22
     *
     * @param imageUrl
     * @param isCircle
     * @param resId
     */
    protected void setTitleImage(String imageUrl, boolean isCircle, @DrawableRes int resId) {

        img_commTitle.setVisibility(View.VISIBLE);

        //对齐方式(左上角对齐)
        PointF focusPoint = new PointF();
        focusPoint.x = 0f;
        focusPoint.y = 0f;

        //初始化圆角圆形参数对象
        RoundingParams rp = new RoundingParams();
        //设置图像是否为圆形
        rp.setRoundAsCircle(isCircle);
        //
        if (isCircle) {
            //设置圆角半径
            rp.setCornersRadius(getResources().getDimensionPixelSize(R.dimen.live_size_30dp));
        }else{
            rp.setCornersRadius(getResources().getDimensionPixelSize(R.dimen.live_size_4dp));
        }
        //获取GenericDraweeHierarchy对象
        GenericDraweeHierarchy hierarchy = GenericDraweeHierarchyBuilder.newInstance(getResources())
                //设置圆形圆角参数
                .setRoundingParams(rp)
                .setPlaceholderImage(resId)    //占位图
                .setPlaceholderImageScaleType(ScalingUtils.ScaleType.FIT_XY)    //占位图拉伸
                .setActualImageFocusPoint(focusPoint)
                .setActualImageScaleType(ScalingUtils.ScaleType.FOCUS_CROP)     //图片拉伸（配合上面的focusPoint）
                .setFadeDuration(1000)
                //构建
                .build();

        //设置Hierarchy
        img_commTitle.setHierarchy(hierarchy);

        //压缩、裁剪图片
        if(!TextUtils.isEmpty(imageUrl)){
            Uri imageUri = Uri.parse(imageUrl);
            ImageRequest request = ImageRequestBuilder.newBuilderWithSource(imageUri)
                    .setResizeOptions(new ResizeOptions(getResources().getDimensionPixelSize(R.dimen.actionbar_height), getResources().getDimensionPixelSize(R.dimen.actionbar_height)))
                    .build();
            DraweeController controller = Fresco.newDraweeControllerBuilder()
                    .setImageRequest(request)
                    .setOldController(img_commTitle.getController())
                    .setControllerListener(new BaseControllerListener<ImageInfo>())
                    .build();

            //设置Controller
            img_commTitle.setController(controller);
        }
    }

    /**
     * 设置标题图标
     * add by Jagger 2018-7-31
     *
     * @param imageUrl
     * @param isCircle
     */
    protected void setTitleImage(String imageUrl, boolean isCircle) {
        setTitleImage(imageUrl, isCircle, R.color.transparent_full);
    }

    /**
     *
     * @param gravity
     */
    protected void setTitleBodyGravity(int gravity){
        ll_title_body.setGravity(gravity);
    }

    protected void setTitleVisible(int visibility) {
        fl_commTitleBar.setVisibility(visibility);
        //解决头部盖在内容上方问题
        RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) llContainer.getLayoutParams();
        if (visibility == View.VISIBLE) {
            params.topMargin = DisplayUtil.dip2px(this, 56);
        } else {
            params.topMargin = 0;
        }
    }

    /**
     * 标题文字被点击响应
     */
    protected void onTitleClicked() {

    }

    /**
     * 2018/10/26 hardy
     * 设置返回按钮的图标
     *
     * @param resId
     */
    protected void setTitleBackResId(@DrawableRes int resId) {
        iv_commBack.setImageResource(resId);
    }

    /**
     *
     * @param drawableId
     * @param onClickListener
     */
    protected void addTitleRightMenu(@DrawableRes int drawableId, View.OnClickListener onClickListener){
        ImageView imageView = new ImageView(mContext);
        imageView.setImageResource(drawableId);
        imageView.setBackgroundResource(R.drawable.touch_feedback_holo_light_circle);
        imageView.setOnClickListener(onClickListener);
        imageView.setScaleType(ImageView.ScaleType.CENTER);
        ll_title_right.addView(imageView);
        ViewGroup.LayoutParams layoutParams = imageView.getLayoutParams();
        layoutParams.width = getResources().getDimensionPixelSize(R.dimen.actionbar_backicon_height);
        layoutParams.height = getResources().getDimensionPixelSize(R.dimen.actionbar_backicon_height);
        imageView.setLayoutParams(layoutParams);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.iv_commBack) {
            finish();
        } else if (i == R.id.tv_commTitle) {
            onTitleClicked();
        } else if (i == R.id.img_commTitle) {
            onTitleClicked();
        }
    }
}
