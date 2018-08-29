package com.qpidnetwork.livemodule.liveshow.guide;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;

import java.util.ArrayList;
import java.util.List;

public class GuideActivity extends Activity {

    private static final String KEY_TYPE = "guideType";
    private static int GUIDE_VERSON = 329;

    private ViewPager mIn_vp;
    private LinearLayout mIn_ll;
    private List<View> mViewList;
    private Integer[] mResIdList;
    private ImageView mLight_dots;
    private int mDistance;
    private Button mBtn_next;
    private LinearLayout mLLBottom;
    private TextView mTextView;

    /**
     * 引导页类型
     */
    public enum GuideType{
        MAIN_A,
        MAIN_B,
        PROFILE_A,
        PROFILE_B
    }

    /**
     *
     * @param context
     * @param type
     */
    public static void show(Context context, GuideType type){
        //SP
        SharedPreferences sharedPreferences = context.getSharedPreferences("guideSetting", MODE_PRIVATE);

        //小于指定版本号　则显示引导
        boolean isShow = sharedPreferences.getBoolean("guideVersion", true);
        if(isShow){ // < 可以改为某个版本号，不然每次更新都会显示引导页
            context.startActivity(GuideActivity.getIntent(context , type));

            //保存版本号，表示已经看过
            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.putBoolean("guideVersion", false);
            editor.commit();
        }
    }

