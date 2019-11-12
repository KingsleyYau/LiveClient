package com.qpidnetwork.livemodule.liveshow.sayhi;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;

public class SayHiNoteActivity extends BaseActionBarFragmentActivity {


    private final static String KEY_IMAGE_URL = "KEY_IMAGE_URL";
    private final static String KEY_LADY_NAME = "KEY_LADY_NAME";
    private final static String KEY_LADY_CONTENT = "KEY_LADY_CONTENT";

    public static void luanch(Context context,
                              String imageUrl,
                              String ladyName,
                              String content) {

        Intent intent = new Intent(context, SayHiNoteActivity.class);
        intent.putExtra(KEY_IMAGE_URL, imageUrl);
        intent.putExtra(KEY_LADY_NAME, ladyName);
        intent.putExtra(KEY_LADY_CONTENT, content);
        context.startActivity(intent);
    }

    private SimpleDraweeView img_bg;
    private TextView tv_anchor_name, tv_note_content, tv_man_name;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_say_hi_note);
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
        img_bg = findViewById(R.id.img_bg);
        tv_anchor_name = findViewById(R.id.tv_anchor_name);
        tv_note_content = findViewById(R.id.tv_note_content);
//        tv_note_content.setMovementMethod(ScrollingMovementMethod.getInstance());   //可滚
        tv_man_name = findViewById(R.id.tv_man_name);
    }

    private void initData() {

        Intent data = getIntent();
        String imageUrl = data.getStringExtra(KEY_IMAGE_URL);
        String ladyName = data.getStringExtra(KEY_LADY_NAME);
        String content = data.getStringExtra(KEY_LADY_CONTENT);

        tv_anchor_name.setText(getString(R.string.say_hi_edit_anchor_name, ladyName));
        tv_note_content.setText(content);
        FrescoLoadUtil.loadUrl(img_bg, imageUrl, DisplayUtil.getActivityHeight(mContext));
        tv_man_name.setText(LoginManager.getInstance().getLoginItem().nickName);
    }
}
