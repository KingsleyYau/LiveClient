package com.qpidnetwork.livemodule.liveshow.guide;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;


import com.qpidnetwork.livemodule.R;

import java.util.ArrayList;
import java.util.List;

public class GuideActivity extends Activity {

    private static final String KEY_TYPE = "guideType";

    private ViewPager mIn_vp;
    private LinearLayout mIn_ll;
    private List<View> mViewList;
    private Integer[] mResIdList;
    private ImageView mLight_dots;
    private int mDistance;
    private Button mBtn_next;

    /**
     * 引导页类型
     */
    public enum GuideType{
        ALL,
        PAY
    }

    public static Intent getIntent(Context context, GuideType type){
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
                mDistance = mIn_ll.getChildAt(1).getLeft() - mIn_ll.getChildAt(0).getLeft();
                mLight_dots.getViewTreeObserver()
                        .removeGlobalOnLayoutListener(this);
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
                }
                if(position != mViewList.size() - 1 && mBtn_next.getVisibility() == View.VISIBLE){
                    mBtn_next.setVisibility(View.GONE);
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
                }
                if(position != mViewList.size() - 1 && mBtn_next.getVisibility() == View.VISIBLE){
                    mBtn_next.setVisibility(View.GONE);
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
                if(type == GuideType.ALL){
                    mResIdList = new Integer[]{
                            R.drawable.live_guide_all_1 ,
                            R.drawable.live_guide_all_2 ,
                            R.drawable.live_guide_all_3 ,
                            R.drawable.live_guide_all_4 ,
                            R.drawable.live_guide_all_5
                    };
                }else if(type == GuideType.PAY){
                    mResIdList = new Integer[]{
                            R.drawable.live_guide_pay_1 ,
                            R.drawable.live_guide_pay_2 ,
                            R.drawable.live_guide_pay_3 ,
                            R.drawable.live_guide_pay_4
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
                ImageView imgBg = (ImageView) view.findViewById(R.id.img_guide_bg);
                imgBg.setBackgroundResource(mResIdList[i]);
                mViewList.add(view);
            }
        }

        mIn_vp.setAdapter(new GuideAdatper(mViewList));
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
    }
}