    private static Intent getIntent(Context context, GuideType type){
        Intent intent = new Intent(context, GuideActivity.class);
        intent.putExtra(KEY_TYPE, type.ordinal());
        return intent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_guide_live);
        initView();
        initData();
        addDots();
        moveDots();
//        mIn_vp.setPageTransformer(true,new DepthPageTransformer());
    }

    private void moveDots() {
        mLight_dots.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                //获得两个圆点之间的距离
                if(mIn_ll.getChildCount() > 1){
                    mDistance = mIn_ll.getChildAt(1).getLeft() - mIn_ll.getChildAt(0).getLeft();
                    mLight_dots.getViewTreeObserver()
                            .removeGlobalOnLayoutListener(this);
                }
            }
        });
        mIn_vp.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
                //页面滚动时小白点移动的距离，并通过setLayoutParams(params)不断更新其位置
                float leftMargin = mDistance * (position + positionOffset);
                RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) mLight_dots.getLayoutParams();
                params.leftMargin = (int) leftMargin;
                mLight_dots.setLayoutParams(params);
                if(position == mViewList.size() - 1){
                    mBtn_next.setVisibility(View.VISIBLE);
                    mLLBottom.setVisibility(View.VISIBLE);
                }
                if(position != mViewList.size() - 1 && mBtn_next.getVisibility() == View.VISIBLE){
                    mBtn_next.setVisibility(View.GONE);
                    mLLBottom.setVisibility(View.INVISIBLE);
                }
            }

            @Override
            public void onPageSelected(int position) {
                //页面跳转时，设置小圆点的margin
                float leftMargin = mDistance * position;
                RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) mLight_dots.getLayoutParams();
                params.leftMargin = (int) leftMargin;
                mLight_dots.setLayoutParams(params);
                if(position == mViewList.size() - 1){
                    mBtn_next.setVisibility(View.VISIBLE);
                    mLLBottom.setVisibility(View.VISIBLE);
                }
                if(position != mViewList.size() - 1 && mBtn_next.getVisibility() == View.VISIBLE){
                    mBtn_next.setVisibility(View.GONE);
                    mLLBottom.setVisibility(View.INVISIBLE);
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    /**
     * 下面几个点点
     */
    private void addDots() {
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        layoutParams.setMargins(20, 0, 20, 0);//与.xml中的iv_light_dots.paddingLeft对应

        for(int i = 0 ; i < mViewList.size() ; i++){
            ImageView imgGrayDot = new ImageView(this);
            imgGrayDot.setImageResource(R.drawable.live_guide_gray_dot);
            mIn_ll.addView(imgGrayDot, layoutParams);
//        imgGrayDot.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                mIn_vp.setCurrentItem(0);
//            }
//        });
        }
    }


    private void initData() {

        Bundle bundle = getIntent().getExtras();
        if(bundle != null) {
            if (bundle.containsKey(KEY_TYPE)) {
                GuideType type = GuideType.values()[bundle.getInt(KEY_TYPE)];
                if(type == GuideType.MAIN_A){
                    mResIdList = new Integer[]{
                            R.drawable.live_guide_a_1,
                            R.drawable.live_guide_a_2,
                            R.drawable.live_guide_a_3,
                            R.drawable.live_guide_a_4
                    };
                }else if(type == GuideType.MAIN_B){
                    mResIdList = new Integer[]{
                            R.drawable.live_guide_b_1,
                            R.drawable.live_guide_b_2,
                            R.drawable.live_guide_b_3,
                            R.drawable.live_guide_b_4
                    };
                }else if(type == GuideType.PROFILE_A){
                    mResIdList = new Integer[]{
                            R.drawable.live_guide_profile_a_1,
                            R.drawable.live_guide_profile_a_2,
                            R.drawable.live_guide_profile_a_3,
                            R.drawable.live_guide_profile_a_4
                    };
                }else if(type == GuideType.PROFILE_B){
                    mResIdList = new Integer[]{
                            R.drawable.live_guide_profile_b_1,
                            R.drawable.live_guide_profile_b_2,
                            R.drawable.live_guide_profile_b_3,
                            R.drawable.live_guide_profile_b_4
                    };
                }
            }
        }


        mViewList = new ArrayList<View>();
        LayoutInflater lf = getLayoutInflater().from(this);
        //TODO:Solve block at here ,spent time 1033ms
        if(mResIdList != null){
            for (int i = 0 ; i < mResIdList.length; i++){
                View view = lf.inflate(R.layout.view_live_guide_page, null);
//                ImageView imgBg = (ImageView) view.findViewById(R.id.img_guide_bg);
//                imgBg.setBackgroundResource(mResIdList[i]);
                mViewList.add(view);
            }
        }

        mIn_vp.setAdapter(new GuideAdatper(mViewList , mResIdList));
    }

    private void initView() {
        mIn_vp = (ViewPager) findViewById(R.id.in_viewpager);
        mIn_ll = (LinearLayout) findViewById(R.id.in_ll);
        mLight_dots = (ImageView) findViewById(R.id.iv_light_dots);
        mBtn_next = (Button) findViewById(R.id.bt_next);
        mBtn_next.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mLLBottom = (LinearLayout)findViewById(R.id.ll_guide_bottom);

        mTextView = (TextView)findViewById(R.id.txt_guide_link);
//        mTextView.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG); //下划线
//        mTextView.getPaint().setAntiAlias(true);//抗锯齿
//        mTextView.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                onClickedLink();
//            }
//        });
        //最后一页底部文字
        SpannableString spanText=new SpannableString(getString(R.string.live_guide_tips2));
        spanText.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(Color.WHITE);       //设置文件颜色
                ds.setUnderlineText(true);      //设置下划线
            }
            @Override
            public void onClick(View widget) {
                onClickedLink();
            }
        }, 0 , spanText.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        mTextView.setHighlightColor(Color.TRANSPARENT); //设置点击后的颜色为透明，否则会一直出现高亮
        mTextView.append(" ");
        mTextView.append(spanText);
        mTextView.setMovementMethod(LinkMovementMethod.getInstance());//开始响应点击事件
    }

    /**
     * 点击连接
     */
    private void onClickedLink(){
        if(LoginManager.getInstance().getSynConfig() != null){
            startActivity(WebViewActivity.getIntent(GuideActivity.this,
                     getResources().getString(R.string.live_webview_user_terms_title),
                    WebViewActivity.UrlIntent.View_Terms_Of_Use,
                    null,
                    true));
        }
    }
}
