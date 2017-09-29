package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.app.Activity;
import android.graphics.drawable.PaintDrawable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.RecycleViewDivider;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.utils.ScreenUtils;
import com.qpidnetwork.livemodule.view.MaterialProgressBar;

import java.util.ArrayList;
import java.util.List;

/**
 * 才艺列表PopupWindow
 * Created by Jagger on 2017/9/20.
 */

public class TalentsPopupWindow {
    private Activity mActivity;
    private View mAnchorView;
    private View mContentView;
    private PopupWindow mPopupWindow;
    private MaterialProgressBar mMaterialProgressBar;
    private LinearLayout mLLayoutEmpty;
    private Button mBtnReload;

    private TalentsAdapter mAdapter;
    private List<TalentInfoItem> mDatas = new ArrayList<>();
    private onBtnClickedListener mOnBtnClickedListener;

    /**
     * 操作回调
     */
    public interface onBtnClickedListener{
        void onRequestClicked(TalentInfoItem talent);
        void onReloadClicked();
    }

    public TalentsPopupWindow(Activity activity , View anchorView , TalentInfoItem[] datas){
        mActivity = activity;
        mAnchorView = anchorView;

        //转为列表，方便数据刷新
        if(datas != null){
            for (TalentInfoItem item :datas) {
                mDatas.add(item);
            }
        }
        initPopWindow();
    }

    public void setTitleText(String titleText){
        TextView textView = (TextView) mContentView.findViewById(R.id.tv_talentTitle);
        textView.setText(titleText);
    }

    public void setLoadingVisible(boolean visible){
        if(visible){
            mMaterialProgressBar.setVisibility(View.VISIBLE);
            mMaterialProgressBar.spin();

            mLLayoutEmpty.setVisibility(View.GONE);
        }else{
            if(mMaterialProgressBar.isSpinning()){
                mMaterialProgressBar.stopSpinning();
                mMaterialProgressBar.setVisibility(View.GONE);
            }
        }
    }

    public void setEmptyViewVisible(boolean visible){
        if(visible){
            mLLayoutEmpty.setVisibility(View.VISIBLE);
        }else {
            mLLayoutEmpty.setVisibility(View.GONE);
        }

    }

    public void setOnBtnClickedListener(onBtnClickedListener l){
        mOnBtnClickedListener = l;
    }

    public void show(){
        //显示位置
        int windowPos[] = calculatePopWindowPos(mAnchorView, mContentView);
        mPopupWindow.showAtLocation(mAnchorView, Gravity.NO_GRAVITY, windowPos[0], windowPos[1]);
        mAdapter.notifyDataSetChanged();
    }

    public void dismiss(){
        mPopupWindow.dismiss();
    }


    public void refreshData(TalentInfoItem[] datas){
        //转为列表，方便数据刷新
        if(datas != null){
            mDatas.clear();
            for (TalentInfoItem item :datas) {
                mDatas.add(item);
            }
        }
        mAdapter.notifyDataSetChanged();
    }

    private void initPopWindow(){

        mContentView = LayoutInflater.from(mActivity.getApplicationContext()).inflate(R.layout.view_live_popupwindow_talents_list, null);
//        mContentView.setBackgroundColor(Color.WHITE);

        mPopupWindow = new PopupWindow(mContentView,
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT, true);

        //点击屏幕其他部分使其消失
        mPopupWindow.setBackgroundDrawable(new PaintDrawable());
        mPopupWindow.setFocusable(true);

        mMaterialProgressBar = (MaterialProgressBar)mContentView.findViewById(R.id.loading);

        //数据填入
        RecyclerView recyclerView = (RecyclerView) mContentView.findViewById(R.id.rv_talentList);
        //创建默认的线性LayoutManager
        LinearLayoutManager layoutManager = new LinearLayoutManager(mActivity);
        recyclerView.setLayoutManager(layoutManager);
        //设置分割线
        recyclerView.addItemDecoration(new RecycleViewDivider( mActivity, LinearLayoutManager.VERTICAL, R.drawable.live_divider_talent_list));

        //如果可以确定每个item的高度是固定的，设置这个选项可以提高性能
        recyclerView.setHasFixedSize(true);
        //创建并设置Adapter
        mAdapter = new TalentsAdapter(mDatas);
        mAdapter.setOnRequestClickedListener(new TalentsAdapter.onRequestClickedListener() {
            @Override
            public void onRequestClicked(TalentInfoItem talent) {
                if(mOnBtnClickedListener != null){
                    mOnBtnClickedListener.onRequestClicked(talent);
                }
            }
        });
        recyclerView.setAdapter(mAdapter);

        //EmptyView
        mLLayoutEmpty = (LinearLayout)mContentView.findViewById(R.id.ll_talentEmpty);
        mBtnReload = (Button)mContentView.findViewById(R.id.btn_talentReload);
        mBtnReload.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mOnBtnClickedListener != null){
                    mOnBtnClickedListener.onReloadClicked();
                }
            }
        });
    }

    /**
     * 计算出来的位置，y方向就在anchorView的上面和下面对齐显示，x方向就是与屏幕右边对齐显示
     * 如果anchorView的位置有变化，就可以适当自己额外加入偏移来修正
     * @param anchorView  呼出window的view
     * @param contentView   window的内容布局
     * @return window显示的左上角的xOff,yOff坐标
     */
    private static int[] calculatePopWindowPos(final View anchorView, final View contentView) {
        final int windowPos[] = new int[2];
        final int anchorLoc[] = new int[2];

        // 获取锚点View在屏幕上的左上角坐标位置
        anchorView.getLocationOnScreen(anchorLoc);
        final int anchorHeight = anchorView.getHeight();
        // 获取屏幕的高宽
        final int screenHeight = ScreenUtils.getScreenHeight(anchorView.getContext());
        final int screenWidth = ScreenUtils.getScreenWidth(anchorView.getContext());
        contentView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
        // 计算contentView的高宽
        final int windowHeight = contentView.getMeasuredHeight();
        final int windowWidth = contentView.getMeasuredWidth();

        // 判断需要向上弹出还是向下弹出显示
        final boolean isNeedShowUp = (screenHeight - anchorLoc[1] - anchorHeight < windowHeight);
        if (isNeedShowUp) {
            windowPos[0] = screenWidth - windowWidth;
            windowPos[1] = anchorLoc[1] - windowHeight;
        } else {
            windowPos[0] = screenWidth - windowWidth;
            windowPos[1] = anchorLoc[1] + anchorHeight;
        }

        return windowPos;
    }
}
