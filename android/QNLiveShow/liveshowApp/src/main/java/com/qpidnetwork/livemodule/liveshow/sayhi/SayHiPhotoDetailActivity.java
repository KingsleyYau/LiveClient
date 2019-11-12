package com.qpidnetwork.livemodule.liveshow.sayhi;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;

import xyz.zpayh.hdimage.HDImageView;
import xyz.zpayh.hdimage.ImageSource;
import xyz.zpayh.hdimage.ImageSourceBuilder;

public class SayHiPhotoDetailActivity extends BaseActionBarFragmentActivity {


    private final static String KEY_IMAGE_URL = "KEY_IMAGE_URL";

    public static void luanch(Context context,
                              String imageUrl) {

        Intent intent = new Intent(context, SayHiPhotoDetailActivity.class);
        intent.putExtra(KEY_IMAGE_URL, imageUrl);
        context.startActivity(intent);
    }

    private HDImageView scaleImage;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_say_hi_photo_detail);

        initTitle();
        initView();
        initData();
    }

    /**
     * 初始化Title
     */
    private void initTitle() {
        //title处理
        setTitle("", R.color.theme_default_black);
        fl_commTitleBar.setBackgroundColor(Color.parseColor("#2B2B2B"));
        tv_commTitle.setText("");
        setTitleBackResId(R.drawable.ic_arrow_back_white);
        hideTitleBarBottomDivider();
    }

    private void initView() {
        scaleImage = findViewById(R.id.scale_image);
        scaleImage.setMaxScale(5f);
    }

    /**
     * 初始化数据
     */
    private void initData() {
        Intent data = getIntent();
        String imageUrl = data.getStringExtra(KEY_IMAGE_URL);
        if (!TextUtils.isEmpty(imageUrl)) {
            ImageSource imageSource = ImageSourceBuilder.newBuilder()
                    .setUri(imageUrl)
                    .build();
            scaleImage.setImageSource(imageSource);
        }
    }
}
